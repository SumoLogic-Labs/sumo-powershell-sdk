<#
.SYNOPSIS
Get the information of source(s)

.DESCRIPTION
Get the information of source(s) based on collector id and source id or source name pattern

.PARAMETER Session
An instance of SumoAPISession which contains API endpoint and credential

.PARAMETER CollectorId
The id of collector in long

.PARAMETER SourceId
The id of source in long

.PARAMETER NamePattern
A string contains a regular expression which used to search source(s) by name

.EXAMPLE
Get-Source -CollectorId 12345
Get all sources for collector with id 12345

.EXAMPLE
Get-Source -CollectorId 12345 -NamePattern "Web Log File"
Get source(s) which name contains "Web Log File" and in collector with id 12345

.EXAMPLE
Get-Collector -NamePattern "IIS" | Get-Source -NamePattern "Web Log File"
Get all sources which name contains "Web Log File" in all collector(s) wich name contains "IIS"

.NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter

.LINK
https://help.sumologic.com/APIs/01Collector-Management-API/
#>

function Get-Source {
  [CmdletBinding(DefaultParameterSetName = "ById")]
  param(
    [SumoAPISession]$Session = $Script:sumoSession,
    [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [alias('id')]
    [long]$CollectorId,
    [parameter(ParameterSetName = "ById", Position = 1)]
    [long]$SourceId,
    [parameter(ParameterSetName = "ByName", Position = 1)]
    [string]$NamePattern
  )
  process {
    switch ($PSCmdlet.ParameterSetName) {
      "ById" {
        if (-not ($SourceId)) {
          $ret = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$CollectorId/sources").sources
        }
        else {
          $ret = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$CollectorId/sources/$SourceId").source
        }
      }
      "ByName" {
        $ret = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$CollectorId/sources").sources | Where-Object { $_.name -match [regex]$NamePattern }
      }
    }
    if ($ret) {
      $ret | ForEach-Object {
        Add-Member -InputObject $_ -MemberType NoteProperty -Name collectorId -Value $CollectorId -PassThru
      }
    }
  }
}
