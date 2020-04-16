$collectors=Get-Collector -limit 10 -Offset 1 #-verbose
Write-Host $collectors.name | Sort-Object
Write-Output $collectors.count 