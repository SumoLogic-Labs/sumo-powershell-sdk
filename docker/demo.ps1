$collectors=Get-Collector -limit 10 -Offset 1 #-verbose
Write-Host $collectors | Sort-Object
Write-Output $collectors.count 