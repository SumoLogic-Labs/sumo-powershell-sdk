<#
.SYNOPSIS
Get the status of collector upgrade task

.DESCRIPTION
Get the status of collector upgrade task by Id

.PARAMETER Session
An instance of SumoAPISession which contains API endpoint and credential

.PARAMETER UpgradeId
The id of upgrade task in long

.EXAMPLE
Get-UpgradeTask -Id 78912
Get upgrade status for the task 78912 (which from the result of Start-UpgradeTask cmdlet)

.NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter

.LINK
https://help.sumologic.com/APIs/01Collector-Management-API/
#>

function Get-UpgradeTask {
  param(
    [SumoAPISession]$Session = $sumoSession,
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [alias('id')]
    [long]$UpgradeId
  )
  $upgrade = (invokeSumoRestMethod -session $Session -method Get -function "collectors/upgrades/$UpgradeId").upgrade
  if (!$upgrade) {
    Write-Error "Cannot get upgrade with id $UpgradeId"
  }
  $collector = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$($upgrade.collectorId)").collector
  if (!$collector) {
    Write-Error "Cannot get collector with id $($upgrade.collectorId)"
  }
  getCollectorUpgradeStatus -collector $collector -upgrade $upgrade
}
