<#
.SYNOPSIS
Wait the upgrade task of collector complete

.DESCRIPTION
Wait the upgrade task to complete and return the result of upgrade

.PARAMETER Session
An instance of SumoAPISession which contains API endpoint and credential

.PARAMETER UpgradeId
The id of upgrade task in long

.PARAMETER RefreshMs
The interval of refreshing status in milliseconds, default is 500

.PARAMETER Quiet
If set, the status of upgrade will not be printed on console

.EXAMPLE
Wait-UpgradeTask -Id 78912
Blocking current session until the upgrade task 78912 complete and return the result

.EXAMPLE
Start-UpgradeTask -CollectorId 12345 -Version 19.216-22 | Wait-UpgradeTask
Submit upgrade request on collector 12345 to version 19.216-22 and wait it complete

.EXAMPLE
Get-UpgradeableCollector | Start-UpgradeTask | Wait-UpgradeTask
Submit upgrade requests on all available collectors to latest version and wait them complete

.INPUTS
PSObject to present collector upgrade task(s)

.OUTPUTS
PSObject to present collector upgrade task(s)

.NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter

.LINK
https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/Wait-UpgradeTask.md

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
    [switch]$Quiet
  )
  begin {
    $ids = @()
  }
  process {
    $ids += $UpgradeId
  }
  end {
    if ($ids.Count -eq 1) {
      waitForSingleUpgrade -Session $Session -UpgradeId $ids[0] -RefreshMs $RefreshMs -$Quiet $Quiet
    } else {
      waitForMultipleUpgrades -Session $Session -UpgradeIds $ids -RefreshMs $RefreshMs -$Quiet $Quiet
    }
    $ids | ForEach-Object {
      Get-UpgradeTask -Session $Session -UpgradeId $_
    }
  }  
}
