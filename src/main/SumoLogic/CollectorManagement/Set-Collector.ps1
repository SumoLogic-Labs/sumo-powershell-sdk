<#
.SYNOPSIS
    Collector
.DESCRIPTION
    Set collector/s info.
.EXAMPLE
    Set-Collector
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
    $org = invokeSumoWebRequest -session $Session -method Get -function "collectors/$Id"
    $etag = ([string[]]$org.Headers.ETag)[0]
    if ($Force -or $PSCmdlet.ShouldProcess("Collector[$Id] will be updated. Continue?")) {
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
