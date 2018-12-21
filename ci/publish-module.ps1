$finalVersion = ""

if(-not [string]::IsNullOrWhiteSpace($env:APPVEYOR_REPO_TAG_NAME)){
  $finalVersion = $env:APPVEYOR_REPO_TAG_NAME.Trim('v')
} else {
  $finalVersion = $env:APPVEYOR_BUILD_VERSION
}

Write-Host "APPVEYOR_REPO_TAG_NAME = $env:APPVEYOR_REPO_TAG_NAME"
Write-Host "APPVEYOR_BUILD_VERSION = $env:APPVEYOR_BUILD_VERSION"

if([string]::IsNullOrWhiteSpace($finalVersion)){
  Write-Error "Unable to determine release version [$finalVersion]"
  exit -1
}

if ($env:APPVEYOR_REPO_TAG -eq 'true') {
  try {
    $file = Get-Item -Path "$PSScriptRoot/../src/main/SumoLogic-Core/SumoLogic-Core.psd1"
    $regex = "(?<=\s+ModuleVersion\s+=\s+')(\d\.\d\.\d+)(?=')"
    $lines = Get-Content $file | ForEach-Object {
      $line = $_
      if ($line -match $regex) {
        $line -replace $regex, $finalVersion
      } else {
        $line
      }
    } 
    $lines | Out-File $file
    Write-Host "Publishing to PowerShell Gallery with version $finalVersion ..."
    Publish-Module -Path "$PSScriptRoot/../src/main/SumoLogic-Core" -NuGetApiKey $env:NuGetApiKey -ErrorAction Stop
    Write-Host "SumoLogic-Core PowerShell Module version $finalVersion published to the PowerShell Gallery." -ForegroundColor Green
  } catch {
    Write-Warning "Fail to publish module to PowerShell Gallery"
    throw $_
  }
} else {
  Write-Warning "Skip Publishing to PowerShell Gallery since APPVEYOR_REPO_TAG = $env:APPVEYOR_REPO_TAG"
}
