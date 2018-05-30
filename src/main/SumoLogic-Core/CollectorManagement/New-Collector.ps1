<#
.SYNOPSIS
Create a hosted collector

.DESCRIPTION
Create a new hosted collector with json string or PSObject with collector definition

.PARAMETER Session
An instance of SumoAPISession which contains API endpoint and credential

.PARAMETER Collector
A PSObject contains collector definition

.PARAMETER Json
A string contains collector definition in json format

.PARAMETER Force
Do not confirm before running

.EXAMPLE
New-Collector -Collector $collector
Create a collector with the definition in $collector

.EXAMPLE
Get-Content collector.json -Raw | New-Collector
Create a collector with the definition in collector.json

.INPUTS
PSObject to present collector (for copy an existing collector) or JSON string

.OUTPUTS
PSObject to present collector(s)

.NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter
Only "Hosted" collector can be created with API

.LINK
https://github.com/SumoLogic/sumo-powershell-sdk/blob/master/docs/New-Collector.md

.LINK
https://help.sumologic.com/APIs/01Collector-Management-API/
#>

function New-Collector {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
  param(
    [SumoAPISession]$Session = $sumoSession,
    [parameter(ParameterSetName = "ByObject", ValueFromPipeline = $true, Position = 0)]
    [psobject]$Collector,
    [parameter(ParameterSetName = "ByJson", ValueFromPipeline = $true, Position = 0)]
    [string]$Json,
    [switch]$Force
  )
  process {
    switch ($PSCmdlet.ParameterSetName) {
      "ByObject" {
        $Json = convertCollectorToJson($Collector)
      }
      "ByJson" {
        $Collector = (ConvertFrom-Json $Json).collector
      }
    }
    if ($Force -or $PSCmdlet.ShouldProcess("Create $($Collector.type) collector with name $($Collector.name). Continue?")) {
      $res = invokeSumoRestMethod -session $Session -method Post -function "collectors" -body $Json
    }
    if ($res) {
      $res.collector
    }
  }
}
