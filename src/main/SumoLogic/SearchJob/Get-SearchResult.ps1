<#
.SYNOPSIS
    Get results
.DESCRIPTION
    Call results of a search.
.EXAMPLE
    Get-SearchResult
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
