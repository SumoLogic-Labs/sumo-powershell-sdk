<#
.SYNOPSIS
    Source
.DESCRIPTION
    Edit sources.
.EXAMPLE
    Set-Source
#>

function Set-Source {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Medium")]
  param(
    $Session = $Script:sumoSession,
    [parameter(Mandatory = $true, ValueFromPipeline = $true)]
    $Source,
    [switch]$Passthru,
    [switch]$Force
  )
  process {
    $collectorId = $Source.collectorId
    $sourceId = $Source.id
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
      $ret = invokeSumoRestMethod -session $Session -headers $headers -method Put -function "collectors/$collectorId/sources/$sourceId" -body $json
    }
    if ($ret -and $Passthru) {
      $newSource = $ret.source
      Add-Member -InputObject $newSource -MemberType NoteProperty -Name collectorId -Value $collectorId -PassThru
    }
  }
}
