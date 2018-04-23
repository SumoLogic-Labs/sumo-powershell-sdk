
$Script:ModuleName = "SumoLogic"
Remove-Module $ModuleName -Force -ErrorAction SilentlyContinue

Write-Host "From Global.ps1:" +  $PSScriptRoot
$Script:ModuleRoot = Get-Item "$PSScriptRoot\..\..\..\main\SumoLogic"
Write-Host "Module Root - $ModuleRoot"
$Script:TestRoot = Get-Item "$PSScriptRoot\.."
Write-Host "Test Root - $TestRoot"

Import-Module $ModuleRoot -Force
. "$TestRoot/Common/TestHelpers.ps1"

# To run full set of test, uncomment following lines and fill with real access id/key from Sumo Logic
# $Global:AccessId = 
# $Global:AccessKey = 
# New-SumoSession -AccessId $AccessId -AccessKey $AccessKey | Out-Null
