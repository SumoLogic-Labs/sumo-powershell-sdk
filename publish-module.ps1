if ($env:appveyor_build_version) {
  $newVersion = $env:appveyor_build_version
  try {
    $file = Get-Item -Path "$PSScriptRoot/src/main/SumoLogic-Core/SumoLogic-Core.psd1"
    Write-Host "Update module version in $file..."
    $regex = "(?<=ModuleVersion\s+=\s+')\d\.\d\.\d+(?=')"
    (Get-Content $file) -replace $regex, $newVersion | Set-Content $file
    Write-Host "Updated the module version to $newVersion." -ForegroundColor Green
  } catch {
    Write-Warning "Fail to upgrade version in module file"
    throw $_
  }

  try {
    Write-Host "Commit back to GitHub..."
    $env:Path += ";$env:ProgramFiles\Git\cmd"
    Import-Module posh-git -ErrorAction Stop
    git config --global credential.helper store
    Add-Content "$env:USERPROFILE\.git-credentials" "https://$($env:GitHubKey):x-oauth-basic@github.com`n"
    git config --global user.email "byi@sumologic.com"
    git config --global user.name "Bin Yi"
    git config --global core.autocrlf true
    git config --global core.safecrlf false
    git checkout ps_gallery
    git add --all
    git status
    git commit -s -m "Update version to $newVersion"
    git push origin ps_gallery
    Write-Host "PowerShell Module version $newVersion published to GitHub." -ForegroundColor Green
  } catch {
    Write-Warning "Fail to commit module version change"
    throw $_
  }

  try {
    Write-Host "Publishing to PowerShell Gallery..."
    Publish-Module -Path "$PSScriptRoot/src/main/SumoLogic-Core" -NuGetApiKey $env:NuGetApiKey -ErrorAction Stop
    Write-Host "SumoLogic-Core PowerShell Module version $newVersion published to the PowerShell Gallery." -ForegroundColor Green
  } catch {
    Write-Warning "Fail to publish module to PowerShell Gallery"
    throw $_
  }
}
