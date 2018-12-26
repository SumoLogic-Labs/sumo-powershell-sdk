$Script:defaultHeaders = @{
  "content-type" = "application/json"
  "accept"       = "application/json"
}

$Script:apiEndpoints = @(
  "https://api.au.sumologic.com/api/v1/"
  "https://api.de.sumologic.com/api/v1/"
  "https://api.eu.sumologic.com/api/v1/"
  "https://api.jp.sumologic.com/api/v1/"
  "https://api.sumologic.com/api/v1/"
  "https://api.us2.sumologic.com/api/v1/"
)

function getSession([System.Management.Automation.PSCredential]$credential) {
  if ($env:SUMOLOGIC_API_ENDPOINT) {
    $apiEndpoints = @($env:SUMOLOGIC_API_ENDPOINT) + $apiEndpoints
  }
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
  $err | ForEach-Object { Write-Verbose $_ }
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
  if ($method -ne [Microsoft.PowerShell.Commands.WebRequestMethod]::Get) {
    Write-Verbose "Cmdlet:: $cmdlet"
    Write-Verbose "Headers: $headers"
    Write-Verbose "Method: $method"
    Write-Verbose "WebSession: ${session.WebSession}"
    Write-Verbose "Body: $body"
    & $cmdlet -Uri $url -Headers $headers -Method $method -WebSession $session.WebSession -Body $body -ErrorVariable err
  }
  else {
    & $cmdlet -Uri $url -Headers $headers -Method $method -WebSession $session.WebSession -ErrorVariable err
  }
  if ($err) {
    $err | ForEach-Object { Write-Error $_ }
  }
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

function getCollectorsByPage([SumoAPISession]$session, [int]$offset, [int]$limit) {
  $query = @{
    'offset' = $offset
    'limit'  = $limit
  }
  try {
    (invokeSumoRestMethod -session $Session -method Get -function "collectors" -query $query).collectors
  }
  catch {
    @()
  }
}

function getAllCollectors([SumoAPISession]$session) {
  $res = @()
  $limit = 1000
  $offset = 0
  do {
    $text = "Processing {0} to {1} collectors" -f $offset, ($offset + $limit)
    Write-Progress -Activity "Query collectors" -Status $text -PercentComplete -1
    $set = getCollectorsByPage -session $session -offset $offset -limit $limit
    $res += $set
    $offset += $limit
  } while ($set.count -gt 0)
  $res
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
  invokeSumoRestMethod -session $session -method Post -function "search/jobs" -body ($q | ConvertTo-Json)
}

function getSearchResult ([SumoAPISession]$session, [string]$id, [int]$limit, [SumoSearchResultType]$type, [int]$page) {
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
  [array]$results = @()
  while ($results.Count -lt $total) {
    $func = "search/jobs/{0}/{1}" -f $id, $ttype
    $lowerBound = $results.Count
    $upperBound = if ($results.Count + $page -lt $total) {
      $results.Count + $page
    }
    else {
      $total
    }
    Write-Verbose "Requesting result $lowerBound - $upperBound ..."
    $res = invokeSumoRestMethod -session $session -method Get -function $func -query @{
      offset = $lowerBound
      limit  = ($upperBound - $lowerBound)
    }
    if ([SumoSearchResultType]::Record -eq $type) {
      $set = $res.records
    }
    else {
      $set = $res.messages
    }
    $set | ForEach-Object {
      $results += $_.map
    }
    Write-Verbose "Got $($set.Count) results (Total: $($results.Count))"
    if ($total -ne 0 -and $results.Count -lt $total) {
      $text = "Downloaded {0} of {1} {2}" -f $results.Count, $total, $ttype
      Write-Progress -Activity "Downloading Result" -Status $text -PercentComplete ($results.Count * 100 / $total)
    }
  }
  $results
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
  }
  else {
    "(connection lost) " | Write-Host -NoNewline -ForegroundColor Red
  }
  if ((get-host).UI.RawUI.MaxWindowSize.Width -ge 150) {
    "on $($collector.osName)($($collector.osVersion)) $($collector.collectorVersion)=>$($upgrade.toVersion); " | Write-Host -NoNewline -ForegroundColor Gray
  }
  "STATUS: " | Write-Host -NoNewline -ForegroundColor White
  switch ($upgrade.status) {
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
      getStatusMessage $upgrade | Write-Host -NoNewline -ForegroundColor Cyan
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
  $lastSeenAlive = $collector.lastSeenAlive
  Add-Member -InputObject $upgrade -MemberType NoteProperty -Name lastHeartbeat -Value (getDotNetDateTime $lastSeenAlive)
  $message = getStatusMessage $upgrade
  $upgrade.PSObject.Properties.Remove("message")
  Add-Member -InputObject $upgrade -MemberType NoteProperty -Name message -Value $message
  $upgrade
}

function getStatusMessage($upgrade) {
  switch ($upgrade.status) {
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

function waitForSingleUpgrade([SumoAPISession]$Session, [long]$UpgradeId, [long]$RefreshMs, [switch]$Quiet) {
  $counter = 0
  $spinner = "|", "/", "-", "\"
  do {
    $counter++
    $upgrade = (invokeSumoRestMethod -session $Session -method Get -function "collectors/upgrades/$UpgradeId").upgrade
    if (!$upgrade) {
      Write-Error "Cannot get upgrade with id $UpgradeId"
      return
    }
    $collector = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$($upgrade.collectorId)").collector
    if (!$collector) {
      Write-Error "Cannot get collector with id $($upgrade.collectorId)"
      return
    }
    if (-not $Quiet) {
      Write-Host -NoNewLine -ForegroundColor Cyan -Object "`r$($spinner[$counter % 4]) "
      writeCollectorUpgradeStatus $collector $upgrade
    }
    Start-Sleep -Milliseconds $RefreshMs
  } while ($collector -and $upgrade -and $upgrade.status -ne 2 -and $upgrade.status -ne 3)
}

function waitForMultipleUpgrades([SumoAPISession]$Session, [array]$UpgradeIds, [long]$RefreshMs, [switch]$Quiet) {
  [array]$completed = @()
  $counter = 0
  $succeed = 0
  $failed = 0
  $na = 0
  $spinner = "|", "/", "-", "\"
  do {
    $counter++
    foreach ($upgradeId in $UpgradeIds) {
      if ($completed -contains $upgradeId) {
        continue
      }
      $upgrade = (invokeSumoRestMethod -session $Session -method Get -function "collectors/upgrades/$upgradeId").upgrade
      if (!$upgrade) {
        Write-Warning "Cannot get upgrade with id $upgradeId"
        $completed += $upgradeId
        $na++
      }
      elseif ($upgrade.status -eq 2) {
        $completed += $upgradeId
        $succeed++
      }
      elseif ($upgrade.status -eq 3) {
        $completed += $upgradeId
        $failed++
      }
    }
    if (-not $Quiet) {
      Write-Host -NoNewLine -ForegroundColor Cyan -Object "`r$($spinner[$counter % 4]) "
      "Upgrade STATUS - Total: " | Write-Host -NoNewLine -ForegroundColor Gray
      $UpgradeIds.Count | Write-Host -NoNewLine -ForegroundColor White
      " - Running: " | Write-Host -NoNewLine -ForegroundColor Gray
      $UpgradeIds.Count - $failed - $succeed - $na | Write-Host -NoNewLine -ForegroundColor Cyan
      ", Succeed: " | Write-Host -NoNewLine -ForegroundColor Gray
      $succeed | Write-Host -NoNewLine -ForegroundColor Green
      ", Failed: " | Write-Host -NoNewLine -ForegroundColor Gray
      $failed | Write-Host -NoNewLine -ForegroundColor Red
      ", N/A: " | Write-Host -NoNewLine -ForegroundColor Gray
      "$na      " | Write-Host -NoNewLine -ForegroundColor Yellow
    }
    Start-Sleep -Milliseconds $RefreshMs
  } while ($completed.Length -lt $UpgradeIds.Length)
}