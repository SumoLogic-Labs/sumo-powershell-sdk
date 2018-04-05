Import-Module SumoLogic

#### Demo #####################################################################################################

# Create session by inputing access id and key
Get-Credential | New-SumoSession -Deployment Prod

# Create session by giving access id and key in code
# $session = New-SumoSession -Deployment Prod -AccessId "xxxxxxxxx" -AccessKey 'yyyyyyyyyyyyyyyyyyyuyuu'

# Get all collectors 
Get-Collector

# Get all collectors by page
# If you have more than 1000 you must use -Limit and -Offset to get complete results!
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

# Filtering Get-Collector results using other properties

# filter for Hosted or Installable collector types only
Get-Collector -collectorType Installable 
Get-Collector -ByName -NamePattern 'sometext' -Verbose -collectorType Hosted 

# for more than 1000 collectors you must add -Limit greater than your total collector count or you might get incomplete results.
Get-Collector -Limit 10000 -Offset 0 -collectorType Installable -Verbose

# filter by JSON sync mode or not
Get-Collector -sourceSyncMode UI -Verbose  
Get-Collector -limit 10000 -Offset 0 -sourceSyncMode UI -Verbose  
Get-Collector -ByName -NamePattern 'sometext' -sourceSyncMode JSON 

# Filtering Using FilterProperties
# other types of filtering can be achieved this way by passing a hash of properties

# turn on -verbose to get some info about if filtering is working as expected
Get-Collector -ByName -NamePattern 'sometext' -FilterProperties @{"ephemeral" = $false} -Verbose

# agents that are not reporting to sumo
Get-Collector -limit 10000 -Offset 0 -FilterProperties @{ "alive" = $false }  

# you can include multiple FilterProperties at once
Get-Collector -limit 10000 -Offset 0 -FilterProperties @{ "sourceSyncMode" = "UI"; "alive" = $false; "ephemeral" = $false }

