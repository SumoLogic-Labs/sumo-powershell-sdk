<#
.SYNOPSIS
    Collector
.DESCRIPTION
    Get collector/s details.
.EXAMPLE
    Get-Collector
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
