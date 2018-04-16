
$Script:ModuleName = "SumoLogic"
Remove-Module $ModuleName -Force -ErrorAction SilentlyContinue

Write-Host "From Global.ps1:" +  $PSScriptRoot
$Script:ModuleRoot = Get-Item "$PSScriptRoot\..\..\..\main\SumoLogic"
Write-Host "Module Root - $ModuleRoot"
$Script:TestRoot = Get-Item "$PSScriptRoot\.."
Write-Host "Test Root - $TestRoot"

Import-Module $ModuleRoot
Import-Module "Microsoft.PowerShell.Utility"