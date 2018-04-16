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
        return New-Object -TypeName SumoAPISession -Property @{ Endpoint = $apiEndpoint; WebSession = $webSession}
      }
    }
    catch {
      Write-Verbose "An error occurred when calling $apiEndpoint."
    }
  }
  Write-Verbose "$err"
  return $null
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
  [System.Collections.IDictionary]$headers = $Script:defaultHeaders,
  [Microsoft.PowerShell.Commands.WebRequestMethod]$method,
  [string]$function,
  [hashtable]$content,
  $cmdlet) {

    $url = $session.Endpoint + $function
    if ($method -eq [Microsoft.PowerShell.Commands.WebRequestMethod]::Get) {
      if ($content) {
        $qStr = getQueryString($content)
        $url += "?" + $qStr
      }
      & $cmdlet -Uri $url -Headers $headers -Method $method -WebSession $session.WebSession
    }
    else {
      $url = $session.Endpoint + $function
      & $cmdlet -Uri $url -Headers $headers -Method $method -WebSession $session.WebSession -Body (ConvertTo-Json $content -Depth 10)
    }
  }

function invokeSumoWebRequest([SumoAPISession]$session,
  [System.Collections.IDictionary]$headers = $Script:defaultHeaders,
  [Microsoft.PowerShell.Commands.WebRequestMethod]$method,
  [string]$function,
  [hashtable]$content) {
    invokeSumoAPI $session $headers $method $function $content (Get-Command Invoke-WebRequest -Module Microsoft.PowerShell.Utility)
}

function invokeSumoRestMethod([SumoAPISession]$session,
  [System.Collections.IDictionary]$headers = $Script:defaultHeaders,
  [Microsoft.PowerShell.Commands.WebRequestMethod]$method,
  [string]$function,
  [hashtable]$content) {
    invokeSumoAPI $session $headers $method $function $content (Get-Command Invoke-RestMethod -Module Microsoft.PowerShell.Utility)
}

function startSearchJob ([SumoAPISession]$session, [string]$query, [datetime]$from, [datetime]$to, [string]$timeZone) {
  $fromT = getUnixTimeStamp ($from)
  $toT = getUnixTimeStamp ($to)
  $content = @{
    "query"    = $query
    "from"     = $fromT
    "to"       = $toT
    "timeZone" = $timeZone
  }
  invokeSumoRestMethod -session $session -method Post -function "search/jobs" -content $content
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
  $ret = @()
  $page = 100
  $offset = 0
  while ($offset -le $total) {
    $func = "search/jobs/{0}/{1}" -f $id, $ttype
    $res = invokeSumoRestMethod -session $session -method Get -function $func -content @{
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
      $ret += $entry.map
    }
    $text = "Downloaded {0} of {1} {2}" -f $offset, $total, $ttype
    Write-Progress -Activity "Downloading Result" -Status $text -PercentComplete ($offset / $total * 100)
    $offset += $page
  }
  $ret
}
