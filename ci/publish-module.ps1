if ($env:appveyor_build_version) {
  try {
    $file = Get-Item -Path "$PSScriptRoot/../src/main/SumoLogic-Core/SumoLogic-Core.psd1"
    $regex = "ModuleVersion\s+=\s+'(\d\.\d\.\d+)'"
    $version = (Get-Content $file | Select-String -Pattern $regex).Matches.Groups[1].Value
    Write-Host "Publishing to PowerShell Gallery with version $version ..."
    Publish-Module -Path "$PSScriptRoot/src/main/SumoLogic-Core" -NuGetApiKey $env:NuGetApiKey -ErrorAction Stop
    Write-Host "SumoLogic-Core PowerShell Module version $version published to the PowerShell Gallery." -ForegroundColor Green
  } catch {
    Write-Warning "Fail to publish module to PowerShell Gallery"
    throw $_
  }
}
