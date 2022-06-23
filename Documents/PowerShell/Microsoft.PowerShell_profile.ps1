Invoke-Expression (oh-my-posh --init --shell pwsh --config "$(scoop prefix oh-my-posh)\themes\powerlevel10k_modern.omp.json")
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
