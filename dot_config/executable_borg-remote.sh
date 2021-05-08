#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

export BORG_REPO='ssh://18320@ch-s011.rsync.net/./mac-mini-personal'
export BORG_REMOTE_PATH='borg1'
export DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")-$(hostname)

source '/Users/vsong/.victor-secrets.sh'

info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

info "Starting backup"

/opt/homebrew/bin/borg create \
    --verbose \
    --exclude '*/.DS_Store' \
    --list --filter=AME \
    --stats --show-rc \
    --compression auto,zstd,6 \
    "::${DATE}-personal" \
    /Users/vsong/Personal

backup_exit=$?

info "Pruning repository"

/opt/homebrew/bin/borg prune \
    --list --stats \
    --show-rc \
    --keep-daily 7 \
    --keep-weekly 10 \
    --keep-monthly 6

prune_exit=$?

global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

if [ ${global_exit} -eq 1 ];
then
    info "Backup and/or Prune finished with a warning"
fi

if [ ${global_exit} -gt 1 ];
then
    info "Backup and/or Prune finished with an error"
fi

exit ${global_exit}

