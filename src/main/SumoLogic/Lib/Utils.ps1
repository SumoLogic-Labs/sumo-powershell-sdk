$Script:defaultHeaders = @{
  "content-type" = "application/json"
  "accept"       = "application/json"
}

$Script:apiEndpoints = @(
  "https://api.sumologic.com/api/v1/"
  "https://api.us2.sumologic.com/api/v1/"
  "https://api.au.sumologic.com/api/v1/"
  "https://api.eu.sumologic.com/api/v1/"
  "https://api.de.sumologic.com/api/v1/"
)

function getSession([System.Management.Automation.PSCredential]$credential) {
  foreach ($apiEndpoint in $apiEndpoints) {
    $url = $apiEndpoint + "collectors?limit=1"
    try {
      $res = Invoke-RestMethod -Uri $url -Headers $defaultHeaders -Method Get `
        -Credential $credential -SessionVariable webSession -ErrorAction SilentlyContinue -ErrorVariable err
      if ($res) {
        return [SumoAPISession]::new($apiEndpoint, $webSession)
      }
    }
    catch {
      Write-Verbose "An error occurred when calling $apiEndpoint."
    }
  }
  $err | ForEach-Object { Write-Error $_ }
} 
function getHex([long]$id) {
  "{0:X16}" -f $id
}

function getFullName([psobject]$obj) {
  "'{0}'[{1}]" -f $obj.name, (getHex $obj.id)
}

function urlEncode([string]$str) {
  [System.Web.HttpUtility]::UrlEncode($str)
}

function urlDecode([string]$str) {
  [System.Web.HttpUtility]::UrlDecode($str)
}

function getQueryString([hashtable]$form) {
  $sections = $form.GetEnumerator() | Sort-Object -Property Name | ForEach-Object { 
    "{0}={1}" -f (urlEncode($_.Name)), (urlEncode($_.Value)) 
  }
  $sections -join "&"
}

function getUnixTimeStamp([datetime]$time) {
  $base = New-Object -TypeName DateTime -ArgumentList (1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)
  [long](($time.ToUniversalTime() - $base).TotalMilliseconds)
}

function getDotNetDateTime([long]$time) {
  $base = New-Object -TypeName DateTime -ArgumentList (1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)
  $base + [TimeSpan]::FromMilliseconds($time)
}

function invokeSumoAPI([SumoAPISession]$session,
  [hashtable]$headers = $Script:defaultHeaders,
  [Microsoft.PowerShell.Commands.WebRequestMethod]$method,
  [string]$function,
  [hashtable]$query,
  [string]$body,
  $cmdlet) {

    $url = $session.Endpoint + $function
    if ($query) {
      $qStr = getQueryString($query)
      $url += "?" + $qStr
    }
    & $cmdlet -Uri $url -Headers $headers -Method $method -WebSession $session.WebSession -Body $body -ErrorVariable err
    $err | ForEach-Object { Write-Error $_ }
  }

function invokeSumoWebRequest([SumoAPISession]$session,
  [hashtable]$headers = $Script:defaultHeaders,
  [Microsoft.PowerShell.Commands.WebRequestMethod]$method,
  [string]$function,
  [hashtable]$query,
  [string]$body) {
    invokeSumoAPI $session $headers $method $function $query $body (Get-Command Invoke-WebRequest -Module Microsoft.PowerShell.Utility)
}

function invokeSumoRestMethod([SumoAPISession]$session,
  [hashtable]$headers = $Script:defaultHeaders,
  [Microsoft.PowerShell.Commands.WebRequestMethod]$method,
  [string]$function,
  [hashtable]$query,
  [string]$body) {
    invokeSumoAPI $session $headers $method $function $query $body (Get-Command Invoke-RestMethod -Module Microsoft.PowerShell.Utility)
}

function startSearchJob ([SumoAPISession]$session, [string]$query, [datetime]$from, [datetime]$to, [string]$timeZone) {
  $fromT = getUnixTimeStamp ($from)
  $toT = getUnixTimeStamp ($to)
  $q = @{
    "query"    = $query
    "from"     = $fromT
    "to"       = $toT
    "timeZone" = $timeZone
  }
  invokeSumoRestMethod -session $session -method Post -function "search/jobs" -query $q
}

function getSearchResult ([SumoAPISession]$session, [string]$id, [int]$limit, [SumoSearchResultType]$type) {
  $status = invokeSumoRestMethod -session $session -method Get -function "search/jobs/$id"
  if ($status.state -ne "DONE GATHERING RESULTS") {
    throw "Result is not ready"
  }
  if ([SumoSearchResultType]::Record -eq $type) {
    $ttype = "records"
    $total = $status.recordCount
  }
  else {
    $ttype = "messages"
    $total = $status.messageCount
  }
  if ($limit -and ($limit -lt $total)) {
    $total = $limit
  }
  $res = @()
  $page = 100
  $offset = 0
  while ($offset -le $total) {
    $func = "search/jobs/{0}/{1}" -f $id, $ttype
    $res = invokeSumoRestMethod -session $session -method Get -function $func -query @{
      "offset" = $offset
      "limit" = $page
    }
    if ([SumoSearchResultType]::Record -eq $type) {
      $set = $res.records
    }
    else {
      $set = $res.messages
    }
    foreach ($entry in $set) {
      $res += $entry.map
    }
    $text = "Downloaded {0} of {1} {2}" -f $offset, $total, $ttype
    Write-Progress -Activity "Downloading Result" -Status $text -PercentComplete ($offset / $total * 100)
    $offset += $page
  }
  $res
}

function convertCollectorToJson([psobject]$collector) {
  if (!($collector.collectorType -and $collector.collectorType -ieq "Hosted")) {
    throw "Only hosted collector can be created though API"
  }
  $validProperties = @(
    "collectorType",
    "name",
    "description",
    "category",
    "timeZone"
  )
  $propNames = $collector.PSObject.Properties | ForEach-Object { $_.Name }
  $propNames | ForEach-Object {
    if (!($_ -in $validProperties)) {
      Write-Verbose "Property [$_] in input collector is removed."
      $collector.PSObject.Properties.Remove($_)
    }
  }
  $wrapper = New-Object -TypeName psobject @{ "collector" = $collector }
  ConvertTo-Json $wrapper -Depth 10
}

function convertSourceToJson([psobject]$source) {
  $removeProperties = @(
    "collectorId",
    "id",
    "alive"
  )
  $propNames = $source.PSObject.Properties | ForEach-Object { $_.Name }
  $propNames | ForEach-Object {
    if ($_ -in $removeProperties) {
      Write-Verbose "Property [$_] in input source is removed."
      $source.PSObject.Properties.Remove($_)
    }
  }
  $wrapper = New-Object -TypeName psobject @{ "source" = $source }
  ConvertTo-Json $wrapper -Depth 10
}

function writeCollectorUpgradeStatus($collector, $upgrade) {
  getFullName $collector | Write-Host -NoNewline -ForegroundColor White
  if ($collector.alive) {
    "(alive) " | Write-Host -NoNewline -ForegroundColor Green
  } else {
    "(connection lost) " | Write-Host -NoNewline -ForegroundColor Red
  }
  if ((get-host).UI.RawUI.MaxWindowSize.Width -ge 150) {
    "on $($collector.osName)($($collector.osVersion)) $($collector.collectorVersion)=>$($upgrade.toVersion); " | Write-Host -NoNewline -ForegroundColor Gray
  }
  "STATUS: " | Write-Host -NoNewline -ForegroundColor White
  switch($upgrade.status) {
    0 {
      getStatusMessage $upgrade | Write-Host -NoNewline -ForegroundColor White
    }
    1 {
      getStatusMessage $upgrade | Write-Host -NoNewline -ForegroundColor Blue
    }
    2 {
      getStatusMessage $upgrade | Write-Host -NoNewline -ForegroundColor Green
    }
    3 {
      getStatusMessage $upgrade | Write-Host -NoNewline -ForegroundColor Red
    }
    6 {
      getStatusMessage $upgrade | Write-Host -NoNewline -ForegroundColor DarkBlue
    }
  }
}

function getCollectorUpgradeStatus($collector, $upgrade) {
  Add-Member -InputObject $upgrade -MemberType NoteProperty -Name collectorName -Value $collector.name
  Add-Member -InputObject $upgrade -MemberType NoteProperty -Name osName -Value $collector.osName
  Add-Member -InputObject $upgrade -MemberType NoteProperty -Name osVersion -Value $collector.osVersion
  Add-Member -InputObject $upgrade -MemberType NoteProperty -Name collectorVersion -Value $collector.collectorVersion
  Add-Member -InputObject $upgrade -MemberType NoteProperty -Name alive -Value $collector.alive
  $requestTime = $upgrade.requestTime
  $upgrade.PSObject.Properties.Remove("requestTime")
  Add-Member -InputObject $upgrade -MemberType NoteProperty -Name requestTime -Value (getDotNetDateTime $requestTime)
  $message = getStatusMessage $upgrade
  $upgrade.PSObject.Properties.Remove("message")
  Add-Member -InputObject $upgrade -MemberType NoteProperty -Name message -Value $message
  $upgrade
}

function getStatusMessage($upgrade) {
  switch($upgrade.status) {
    0 {
      "Not started"
    }
    1 {
      "Preparing to upgrade collector"
    }
    2 {
      "Upgrade completed and success "
    }
    3 {
      "Upgrade failed ($($upgrade.message))"
    }
    6 {
     "Working on upgrade collector   "
    }
  }
}
