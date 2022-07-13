#!/usr/bin/env zx

$.verbose = false

// If backup-rsync doesn't exist, it should be 18320@ch-s011.rsync.net
const BORG_BACKUPS = [
  {
    repo: 'ssh://backup-rsync/./icloud_drive_courses',
    folder: '/Users/vsong/Documents/Courses',
    suffix: 'courses'
  },
  {
    repo: 'ssh://backup-rsync/./icloud_drive_books',
    folder: '/Users/vsong/Documents/Books',
    suffix: 'books'
  }
]

const createFlags = [
  '--verbose',
  '--progress',
  '--list',
  '--filter=AME',
  '--stats',
  '--show-rc'
]

const pruneFlags = [
  '--verbose',
  '--progress',
  '--list',
  '--stats',
  '--show-rc',
  '--keep-daily=14',
  '--keep-weekly=10',
  '--keep-monthly=6',
  '--keep-yearly=3'
]

const time = (await $`date -u +"%Y-%m-%dT%H:%M:%SZ"`).stdout.trim()
const host = (await $`hostname`).stdout.trim()

$.prefix += 'source /Users/vsong/.victor-secrets.sh; '

console.log(`${time}\t${chalk.greenBright('Starting backup...')}`)

for (const backup of BORG_BACKUPS) {
  console.log(chalk.magentaBright(`Running borg backup for ${backup.folder}...`))
  const backupExit = await $`BORG_REPO=${backup.repo} borg create ${createFlags} --exclude '*/.DS_Store' --compression auto,zstd,6 ::${time}-${host}-${backup.suffix} ${backup.folder}`

  switch (backupExit.exitCode) {
    case 0:
      console.log(
        `${time}\t${chalk.greenBright(
          `borg backup for ${backup.folder} was successful!`
        )}`
      )
      break
    case 1:
      console.log(
        `${time}\t${chalk.yellowBright(
          `borg backup for ${backup.folder} exited with a warning`
        )}`
      )
      break
    default:
      console.log(
        `${time}\t${chalk.redBright(
          `borg backup for ${backup.folder} exited with an error`
        )}`
      )
      break
  }

  const pruneExit = await $`BORG_REPO=${backup.repo} borg prune ${pruneFlags}`

  switch (pruneExit.exitCode) {
    case 0:
      console.log(
        `${time}\t${chalk.greenBright(
          `borg prune for ${backup.folder} was successful!`
        )}`
      )
      break
    case 1:
      console.log(
        `${time}\t${chalk.yellowBright(
          `borg prune for ${backup.folder} exited with a warning`
        )}`
      )
      break
    default:
      console.log(
        `${time}\t${chalk.redBright(
          `borg prune for ${backup.folder} exited with an error`
        )}`
      )
      break
  }

  await $`BORG_REPO=${backup.repo} borg compact`
}

// TODO: make this more automatic

const RCLONE_BACKUPS = ['personal-onedrive','rice-onedrive', 'unt-onedrive']

for (const backup of RCLONE_BACKUPS) {
  console.log(chalk.magentaBright(`Running rclone copy for ${backup}`))
  const rcloneExit = await $`rclone copy -P ${backup}: personal-rsync:victor-${backup}`
  if (rcloneExit.exitCode == 0) {
    console.log(
      `${time}\t${chalk.greenBright(
        `rclone copy for ${backup} exited successfully`
      )}`
    )
  } else {
    console.log(
      `${time}\t${chalk.redBright(
        `rclone copy for ${backup} exited with an error`
      )}`
    )
  }
}

console.log(chalk.magentaBright(`Running rclone copy for Google Photos`))

const rcloneExit = await $`rclone copy -P personal-google-photos:/media/by-month personal-rsync:google-photos-backup/media/by-month`

if (rcloneExit.exitCode == 0) {
  console.log(
    `${time}\t${chalk.greenBright(
      `rclone copy for Google Photos exited successfully`
    )}`
  )
} else {
  console.log(
    `${time}\t${chalk.redBright(
      `rclone copy for Google Photos exited with an error`
    )}`
  )
}
