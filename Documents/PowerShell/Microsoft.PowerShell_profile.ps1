Invoke-Expression (oh-my-posh --init --shell pwsh --config "~/Documents/PowerShell/hotstick.minimal.omp.json")
:# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
