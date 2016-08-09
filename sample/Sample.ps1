Import-Module SumoLogic

#### Demo #####################################################################################################

# Create session by inputing access id and key
Get-Credential | New-SumoSession -Deployment Prod

# Create session by giving access id and key in code
# $session = New-SumoSession -Deployment Prod -AccessId "xxxxxxxxx" -AccessKey 'yyyyyyyyyyyyyyyyyyyuyuu'

# Get all collectors
Get-Collector

# Get all collectors by page
Get-Collector -Offset 3 -Limit 5

# Get collector by Id
Get-Collector 12345678

# Get collector by NamePattern (RegEx) 
Get-Collector -NamePattern "myCollector.*"

Get-Collector | where {$_.alive -and $_.collectorType -eq "Installable"}

# Set-Collector
Get-Collector 12345678 | ForEach-Object {$_.name = "renamed-collector"; $_} | Set-Collector -Passthru

# Remove-Collector
Get-Collector 12345678 | Remove-Collector

# Get all source of a collector
Get-Collector 12345678 | Get-Source

# Get source by id
Get-Collector 12345678 | Get-Source 98765432

# Get source by name pattern
Get-Collector 12345678 | Get-Source -NamePattern gc

# Set-Source
Get-Collector 12345678 | Get-Source | ForEach-Object {$_.name += " renamed by script"; $_} | Set-Source -Passthru

# Remove-Source
Get-Source -CollectorId 12345678 -SourceId 98765432 | Remove-Source

# Search-Log
# search any exception in last hour and return last 400 results
Start-SearchJob -Query "*exception*" -Last ([TimeSpan]::FromHours(1)) | Get-SearchResult -Limit 400

# search formatted exceptions and count the number with groups 
Start-SearchJob -Query '*exception* | timeslice 1h | split _raw delim='' '' extract _, _, _, level, _, host | count group level, host' | Get-SearchResult -Type Record

