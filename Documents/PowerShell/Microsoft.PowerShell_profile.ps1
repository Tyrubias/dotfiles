oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/powerlevel10k_modern.omp.json" | Invoke-Expression
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
