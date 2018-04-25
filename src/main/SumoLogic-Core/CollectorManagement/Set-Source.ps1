<#
.SYNOPSIS
Update the configuration of a source

.DESCRIPTION
Update the configuration of a source with fields in PSObject

.PARAMETER Session
An instance of SumoAPISession which contains API endpoint and credential

.PARAMETER Source
A PSObject contains source definition

.EXAMPLE
Set-Source -Source $source
Update source with the properties in $source

.EXAMPLE
Set-Source -Source $source -Passthru
Update source with the properties in $source and return the updated result from server

.INPUTS
PSObject to present source

.OUTPUTS
PSObject to present source (if -Passthru)

.NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter
The input collector must contains a valid id field

.LINK
https://help.sumologic.com/APIs/01Collector-Management-API/
#>

function Set-Source {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
  param(
    [SumoAPISession]$Session = $Script:sumoSession,
    [parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    $Source,
    [switch]$Passthru,
    [switch]$Force
  )
  process {
    $collectorId = $Source.collectorId
    $sourceId = $Source.id
    $collector = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$collectorId").collector
    if (!$collector) {
      Write-Error "Cannot get collector with id $collectorId"
    }
    $org = invokeSumoWebRequest -session $Session -method Get -function "collectors/$collectorId/sources/$sourceId"
    if ($org -and ($Force -or $PSCmdlet.ShouldProcess("Update source $(getFullName $source) in collector $(getFullName $collector). Continue?"))) {
      $etag = ([string[]]$org.Headers.ETag)[0]
      $headers = @{
        "If-Match"     = $etag
        'content-type' = 'application/json'
        'accept'       = 'application/json'
      }
      $wrapper = New-Object -TypeName psobject @{ "source" = $Source }
      $json = ConvertTo-Json $wrapper -Depth 10
      $res = invokeSumoRestMethod -session $Session -headers $headers -method Put -function "collectors/$collectorId/sources/$sourceId" -body $json
    }
    if ($res -and $Passthru) {
      $newSource = $res.source
      Add-Member -InputObject $newSource -MemberType NoteProperty -Name collectorId -Value $collectorId -PassThru
    }
  }
}
