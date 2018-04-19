<#
.SYNOPSIS
    Collector
.DESCRIPTION
    Create collector/s.
.EXAMPLE
    New-Collector
#>

function New-Collector {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
  param(
    [SumoAPISession]$Session = $sumoSession,
    [parameter(ParameterSetName = "ByObject", ValueFromPipeline = $true, Position = 0)]
    [psobject]$Collector,
    [parameter(ParameterSetName = "ByJson", ValueFromPipeline = $true, Position = 0)]
    [string]$Json,
    [switch]$Force
  )
  process {
    switch ($PSCmdlet.ParameterSetName) {
      "ByObject" {
        $Json = convertCollectorToJson($Collector)
      }
      "ByJson" {
        $Collector = (ConvertFrom-Json $Json).collector
      }
    }
    if ($Force -or $PSCmdlet.ShouldProcess("Create $($Collector.type) collector with name $($Collector.name). Continue?")) {
      $ret = invokeSumoRestMethod -session $Session -method Post -function "collectors" -body $Json
    }
    if ($ret) {
      $ret.collector
    }
  }
}
