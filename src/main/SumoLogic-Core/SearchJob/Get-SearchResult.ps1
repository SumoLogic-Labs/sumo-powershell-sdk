<#
.SYNOPSIS
Get the result of search

.DESCRIPTION
Get the result of a search job. It could be in messages (for log search) or in records (for aggregating)

.PARAMETER Session
An instance of SumoAPISession which contains API endpoint and credential

.PARAMETER Id
The search job id, which from the result of Start-SearchJob

.PARAMETER Type
Can be "Message" or "Record"

.PARAMETER Limit
Only return last x entries of results if specified

.EXAMPLE
Start-SearchJob -Query "_sourceCategory=service ERROR" -Last "00:30:00" | Get-SearchResult -Type Message
Search all results in last 30 minutes with "ERROR" in "service" category and return the messages

.EXAMPLE
Start-SearchJob -Query "| count _sourceCategory" -Last "00:30:00" | Get-SearchResult -Type Record
Return the number of messages for each source category in last 30 minutes

.INPUTS
PSObject to present search job

.OUTPUTS
PSObject to present records or messages

.NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter
This call will wait until done gathering results or hit a failure. See link page for details

.LINK
https://help.sumologic.com/APIs/Search-Job-API/About-the-Search-Job-API
#>

function Get-SearchResult {
  [CmdletBinding()]
  param(
    $Session = $Script:sumoSession,
    [parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
    $Id,
    [SumoSearchResultType]$Type = [SumoSearchResultType]::Message,
    [int]$Limit
  )

  getSearchResult $Session $Id $Limit $Type

}
