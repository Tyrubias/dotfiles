#!/usr/bin/python3
"""
Extracts all artifacts from a .pkg file
"""

import os
import shutil
import subprocess
import sys
import tempfile

XAR_PATH = "/usr/bin/xar"
CPIO_PATH = "/usr/bin/cpio"


def get_extract_dir(pkg_path):
    """
    Returns the directory to extract the contents of the .pkg file to extract
    """
    enclosing_path, pkg_name = os.path.split(os.path.splitext(pkg_path)[0])

    if not os.access(enclosing_path, os.W_OK):
        enclosing_path = os.path.join(os.environ["HOME"], "Downloads")

    extract_dir = os.path.join(enclosing_path, pkg_name)

    if os.path.exists(extract_dir):
        orig_extract_dir = extract_dir
        for i in range(1, 1000):
            extract_dir = "%s-%s" % (orig_extract_dir, str(i))
            if not os.path.exists(extract_dir):
                break
            if i == 999:
                print("Cannot establish appropriate extraction directory.")
                sys.exit()

    return extract_dir


def find_pax(pkg_path):
    """
    Finds .pax and .pax.gz files in the given .pkg file
    """
    for root, _, files in os.walk(pkg_path):
        for filename in files:
            if filename.endswith(".pax") or filename.endswith(".pax.gz"):
                return os.path.join(root, filename)

    return None


def extract_package(pkg_path, extract_dir):
    """
    If a payload exists in the .pkg file, extract it using xar and cpio and return the status
    """
    if os.path.isdir(pkg_path):
        pax_path = find_pax(pkg_path)
        if not pax_path:
            print("Cannot find .pax file. (not a valid package?)")
            return False
        os.mkdir(extract_dir)
        extract_prog = '/bin/pax -r < "%s"'
        if pax_path[-3:] == ".gz":
            extract_prog = '/usr/bin/gzcat "%s" | /bin/pax -r'
        retval = subprocess.run(extract_prog, shell=True, check=True)
        return retval.returncode == 0

    with open(pkg_path, "rb") as pkg_file:
        if pkg_file.read(4) != b"xar!":
            print("Not a valid package.")
            return False

    temp_dir = tempfile.mkdtemp()
    subprocess.run(
        '"%s" -xf "%s"' % (XAR_PATH, pkg_path), shell=True, cwd=temp_dir, check=True
    )

    payloads = []
    for root, _, files in os.walk(temp_dir):
        for filename in filter(lambda x: x == "Payload", files):
            payloads.append(os.path.join(root, filename))

    os.mkdir(extract_dir)
    extract_prog = '/usr/bin/gzcat "%s" | "' + CPIO_PATH + '" -i --quiet'

    if len(payloads) == 0:
        print("No payloads found.")
    elif len(payloads) == 1:
        subprocess.run(
            extract_prog % payloads[0], shell=True, cwd=extract_dir, check=True
        )
    else:
        for payload in payloads:
            subpack_name = os.path.splitext(os.path.basename(os.path.dirname(payload)))[
                0
            ]
            subpack_path = os.path.join(extract_dir, subpack_name)
            os.mkdir(subpack_path)
            subprocess.run(
                extract_prog % payload, shell=True, cwd=subpack_path, check=True
            )

    shutil.rmtree(temp_dir)
    return True


def main():
    """
    Program runner.  Takes in the paths to the .pkg or .mpkg files and extracts them
    """
    for pkg_path in sys.argv[1:]:
        if not os.path.isabs(pkg_path):
            pkg_path = os.path.realpath(pkg_path)

        print('Extracting "%s"...' % os.path.splitext(os.path.basename(pkg_path))[0])
        sys.stdout.flush()

        if not os.access(pkg_path, os.R_OK):
            print("Insufficient permission to read package")
            continue

        extract_dir = get_extract_dir(pkg_path)

        if pkg_path.endswith(".mpkg"):
            os.mkdir(extract_dir)
            count = 0
            for root, dirs, files in os.walk(pkg_path):
                for filename in files + dirs:
                    if filename.endswith(".pkg"):
                        subpkg_extract_dir = os.path.join(
                            extract_dir, os.path.splitext(filename)[0]
                        )
                        if extract_package(
                            os.path.join(root, filename), subpkg_extract_dir
                        ):
                            count += 1
            if count > 0:
                print(
                    'Extracted %d internal package%s to "%s".'
                    % (count, ("", "s")[count > 1], extract_dir)
                )
            else:
                shutil.rmtree(extract_dir)
                print("No packages found within the metapackage.")
        elif pkg_path.endswith(".pkg"):
            if extract_package(pkg_path, extract_dir):
                print("Extracted to %s." % extract_dir)
        else:
            print("Not a package.")

        print("---------------------")

    print("Done!")


if __name__ == "__main__":
    main()
