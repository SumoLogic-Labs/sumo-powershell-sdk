$Script:ModuleName = "SumoLogic-Core"
Remove-Module $ModuleName -Force -ErrorAction SilentlyContinue

Write-Verbose "Location of Global.ps1 - $PSScriptRoot"
$Script:ModuleRoot = Get-Item "$PSScriptRoot\..\..\..\main\SumoLogic-Core"
Write-Verbose "Module Root - $ModuleRoot"
$Script:TestRoot = Get-Item "$PSScriptRoot\.."
Write-Verbose "Test Root - $TestRoot"

Import-Module $ModuleRoot -Force
. "$TestRoot/Common/TestHelpers.ps1"

if (!$AccessId) {
  $Global:AccessId = Read-Host "Please enter your SumoLogic Access ID"
}
if (!$AccessKeyAsSecureString) {
  $Global:AccessKeyAsSecureString = Read-Host "Please enter your SumoLogic Access Key" -AsSecureString
}
New-SumoSession -AccessId $AccessId -AccessKeyAsSecureString $AccessKeyAsSecureString | Out-Null
