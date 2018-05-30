$Script:ModuleName = "SumoLogic-Core"
Remove-Module $ModuleName -Force -ErrorAction SilentlyContinue

Write-Verbose "Location of Global.ps1 - $PSScriptRoot"
$Script:ModuleRoot = Get-Item "$PSScriptRoot\..\..\..\main\SumoLogic-Core"
Write-Verbose "Module Root - $ModuleRoot"
$Script:TestRoot = Get-Item "$PSScriptRoot\.."
Write-Verbose "Test Root - $TestRoot"

Import-Module $ModuleRoot -Force
. "$TestRoot/Common/TestHelpers.ps1"

if ($env:appveyor_test_acc_id) {
  $Global:AccessId = $env:appveyor_test_acc_id
  $Global:AccessKeyAsSecureString = ConvertTo-SecureString $env:appveyor_test_acc_key -AsPlainText -Force
  New-SumoSession -AccessId $AccessId -AccessKeyAsSecureString $AccessKeyAsSecureString | Out-Null
  Get-Collector -NamePattern "PowerShell_Test" | Remove-Collector -Force
}