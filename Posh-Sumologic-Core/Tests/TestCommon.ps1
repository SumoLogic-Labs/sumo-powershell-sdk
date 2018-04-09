# Load module from the local filesystem, instead from the ModulePath
Remove-Module Posh-Sumologic-Core -Force -ErrorAction SilentlyContinue
Import-Module (Split-Path $PSScriptRoot -Parent)

$Script:ModuleName = 'Posh-Sumologic-Core'
$script:FunctionPath = Resolve-Path (Join-Path $PSScriptRoot '../Functions')
