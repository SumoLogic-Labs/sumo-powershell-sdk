Write-Verbose "Loading SumoLogic module..."

# load functions
$root = $PSScriptRoot

Get-ChildItem -Path $root -Filter "*.ps1" -Recurse | Foreach-Object {
  Write-Verbose "Loading function(s) in $($_.Name)..."
  . $_.FullName
}

Write-Verbose "Done."
