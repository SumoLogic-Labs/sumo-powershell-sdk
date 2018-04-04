function getSession($endpoint, $webSession) {
    $session = New-Object –TypeName PSObject
    $session | Add-Member –MemberType NoteProperty –Name Endpoint –Value $endpoint
    $session | Add-Member -MemberType NoteProperty -Name WebSession -Value $webSession
    $session
}

function getUnixTimeStamp([DateTime]$time) {
    $base = New-Object -TypeName DateTime -ArgumentList (1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)
    [long](($time.ToUniversalTime() - $base).TotalMilliseconds)
}

function getDotNetDateTime([long]$time) {
    $base = New-Object -TypeName DateTime -ArgumentList (1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)
    $base + [TimeSpan]::FromMilliseconds($time)
}

function debugRest($url, $method, $header, $content) {
    $temp = @"
URL: $url [$method]
Headers:
{0}
Content:
{1}
"@
    Write-Debug ($temp -f ($header | Out-String), ($content | Out-String))
}

function encodeUrl($url) {
    [System.Web.HttpUtility]::UrlEncode($url)
}

function decodeUrl($url) {
    [System.Web.HttpUtility]::UrlDecode($url)
}

function getQueryString($form) {
    $ret = ""
    foreach ($e in $form.GetEnumerator()) {
        $ret += "{0}={1}&" -f (encodeUrl $e.Name.toString()), (encodeUrl $e.Value.toString())
    }
    $ret
}

function invokeSumoWebRequest($session,
    [System.Collections.IDictionary]$headers = $Script:defaultHeaders,
    [Microsoft.PowerShell.Commands.WebRequestMethod]$method,
    $function,
    $content) {
    $url = $session.Endpoint + $function
    if ($Method -eq 'Get') {
        if ($content) {
            $url += "?" + (getQueryString $content)
        }
        debugRest $url $method $headers
        Invoke-WebRequest -Uri $url -Headers $headers -Method $method -WebSession $session.WebSession
    } else {
        $url = $session.Endpoint + $function
        debugRest $url $method $headers $content
        Invoke-WebRequest -Uri $url -Headers $headers -Method $method -WebSession $session.WebSession -Body (ConvertTo-Json $content -Depth 10)
    }
}

function invokeSumoRestMethod($session,
    [System.Collections.IDictionary]$headers = $Script:defaultHeaders,
    [Microsoft.PowerShell.Commands.WebRequestMethod]$method,
    $function,
    $content) {
    $url = $session.Endpoint + $function
    if ($Method -eq 'Get') {
        if ($content) {
            $url += "?" + (getQueryString $content)
        }
        debugRest $url $method $headers
        Invoke-RestMethod -Uri $url -Headers $headers -Method $method -WebSession $session.WebSession
    } else {
        $url = $session.Endpoint + $function
        debugRest $url $method $headers $content
        Invoke-RestMethod -Uri $url -Headers $headers -Method $method -WebSession $session.WebSession -Body (ConvertTo-Json $content -Depth 10)
    }
}

function startSearchJob ($Session, $Query, $From, $To, $TimeZone) {
    $_From = getUnixTimeStamp ($From)
    $_To = getUnixTimeStamp ($To)
    $content = @{
        'query' = $Query
        'from' = $_From
        'to' = $_To
        'timeZone' = $TimeZone
    }
    invokeSumoRestMethod -session $Session -method Post -function "search/jobs" -content $content
}

function getMessageResult ($Session, $Id, $Limit) {
    $status = invokeSumoRestMethod -session $Session -method Get -function "search/jobs/$Id"
    if ($status.state -ne "DONE GATHERING RESULTS") {
        throw "Result is not ready"
    }
    $total = $status.messageCount
    if ($Limit -and ($Limit -lt $total)) {
        $total = $Limit
    }
    $ret = @()
    $page = 100
    $offset = 0
    $type = "messages"
    while ($offset -le $total) {
        $func = "search/jobs/{0}/{1}?offset={2}&limit={3}" -f $Id, $type, $offset, $page
        $res = invokeSumoRestMethod -session $Session -method Get -function $func
        $res.messages | ForEach-Object {
            $ret += $_.map
        }
        $text = "Downloaded {0} of {1} {2}" -f $offset, $total, $type
        Write-Progress -Activity "Downloading Result" -Status $text -PercentComplete ($offset / $total * 100)
        $offset += $page
    }
    $ret
}

function getRecordResult ($Session, $Id, $Limit) {
    $status = invokeSumoRestMethod -session $Session -method Get -function "search/jobs/$Id"
    if ($status.state -ne "DONE GATHERING RESULTS") {
        throw "Result is not ready"
    }
    $total = $status.recordCount
    if ($Limit -and ($Limit -lt $total)) {
        $total = $Limit
    }
    $ret = @()
    $page = 100
    $offset = 0
    $type = "records"
    while ($offset -le $total) {
        $func = "search/jobs/{0}/{1}?offset={2}&limit={3}" -f $Id, $type, $offset, $page
        $res = invokeSumoRestMethod -session $Session -method Get -function $func
        $res.records | ForEach-Object {
            $ret += $_.map
        }
        $text = "Downloaded {0} of {1} {2}" -f $offset, $total, $type
        Write-Progress -Activity "Downloading Result" -Status $text -PercentComplete ($offset / $total * 100)
        $offset += $page
    }
    $ret
}
