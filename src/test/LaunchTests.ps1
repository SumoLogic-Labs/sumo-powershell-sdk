Clear-Host

Write-Information "Running tests..."
Get-ChildItem $TestRoot -Recurse -Include "*.ps1" | ForEach-Object { 
  & $_.FullName
}
Write-Information "Done."