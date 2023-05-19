#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

PROFILE_DIR=$(mktemp -d)

function cleanup {
  rm -rf "${PROFILE_DIR}"
}

trap cleanup EXIT

/Applications/LibreWolf.app/Contents/MacOS/librewolf -profile "${PROFILE_DIR}" -no-remote -new-instance >/dev/null 2>&1 || true
