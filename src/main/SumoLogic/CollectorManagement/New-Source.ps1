<#
.SYNOPSIS
    Source
.DESCRIPTION
    Create sources.
.EXAMPLE
    New-Source
#>

function New-Source {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
  param(
    [SumoAPISession]$Session = $sumoSession,
    [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [alias('id')]
    [long]$CollectorId,
    [parameter(ParameterSetName = "ByObject", Position = 1)]
    [psobject]$Source,
    [parameter(ParameterSetName = "ByJson", Position = 1)]
    [string]$Json,
    [switch]$Force
  )
  process {
    $collector = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$CollectorId").collector
    switch ($PSCmdlet.ParameterSetName) {
      "ByObject" {
        $Json = convertSourceToJson($Source)
      }
      "ByJson" {
        $Source = (ConvertFrom-Json $Json).source
      }
    }
    if ($collector -and ($Force -or $PSCmdlet.ShouldProcess("Create $($Source.sourceType) source with name $($Source.name) in collector $(getFullName $collector)]. Continue?"))) {
      $ret = invokeSumoRestMethod -session $Session -method Post -function "collectors/$collectorId/sources" -body $Json
    }
    if ($ret) {
      $newSource = $ret.source
      Add-Member -InputObject $newSource -MemberType NoteProperty -Name collectorId -Value $CollectorId -PassThru
    }
  }
}
