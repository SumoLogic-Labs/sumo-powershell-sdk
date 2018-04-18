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
    [parameter(ParameterSetName = "ByObject", ValueFromPipeline = $true)]
    [psobject]$Collector,
    [parameter(ParameterSetName = "ByJson")]
    [string]$Json,
    [switch]$Force
  )
  process {
    if ($PSCmdlet.ParameterSetName -eq "ByObject") {
      $Json = $Collector | ForEach-Object { convertCollectorToJson($_) }
    }
    $Json | ForEach-Object {
      $target = ConvertFrom-Json $_
      if ($Force -or $PSCmdlet.ShouldProcess("Create $($target.collector.type) collector with name $($target.collector.name) will be created. Continue?")) {
        $res = invokeSumoRestMethod -session $Session -headers $headers -method Post -function "collectors" -body $_
        $res.collector
      }
    }
  }
}
