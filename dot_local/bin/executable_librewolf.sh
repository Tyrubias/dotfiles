#!/bin/bash

set -euo pipefail

PROFILE_DIR=$(mktemp -d)

/Applications/LibreWolf.app/Contents/MacOS/librewolf -profile "${PROFILE_DIR}" -no-remote -new-instance >/dev/null 2>&1 || true

rm -rf "${PROFILE_DIR}"
