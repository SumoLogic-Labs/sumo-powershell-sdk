Clear-Host

$Script:ModuleName = "SumoLogic"
Remove-Module $ModuleName -Force -ErrorAction SilentlyContinue

$Script:ModuleRoot = Get-Item "..\main\SumoLogic"
Write-Host "Module Root - $ModuleRoot"
$Script:TestRoot = Get-Item "$PSScriptRoot\SumoLogic"
Write-Host "Test Root - $TestRoot"

Import-Module "$ModuleRoot\SumoLogic.psd1"

Write-Information "Running tests..."
Get-ChildItem $TestRoot -Recurse -Include "*.ps1" | ForEach-Object { 
  & $_.FullName
}
Write-Information "Done."