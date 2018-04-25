<#
.SYNOPSIS
Get the information of collector(s)

.DESCRIPTION
Get the information of collector(s) based on id or name pattern. The result can also be retrieved in pages if there are many collectors in your organization

.PARAMETER Session
An instance of SumoAPISession which contains API endpoint and credential

.PARAMETER Id
The id of collector in long

.PARAMETER NamePattern
A string contains a regular expression which used to search collector(s) by name

.PARAMETER Offset
The offset used for paging result

.PARAMETER Limit
The limit (e.g. page size) used for paging result

.EXAMPLE
Get-Collector
Get all collectors in current organization

.EXAMPLE
Get-Collector -Id 12345
Get collector with id 12345

.EXAMPLE
Get-Collector -NamePattern "IIS"
Get all collector(s) which name contains "IIS"

.EXAMPLE
Get-Collector -Offset 100 -Limit 50
Get all collectors in current organization in page; return 50 results from begin from the 100th result

.INPUTS
Not accepted

.OUTPUTS
PSObject to present collector(s)

.NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter

.LINK
https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/Get-Collector.md

.LINK
https://help.sumologic.com/APIs/01Collector-Management-API/
#>

function Get-Collector {
  [CmdletBinding(DefaultParameterSetName = "ById")]
  param(
    [SumoAPISession]$Session = $sumoSession,
    [parameter(ParameterSetName = "ById", Position = 0)]
    [long]$Id,
    [parameter(ParameterSetName = "ByName")]
    [string]$NamePattern,
    [parameter(ParameterSetName = "ByPage", Mandatory = $true)]
    [int]$Offset,
    [parameter(ParameterSetName = "ByPage", Mandatory = $true)]
    [int]$Limit
  )
  switch ($PSCmdlet.ParameterSetName) {
    "ById" {
      if (-not ($Id)) {
        (invokeSumoRestMethod -session $Session -method Get -function "collectors").collectors
      }
      else {
        (invokeSumoRestMethod -session $Session -method Get -function "collectors/$Id").collector
      }
    }
    "ByName" {
      (invokeSumoRestMethod -session $Session -method Get -function "collectors").collectors | Where-Object { $_.name -match [regex]$NamePattern }
    }
    "ByPage" {
      $query = @{
        'offset' = $Offset
        'limit'  = $Limit
      }
      (invokeSumoRestMethod -session $Session -method Get -function "collectors" -query $query).collectors
    }
  }
}
