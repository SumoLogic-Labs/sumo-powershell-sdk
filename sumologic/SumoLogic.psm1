#### Global Definitions #####################################################################################################
Add-Type -TypeDefinition @"
   public enum SumoDeployment
   {
       Prod,
       Sydney,
       Dublin,
       US2
   }
"@

Add-Type -TypeDefinition @"
   public enum SumoSearchResultType
   {
       Message,
       Record
   }
"@

$Script:defaultHeaders = @{
    'content-type' = 'application/json'
    'accept' = 'application/json'
}

$Script:apiPoints = @{
    [SumoDeployment]::Prod = 'https://api.sumologic.com/api/v1/'
    [SumoDeployment]::Sydney = 'https://api.au.sumologic.com/api/v1/'
    [SumoDeployment]::Dublin = 'https://api.eu.sumologic.com/api/v1/'
    [SumoDeployment]::US2 = 'https://api.us2.sumologic.com/api/v1/'
}

$Script:sumoSesion = $null

# TLS 1.1+ is not enabled by default in Windows PowerShell, but it is
# required to communicate with the Sumo Logic API service.
# Enable it if needed
if ([System.Net.ServicePointManager]::SecurityProtocol -ne [System.Net.SecurityProtocolType]::SystemDefault) {
    Write-Warning "Enabling TLS 1.2 usage via [System.Net.ServicePointManager]::SecurityProtocol"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
}

#### Private Helpers #####################################################################################################

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
            $ret +=$_.map
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
            $ret +=$_.map
        }
        $text = "Downloaded {0} of {1} {2}" -f $offset, $total, $type
        Write-Progress -Activity "Downloading Result" -Status $text -PercentComplete ($offset / $total * 100)
        $offset += $page
    }
    $ret
}

#### Public Cmdlets #####################################################################################################


function New-SumoSession {
    [CmdletBinding()]
    param(
    [parameter(Mandatory = $true, Position = 0)]
    [SumoDeployment]$Deployment,
    [parameter(ParameterSetName = "ByPSCredential", Mandatory = $true, ValueFromPipeline = $true)]
    [PSCredential]$Credential,
    [parameter(ParameterSetName = "ByAccessKey", Mandatory = $true)]
    [string]$AccessId,
    [parameter(ParameterSetName = "ByAccessKey", Mandatory = $true)]
    [string]$AccessKey
    )
    process {
        $endpoint = $Script:apiPoints[$Deployment]
        if ("ByAccessKey" -eq $PSCmdlet.ParameterSetName) {
            $secpasswd = ConvertTo-SecureString $AccessKey -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ($AccessId, $secpasswd)
        }
        $url = $endpoint + "collectors?offset=0&limit=1"
        $res = Invoke-WebRequest -Uri $url -Headers $Script:headers -Method Get `
            -Credential $Credential -SessionVariable webSession
        if ($res.StatusCode -eq 200) {
            $session = getSession $endpoint $webSession $res
            $session
        } else {
            $null
        }
    }
    end {
        $Script:sumoSession = $session
    }
}

function Get-Collector {
    [CmdletBinding(DefaultParameterSetName = "ById")]
    param(
    $Session = $Script:sumoSession,
    [parameter(ParameterSetName = "ById", Position = 0)]
    [long]$Id,
    [parameter(ParameterSetName = "ByName")]
    [string]$NamePattern,
    [parameter(ParameterSetName = "ByPage", Mandatory = $true)]
    [int]$Offset,
    [parameter(ParameterSetName = "ByPage", Mandatory = $true)]
    [int]$Limit,

    # simple filtering params. These are applied optionally on top of parameterset ById,ByName etc
    [parameter(Mandatory = $false)][String][ValidateSet("Json", "UI")] $sourceSyncMode,
    [parameter(Mandatory = $false)][string][ValidateSet("Hosted", "Installable")] $collectorType,

    # fiter by a one or more other properties supplied as a hashtable
    [parameter(Mandatory = $false)] [Hashtable]$FilterProperties 
    )
    process {
        switch ($PSCmdlet.ParameterSetName) {
            "ById" { 
                if (-not ($Id)) {
                    $ret = (invokeSumoRestMethod -session $Session -method Get -function "collectors").collectors
                } else {
                    $ret = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$Id").collector
                }
            } 
            "ByName" {
                $ret = (invokeSumoRestMethod -session $Session -method Get -function "collectors").collectors | where { $_.name -match [regex]$NamePattern }
            }
            "ByPage" {
                $body = @{
                    'offset' = $Offset
                    'limit' = $Limit
                }
                $ret = (invokeSumoRestMethod -session $Session -method Get -function "collectors" -content $body).collectors
            }
        }

        Write-Verbose "Returned $($ret.Count) collectors before filtering"

        if ($sourceSyncMode) {
            Write-Verbose "filter on sourceSyncMode -eq $sourceSyncMode"
            $ret = $ret | Where-Object { $_.sourceSyncMode -eq $sourceSyncMode }
        }

        if ($collectorType) {
            Write-Verbose "filter on collectorType -eq $collectorType"
            $ret = $ret | Where-Object { $_.collectorType -eq $collectorType }
        }

        if ($FilterProperties ) {
            
            foreach ($key in $FilterProperties.Keys) {
                Write-Verbose "filter on FilterProperties property: $key -eq $($FilterProperties[$key]) "
                $ret = $ret | Where-Object { $_.$key -eq $FilterProperties[$key] }
            }
            
        }
        
        Write-Verbose "There are $($ret.Count) collectors after filtering"

        $ret
    }
}

function Set-Collector {
    param(
    $Session = $Script:sumoSession,
    [parameter(Mandatory = $true, ValueFromPipeline = $true)]
    $Collector,
    [switch]$Passthru
    )
    process {
        $Collector | ForEach-Object {
            $Id = $_.id
            $org = invokeSumoWebRequest -session $Session -method Get -function "collectors/$Id"
            $etag = $org.Headers.ETag
            $headers = @{
                "If-Match" = $etag[0]
                'content-type' = 'application/json'
                'accept' = 'application/json'
            }
            $target = ConvertFrom-Json $org.Content
            $target.collector = $_
            $res = invokeSumoRestMethod -session $Session -headers $headers -method Put -function "collectors/$Id" -content $target
            if ($res -and $Passthru) {
                ($res.collector)
            }
        }
    }
}

function Remove-Collector {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    param(
    $Session = $Script:sumoSession,
    [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [long]$Id,
    [switch]$Force
    )
    process {
        $Id | ForEach-Object {
            if ($Force -or $pscmdlet.ShouldProcess("Collector[$_]")) {
                invokeSumoRestMethod -session $Session -method Delete -function "collectors/$_"
            }
        }
    }
}

function Get-Source {
    [CmdletBinding(DefaultParameterSetName = "ById")]
    param(
    $Session = $Script:sumoSession,
    [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [alias('id')]
    [long]$CollectorId,
    [parameter(ParameterSetName = "ById", Position = 0)]
    [long]$SourceId,
    [parameter(ParameterSetName = "ByName")]
    [string]$NamePattern,
    [parameter(ParameterSetName = "ByPage", Mandatory = $true)]
    [int]$Offset,
    [parameter(ParameterSetName = "ByPage", Mandatory = $true)]
    [int]$Limit
    )
    process {
        foreach ($cid in $CollectorId) {
            switch ($PSCmdlet.ParameterSetName) {
                "ById" {
                   if (-not ($SourceId)) {
                        $ret = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$cid/sources").sources
                    } else {
                        $ret = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$cid/sources/$SourceId").source
                    }
                }
                "ByName" {
                    $ret = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$cid/sources").sources | where { $_.name -match [regex]$NamePattern }
                }
                "ByPage" {
                    $body = @{
                        'offset' = $Offset
                        'limit' = $Limit
                    }
                    $ret = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$cid/sources" -content $body).sources
                }
    
            }
            if ($ret) {
                $ret | ForEach-Object {
                    Add-Member -InputObject $_ -MemberType NoteProperty -Name collectorId -Value $cid
                }
            }
            $ret
        }
    }
}

function Set-Source {
    [CmdletBinding()]
    param(
    $Session = $Script:sumoSession,
    [parameter(Mandatory = $true, ValueFromPipeline = $true)]
    $Source,
    [switch]$Passthru
    )
    process {
        $collectorId = $Source.collectorId
        $sourceId = $Source.id
        $org = invokeSumoWebRequest -session $Session -method Get -function "collectors/$collectorId/sources/$sourceId"
        $etag = $org.Headers.ETag
        $headers = @{
            "If-Match" = $etag[0]
            'content-type' = 'application/json'
            'accept' = 'application/json'
        }
        $target = ConvertFrom-Json $org.Content
        $target.source = $Source
        $res = invokeSumoRestMethod -session $Session -headers $headers -method Put -function "collectors/$collectorId/sources/$sourceId" -content $target
        if ($res -and $Passthru) {
            ($res.source)
        }
    }
}

function Remove-Source {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
    param(
    $Session = $Script:sumoSession,
    [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [long]$CollectorId,
    [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [alias("id")]
    [long]$SourcId,
    [switch]$Force
    )
    process {
        $SourcId | ForEach-Object {
            if ($Force -or $pscmdlet.ShouldProcess("Collector[$CollectorId] Source[$_]")) {
                invokeSumoRestMethod -session $Session -method Delete -function "collectors/$CollectorId/sources/$_"
            }
        }
    }
}

function Start-SearchJob {
    [CmdletBinding(DefaultParameterSetName = "ByLast")]
    param(
    $Session = $Script:sumoSession,
    [parameter(Position = 0)]
    [string]$Query,
    [parameter(ParameterSetName = "ByLast")]
    [TimeSpan]$Last = [TimeSpan]::FromMinutes(15),
    [parameter(ParameterSetName = "ByTimeRange", Mandatory = $true)]
    [DateTime]$From,
    [parameter(ParameterSetName = "ByTimeRange", Mandatory = $true)]
    [DateTime]$To,
    [parameter(ParameterSetName = "ByTimeRange")]
    [string]$TimeZone = "UTC"
    )
    if  ("ByLast" -eq $PSCmdlet.ParameterSetName) {
        $utcNow = [DateTime]::NoW.ToUniversalTime()
        $From = $utcNow - $Last
        $To = $utcNow
        $TimeZone = "UTC"
    }
    if ($To -le $From) {
        throw "Time range [$From to $To] is illegal"
    }
    $job = startSearchJob -Session $Session -Query $Query -From $From -To $To -TimeZone $TimeZone
    if (!$job) {
        throw "Job creation fail"
    }
    $totalMs = ($To - $From).TotalMilliseconds
    $title = “Query [{0}], Gathering Result” -f $Query
    $On = $To
    while ((!$status) -or $status.state -ne "DONE GATHERING RESULTS") {
        $status = invokeSumoRestMethod -session $Session -method Get -function ("search/jobs/" + $job.id)
        if ((!$status) -or $status.state -eq "CANCELLED") {
            throw "Job was cancelled"
        }
        if ($status.histogramBuckets) {
            $On = getDotNetDateTime ($status.histogramBuckets[$status.histogramBuckets.Count - 1].startTimestamp)
        }
        $processedMs = ($To - $On).TotalMilliseconds
        $text = "Processed records for last {0} of {1} minutes. Found {2} messages, {3} records" -f [long]($To - $On).TotalMinutes, [long]($To - $From).TotalMinutes, $status.messageCount, $status.recordCount
        Write-Progress -Activity $title -Status $text -PercentComplete ($processedMs / $totalMs * 100)
        Start-Sleep 1
    }
    $job
}
    
function Get-SearchResult {
    [CmdletBinding()]
    param(
    $Session = $Script:sumoSession,
    [parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
    $Id,
    [SumoSearchResultType]$Type = [SumoSearchResultType]::Message,
    [int]$Limit
    )
    switch ($Type) {
        "Message" {
            getMessageResult $Session $Id $Limit
        }
        "Record" {
            getRecordResult $Session $Id $Limit
        }
    }
}