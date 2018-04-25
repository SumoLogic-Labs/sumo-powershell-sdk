<#
.SYNOPSIS
Get the collector version(s) for upgrading

.DESCRIPTION
Get the latest version string of collector from SumoLogic server and it can be used for upgrading collector in following process 

.PARAMETER Session
An instance of SumoAPISession which contains API endpoint and credential

.PARAMETER ListAvailable
If true, return a list of string with all available collector versions

.EXAMPLE
Get-UpgradeVersion
Get a string contains latest version of collector for upgrading    

.EXAMPLE
Get-UpgradeVersion -ListAvailable
Get all available versions for upgrading/downgrading in a string list

.INPUTS
Not accepted

.OUTPUTS
string (for latest upgrade version) all string array (for available upgrade versions)

.NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter

.LINK
https://help.sumologic.com/APIs/01Collector-Management-API/
#>

function Get-UpgradeVersion {
  param(
    [SumoAPISession]$Session = $sumoSession,
    [switch]$ListAvailable
  )
  process {
    $res = invokeSumoRestMethod -session $Session -method Get -function "collectors/upgrades/targets"
    if ($ListAvailable) {
      $res.targets | ForEach-Object { $_.version }
    } else {
      $res.targets | Where-Object { $_.latest } | ForEach-Object {$_.version}
    }
  }
}
