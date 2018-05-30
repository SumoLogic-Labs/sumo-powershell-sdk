<#
.SYNOPSIS
Start a collector upgrade task request

.DESCRIPTION
Start a collector upgrade task to upgrade collector(s) to another version

.PARAMETER Session
An instance of SumoAPISession which contains API endpoint and credential

.PARAMETER CollectorId
The id of collector in long

.PARAMETER Version
A string contains collector version want upgrade/downgrade to

.PARAMETER Force
Do not confirm before running

.EXAMPLE
Start-UpgradeTask -CollectorId 12345 -ToVersion 19.208-19
Submit a collector upgrade task request for upgrading collector with id 12345 to version 19.209-19

.EXAMPLE
Get-UpgradeableCollector | Start-UpgradeTask
Submit upgrade tasks for upgrading all collectors in current orgnization to latest version

.INPUTS
PSObject to present collector

.OUTPUTS
PSObject to present collector upgrade task

.NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter

.LINK
https://github.com/SumoLogic/sumo-powershell-sdk/blob/master/docs/Start-UpgradeTask.md

.LINK
https://help.sumologic.com/APIs/01Collector-Management-API/
#>

function Start-UpgradeTask {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
  param(
    [SumoAPISession]$Session = $sumoSession,
    [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [alias('id')]
    [long]$CollectorId,
    [parameter(Position = 1)]
    [string]$Version,
    [switch]$Force
  )
  process {
    $collector = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$CollectorId").collector
    if (!$collector) {
      Write-Error "Cannot get collector with id $CollectorId"
    }
    if ($collector -and ($Force -or $pscmdlet.ShouldProcess("Upgrade collector $(getFullName $collector) to versoin $Version. Continue?"))) {
      $body = @{
        "collectorId" = $CollectorId
        "toVersion" = $Version
      } | ConvertTo-Json
      $upgradeId = (invokeSumoRestMethod -session $Session -method Post -function "collectors/upgrades" -body $body).id
      $upgrade = (invokeSumoRestMethod -session $Session -method Get -function "collectors/upgrades/$UpgradeId").upgrade
      getCollectorUpgradeStatus -collector $collector -upgrade $upgrade
    }
  }
}
