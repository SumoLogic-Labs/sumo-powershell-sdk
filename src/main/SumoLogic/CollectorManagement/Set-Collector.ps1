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
    $Collector | ForEach-Object {
      $Id = $_.id
      $org = invokeSumoWebRequest -session $Session -method Get -function "collectors/$Id"
      $etag = $org.Headers.ETag
      $headers = @{
        "If-Match"     = $etag[0]
        'content-type' = 'application/json'
        'accept'       = 'application/json'
      }
      $target = ConvertFrom-Json $org.Content
      $target.collector = $_
      if ($Force -or $PSCmdlet.ShouldProcess("Collector[$Id] will be updated. Continue?")) {
        $res = invokeSumoRestMethod -session $Session -headers $headers -method Put -function "collectors/$Id" -body (ConvertTo-Json $target -Depth 10)
      }
      if ($res -and $Passthru) {
        $res.collector
      }
    }
  }
}
