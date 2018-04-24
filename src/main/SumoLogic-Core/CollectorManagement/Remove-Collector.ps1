<#
.SYNOPSIS
Remove a collector

.DESCRIPTION
Remove collector from organization

.PARAMETER Session
An instance of SumoAPISession which contains API endpoint and credential

.PARAMETER Id
The id of collector in long

.EXAMPLE
Get-Collector 12345 | Remove-Collector
Remove collector with id 12345

.NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter

.LINK
https://help.sumologic.com/APIs/01Collector-Management-API/
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
    if (!$collector) {
      Write-Error "Cannot get collector with id $Id"
    }
    if ($collector -and ($Force -or $pscmdlet.ShouldProcess("Remove collector $(getFullName $collector). Continue?"))) {
      invokeSumoRestMethod -session $Session -method Delete -function "collectors/$Id"
    }
  }
}
