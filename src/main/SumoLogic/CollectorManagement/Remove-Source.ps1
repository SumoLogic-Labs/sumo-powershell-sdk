<#
.SYNOPSIS
    Source
.DESCRIPTION
    Remove sources.
.EXAMPLE
    Remove-Source
#>

function Remove-Source {
  [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
  param(
    [SumoAPISession]$Session = $Script:sumoSession,
    [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [long]$CollectorId,
    [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    [alias("id")]
    [long]$SourceId,
    [switch]$Force
  )
  process {
    $collector = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$CollectorId").collector
    $source = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$CollectorId/sources/$SourceId").source
    if ($source -and ($Force -or $pscmdlet.ShouldProcess("Remove source $(getFullName $source) in collector $(getFullName $collector). Continue?"))) {
      invokeSumoRestMethod -session $Session -method Delete -function "collectors/$CollectorId/sources/$SourceId"
    }
  }
}
