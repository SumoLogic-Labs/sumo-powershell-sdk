<#
.SYNOPSIS
Get the information of collector(s) elegible for upgrading

.DESCRIPTION
Get the information of collector(s) which can be upgraded to specific version. The result can also be retrieved in pages if there are many collectors in your organization

.PARAMETER Session
An instance of SumoAPISession which contains API endpoint and credential

.PARAMETER TargetVersion
A string contains version of collector you want upgrade to. If not specified, the latest version will be used.

.PARAMETER Offset
The offset used for paging result

.PARAMETER Limit
The limit (e.g. page size) used for paging result

.EXAMPLE
Get-UpgradeableCollector
Get all collectors in current organization can be upgraded to latest version

.EXAMPLE
Get-UpgradeableCollector -TargetVersion 19.209-8
Get all collectors in current organization can be upgraded/downgraded to version 19.209-8

.EXAMPLE
Get-UpgradeableCollector -Offset 100 -Limit 50
Get all collectors in current organization can be upgraded to latest version in page; return 50 results from begin from the 100th result

.INPUTS
Not accepted

.OUTPUTS
PSObject to present collector(s) (elegible for upgrading)

.NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter

.LINK
https://help.sumologic.com/APIs/01Collector-Management-API/
#>

function Get-UpgradeableCollector {
  param(
    [SumoAPISession]$Session = $sumoSession,
    [string]$TargetVersion = $null,
    [int]$Offset,
    [int]$Limit
  )
  [hashtable]$query = @{}
  if (!$TargetVersion) {
    $TargetVersion = Get-UpgradeVersion
  }
  $query.Add("toVersion", $TargetVersion)
  if ($Limit -gt 0) {
    $query.Add("offset", $Offset)
    $query.Add("limit", $Limit)
  }
  (invokeSumoRestMethod -session $Session -method Get -function "collectors/upgrades/collectors" -query $query).collectors
}
