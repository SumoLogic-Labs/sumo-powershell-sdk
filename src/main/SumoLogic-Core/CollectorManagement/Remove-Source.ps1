<#
.SYNOPSIS
Remove a source

.DESCRIPTION
Remove source from specific collector

.PARAMETER Session
An instance of SumoAPISession which contains API endpoint and credential

.PARAMETER CollectorId
The id of collector in long

.PARAMETER SourceId
The id of source in long

.PARAMETER Force
Do not confirm before running

.EXAMPLE
Get-Source -CollectorId 12345 -NamePattern "Web Log File" | Remove-Source
Remove source(s) which name contains "Web Log File" and in collector with id 12345

.INPUTS
PSObject to present source(s)

.OUTPUTS
None

.NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter

.LINK
https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/Remove-Source.md

.LINK
https://help.sumologic.com/APIs/01Collector-Management-API/
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
    if (!$collector) {
      Write-Error "Cannot get collector with id $CollectorId"
    }
    $source = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$CollectorId/sources/$SourceId").source
    if ($source -and ($Force -or $pscmdlet.ShouldProcess("Remove source $(getFullName $source) in collector $(getFullName $collector). Continue?"))) {
      invokeSumoRestMethod -session $Session -method Delete -function "collectors/$CollectorId/sources/$SourceId"
    }
  }
}
