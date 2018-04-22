<#
.SYNOPSIS
Wait the upgrade task of collector complete

.DESCRIPTION
Wait the upgrade task to complete and return the result of upgrade

.PARAMETER Session
An instance of SumoAPISession which contains API endpoint and credential

.PARAMETER UpgradeId
The id of upgrade task in long

.EXAMPLE
Wait-UpgradeTask -Id 78912
Blocking current session until the upgrade task 78912 complete and return the result

.NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter

.LINK
https://help.sumologic.com/APIs/01Collector-Management-API/
#>

function Wait-UpgradeTask {
  param(
    [SumoAPISession]$Session = $sumoSession,
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [alias('id')]
    [long]$UpgradeId,
    [long]$RefreshMs = 500,
    [switch]$Quiet,
    [switch]$Passthru
  )
  $counter = 0
  $spinner = "|", "/", "-", "\"
  do {
    $counter++
    $upgrade = (invokeSumoRestMethod -session $Session -method Get -function "collectors/upgrades/$UpgradeId").upgrade
    if (!$upgrade) {
      Write-Error "Cannot get upgrade with id $UpgradeId"
      return
    }
    $collector = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$($upgrade.collectorId)").collector
    if (!$collector) {
      Write-Error "Cannot get collector with id $($upgrade.collectorId)"
      return
    }
    if (-not $Quiet) {
      Write-Host -NoNewLine -ForegroundColor Cyan -Object "`r$($spinner[$counter % 4]) "
      writeCollectorUpgradeStatus $collector $upgrade
    }
    Start-Sleep -Milliseconds $RefreshMs
  } while ($collector -and $upgrade -and $upgrade.status -ne 2 -and $upgrade.status -ne 3)
  
  if ($collector -and $upgrade -and $Passthru) {
    getCollectorUpgradeStatus -collector $collector -upgrade $upgrade
  }
}
