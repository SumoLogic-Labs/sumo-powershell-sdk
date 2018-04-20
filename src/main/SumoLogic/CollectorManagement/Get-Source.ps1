<#
.SYNOPSIS
    Source
.DESCRIPTION
    Get sources.
.EXAMPLE
    Get-Source
#>

function Get-Source {
  [CmdletBinding(DefaultParameterSetName = "ById")]
  param(
    $Session = $Script:sumoSession,
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
