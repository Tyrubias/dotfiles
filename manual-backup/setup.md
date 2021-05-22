# Operating System Setup Notes

I reinstall and/or change operating systems a lot, so here are some notes to
help my future self get set up much faster.

The most important thing is to re-setup SSH keys in GitHub and on my Digital
Ocean machines and to enable private-key SSH on my local machines.

## Pop! OS

### Make the system behave like macOS

Install GNOME Shell Extensions using `apt`.

```bash
sudo apt install gnome-shell-extensions
```

Then, install the __Dash to Dock__ and __GPaste__ shell extensions, along
with __GPaste__ itself.

Install the __Multi-Monitors Add On__ from source.

In the __GNOME Tweaks__ application, go to `Windows` and check
`Center New Windows`.

```bash
git clone git://github.com/spin83/multi-monitors-add-on.git
cd multi-monitors-add-on
cp -r multi-monitors-add-on@spin83 ~/.local/share/gnome-shell/extensions/
```

To enable centering windows with a shortcut in GNOME 3, run the
following command

```bash
dconf write "/org/gnome/desktop/wm/keybindings/move-to-center" "['<Control><Super>C']"
```

### Other applications

Install __Google Chrome__, __Visual Studio Code__, and __Slack__ from their own
APT repositories.

You can force dark mode in __Google Chrome__ by changing lines containing `Exec=`
to the following:

```
Exec=/usr/bin/google-chrome-stable --enable-features=WebUIDarkMode --force-dark-mode %U
```

Leave out the `%U` for the "Create New Window" action and use the `--incognito` flag for
the "New Incognito Window" action.

### Container stuff

Install __Docker__ from its own APT repository. Install `nvidia-docker2` from Nvidia's
custom repository, then make sure that all its dependencies have a higher priority than
the default Pop! OS repositories.

Install __Docker Compose__ from GitHub.

Configure rootless Docker using the documentation provided on the Docker website. You
need to disable `cgroups` in `/etc/nvidia-container-runtime/config.toml` by uncommenting
`no-cgroups = false` and changing it to `true`.

Install __Podman__ from Red Hat's own repositories. They should be called `kubic`. Google the
online instructions for configuring GPU access. Create the file (and parent folders)
`/usr/share/containers/oci/hooks.d/oci-nvidia-hook.json` with the following content

```json
{
    "version": "1.0.0",
    "hook": {
        "path": "/usr/bin/nvidia-container-toolkit",
        "args": ["nvidia-container-toolkit", "prestart"],
        "env": [
            "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        ]
    },
    "when": {
        "always": true,
	"commands": [".*"]
    },
    "stages": ["prestart"]
}
```

### Private DNS lookups

Install `cloudflared` from its GitHub repository, then create the
`systemd` service as documented. In the `Network` tab of `Settings`,
change the DNS servers to `127.0.0.1` and `::1`. Finally, disable the
stub DNS resolver by editing `/etc/systemd/resolved.conf` and changing
`DNSStubListener` to `no`.

### Enable DynDNS using ddclient

Install `ddclient`, then create the following configuration.

```
use=web, web=dynamicdns.park-your-domain.com/getip
protocol=namecheap
server=dynamicdns.park-your-domain.com
login=vsong.me
password=<YOUR TOKEN HERE>
<YOUR SUBDOMAIN HERE>
```

### All other applications

Install `Linuxbrew`. Then, install `chezmoi` and run `chezmoi init`
on your `new-dotfiles` repository. Don't forget to manually install
the `Dracula` colorscheme for `neovim` and `vim`, as well as `vim-plug`.

## Windows

Disable all the telemetry. Uninstall all the bloatware. You can use
[this debloater project](https://github.com/Sycnex/Windows10Debloater).

Hide Cortana and the Search Box. Hide the icons in the toolbar, and hide
all shortcuts on Desktop. Install Scoop and Chocolatey.

Install Windows Terminal. Then, install [`chezmoi`](https://chezmoi.io/)
Install WSL 2 following [the official Microsoft instructions](https://docs.microsoft.com/en-us/windows/wsl/install-win10).
Then, install Windows Sandbox following [the official Microsoft instructions](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-sandbox/windows-sandbox-overview). Finally, enable Isolated Browsing and Core Isolation.

Don't forget to install hardware monitoring tools like GPU-Z and HWinfo64.
