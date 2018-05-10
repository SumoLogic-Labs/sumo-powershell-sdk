if ($env:appveyor_build_version) {
  $newVersion = $env:appveyor_build_version
  $file = Get-Item -Path "$PSScriptRoot/src/main/SumoLogic-Core/SumoLogic-Core.psd1"
  Write-Host "Update module version in $file..."
  $regex = "(?<=ModuleVersion\s+=\s+')\d\.\d\.\d+(?=')"
  (Get-Content $file) -replace $regex, $newVersion | Set-Content $file
  Write-Host "Updated the module version to $newVersion." -ForegroundColor Green

  Write-Host "Commit back to GitHub..."
  $env:Path += ";$env:ProgramFiles\Git\cmd"
  Import-Module posh-git -ErrorAction Stop
  git config --global credential.helper store
  Add-Content "$env:USERPROFILE\.git-credentials" "https://$($env:GitHubKey):x-oauth-basic@github.com`n"
  git config --global user.email "byi@sumologic.com"
  git config --global user.name "Bin Yi"
  git config --global core.autocrlf true
  git config --global core.safecrlf false
  git status
  git commit -a -m "update version to $newVersion"
  git push
  Write-Host "PowerShell Module version $newVersion published to GitHub." -ForegroundColor Green

  Write-Host "Publishing to PowerShell Gallery..."
  Publish-Module -Path "$PSScriptRoot/src/main/SumoLogic-Core" -NuGetApiKey $env:NuGetApiKey ErrorAction Stop
  Write-Host "SumoLogic-Core PowerShell Module version $newVersion published to the PowerShell Gallery." -ForegroundColor Green
}
