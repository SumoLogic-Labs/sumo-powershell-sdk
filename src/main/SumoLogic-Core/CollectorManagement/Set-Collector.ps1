<#
.SYNOPSIS
Update the properties of a collector

.DESCRIPTION
Update the properties of a collector with fields in PSObject

.PARAMETER Session
An instance of SumoAPISession which contains API endpoint and credential

.PARAMETER Collector
A PSObject contains collector definition

.EXAMPLE
Set-Collector -Collector $collector
Update collector with the properties in $collector

.EXAMPLE
Set-Collector -Collector $collector -Passthru
Update collector with the properties in $collector and return the updated result from server

.INPUTS
PSObject to present collector

.OUTPUTS
PSObject to present collector (if -Passthru)

.NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter
The input collector must contains a valid id field

.LINK
https://help.sumologic.com/APIs/01Collector-Management-API/
#>

function Set-Collector {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
  param(
    [SumoAPISession]$Session = $Script:sumoSession,
    [parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    [psobject]$Collector,
    [switch]$Passthru,
    [switch]$Force
  )
  process {
    $Id = $Collector.id
    $check = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$Id").collector
    if (!$check) {
      Write-Error "Cannot get collector with id $Id"
    }
    $org = invokeSumoWebRequest -session $Session -method Get -function "collectors/$Id"
    if ($org -and ($Force -or $PSCmdlet.ShouldProcess("Update collector $(getFullName $Collector). Continue?"))) {
      $etag = ([string[]]$org.Headers.ETag)[0]
      $headers = @{
        "If-Match"     = $etag
        'content-type' = 'application/json'
        'accept'       = 'application/json'
      }
      $wrapper = New-Object -TypeName psobject @{ "collector" = $Collector }
      $json = ConvertTo-Json $wrapper -Depth 10
      $res = invokeSumoRestMethod -session $Session -headers $headers -method Put -function "collectors/$Id" -body $json
    }
    if ($res -and $Passthru) {
      $res.collector
    }
  }
}
