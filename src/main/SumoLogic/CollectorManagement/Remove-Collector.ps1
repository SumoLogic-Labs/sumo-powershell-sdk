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
    $collector = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$Id").collector
    if ($collector -and ($Force -or $pscmdlet.ShouldProcess("Remove collector $(getFullName $collector). Continue?"))) {
      invokeSumoRestMethod -session $Session -method Delete -function "collectors/$Id"
    }
  }
}
