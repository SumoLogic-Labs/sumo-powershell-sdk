<#
.SYNOPSIS
    Collector
.DESCRIPTION
    Set collector/s info.
.EXAMPLE
    Set-Collector
#>

function Set-Collector {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact="Medium")]
  param(
    $Session = $Script:sumoSession,
    [parameter(Mandatory = $true, ValueFromPipeline = $true)]
    $Collector,
    [switch]$Passthru,
    [switch]$Force = $false
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
        $res = invokeSumoRestMethod -session $Session -headers $headers -method Put -function "collectors/$Id" -content $target
      }
      if ($res -and $Passthru) {
        $res.collector
      }
    }
  }
}
