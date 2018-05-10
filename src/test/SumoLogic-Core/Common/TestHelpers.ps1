function dotify([hashtable]$acc, $key, $value, [string]$prefix) {
  $pk = if ($prefix) { "$prefix.$key" }  else { "$key" }
  if ($value -is [hashtable]) {
    $value.Keys | ForEach-Object { 
      dotify $acc  $_  $value.Item($_) $pk
    }
  }
  elseif ($value -is [array]) {
    for ($i = 0; $i -lt $value.Count; ++$i) {
      dotify $acc  $i $value[$i] $pk
    }
  }
  elseif ($value -is [psobject]) {
    $value.PSObject.Properties | ForEach-Object {
      dotify $acc  $_.Name  $_.Value $pk
    }
  }
  else {
    $acc[$pk] = $value    
  }
}

function convertToDotifyHash($in) {
  $res = @{}
  dotify $res "" $in $nul
  $res
}

function compareHashtables([hashtable]$lhs, [hashtable]$rhs) {
  $keys = $lhs.Keys + $rhs.Keys | Sort-Object | Select-Object -Unique
  foreach ($key in $keys) {
    if ("$($lhs[$key])" -ne "$($rhs[$key])") {
      New-Object -TypeName psobject -Property @{
        "Key"   = $key
        "Left"  = $lhs[$key]
        "Right" = $rhs[$key]
      }
    }
  }
}

function comparePSObjects($lhs, $rhs) {
  compareHashtables (convertToDotifyHash $lhs) (convertToDotifyHash $rhs)
}

function mockHttpCmdlet {
  Param(
    $Uri,
    $Headers,
    $Method,
    $WebSession,
    $Body
  )
  New-Object PSObject -Property @{
    Uri        = $Uri
    Headers    = $Headers
    Method     = $Method
    WebSession = $WebSession
    Body       = $Body
  }
}

function cleanup {
  $Script:testCollectorIds | ForEach-Object {
    try {
      Remove-Collector -Id $_ -Force
    } catch { }
  }
  $Script:testCollectorIds = @()
}

$Script:testCollectorIds = @()

function testCollector($suffix = "") {
  $obj = New-Object -TypeName psobject -Property @{
    "collectorType" = "Hosted"
    "name"          = "PowerShell_Test$suffix"
    "description"   = "An example Hosted Collector"
    "category"      = "HTTP Collection"
    "timeZone"      = "UTC"
  }
  $res = New-Collector -Collector $obj
  $res | Should Not BeNullOrEmpty
  $Script:testCollectorIds += $res.id
  $res
}

function testSource($collectorId, $suffix = "") {
  $obj = New-Object -TypeName psobject -Property @{
    "sourceType"                 = "HTTP"
    "name"                       = "Example_HTTP_Source_$suffix"
    "messagePerRequest"          = $false
    "category"                   = "logs_from_http"
    "hostName"                   = "dev-host-1"
    "automaticDateParsing"       = $true
    "multilineProcessingEnabled" = $true
    "useAutolineMatching"        = $true
    "forceTimeZone"              = $false
    "filters"                    = @(@{
        "filterType" = "Exclude"
        "name"       = "Filter keyword"
        "regexp"     = '(?s).*EventCode = (?:700|701).*Logfile = \"Directory Service\".*(?s)'
      })
    "cutoffTimestamp"            = 0
    "encoding"                   = "UTF-8"
    "pathExpression"             = "/usr/logs/collector/collector.log*"
  }
  $res = New-Source -CollectorId $collectorId -Source $obj
  $res | Should Not BeNullOrEmpty
  $res
}
