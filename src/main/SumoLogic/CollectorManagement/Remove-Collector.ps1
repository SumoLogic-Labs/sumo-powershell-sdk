<#
.SYNOPSIS
    Collector
.DESCRIPTION
    Remove collector/s.
.EXAMPLE
    Remove-Collector
#>

function Remove-Collector {
  [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
  param(
    [SumoAPISession]$Session = $sumoSession,
    [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [long]$Id,
    [switch]$Force
  )
  process {
    $Id | ForEach-Object {
      if ($Force -or $pscmdlet.ShouldProcess("Collector[$_] will be removed. Continue?")) {
        invokeSumoRestMethod -session $Session -method Delete -function "collectors/$_"
      }
    }
  }
}
