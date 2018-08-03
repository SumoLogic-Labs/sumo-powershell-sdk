. $PSScriptRoot/../Common/Global.ps1
. $ModuleRoot/Lib/Definitions.ps1
. $ModuleRoot/Lib/Utils.ps1

Describe "getSession" {

  It "should get session with valid access key/id from Prod" {
    
    Mock Invoke-RestMethod { return @{collectors = @("yes")} } -ParameterFilter { $Uri -and $Uri -eq "https://api.sumologic.com/api/v1/collectors?limit=1" }
    
    $secpasswd = ConvertTo-SecureString "some-access-key" -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ("some-access-id", $secpasswd)
    $session = getSession $cred 
    
    $session | Should Not BeNullOrEmpty
    $session.Endpoint | Should Be "https://api.sumologic.com/api/v1/"
    $session.WebSession | Should Not Be BeNullOrEmpty
  }

  It "should get session with valid access key/id from US2" {
    
    Mock Invoke-RestMethod { throw "HTTP 401" } -ParameterFilter { $Uri -and $Uri -eq "https://api.sumologic.com/api/v1/collectors?limit=1" }
    Mock Invoke-RestMethod { return @{collectors = @("yes")} } -ParameterFilter { $Uri -and $Uri -eq "https://api.us2.sumologic.com/api/v1/collectors?limit=1" }
    
    $secpasswd = ConvertTo-SecureString "some-access-key" -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ("some-access-id", $secpasswd)
    $session = getSession $cred 

    $session | Should Not BeNullOrEmpty
    $session.Endpoint | Should Be "https://api.us2.sumologic.com/api/v1/"
    $session.WebSession | Should Not Be BeNullOrEmpty
  }

  It "should return null if invalid access key/id used" {
    
    Mock Invoke-RestMethod { throw "HTTP 401" } -ParameterFilter { $Uri }
    
    $secpasswd = ConvertTo-SecureString "some-access-key" -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ('some-access-id', $secpasswd)
    $session = getSession $cred
    $session | Should BeNullOrEmpty
  }
}

Describe "getHex" {
  It "should transfer long id to Hex" {
    getHex(123456) | Should Be "000000000001E240"
  }
}

Describe "getFullName" {
  It "should print name with ID" {
    $obj = New-Object -TypeName psobject -Property @{
      "id"   = 101792472
      "name" = "collector_gc"
    }
    getFullName($obj) | Should Be "'collector_gc'[0000000006113AD8]"
  }
}

Describe "urlEncode" {
  It "should encode the word to URL" {
    urlEncode ""  | Should Be ""
    urlEncode " "  | Should Be "+"
    urlEncode "+"  | Should Be "%2b"
  }
}

Describe "urlDecode" {
  It "should decode the URL to word" {
    urlDecode ""  | Should Be ""
    urlDecode "+"  | Should Be " "
    urlDecode "%20"  | Should Be " "
    urlDecode "%2b"  | Should Be "+"
  }
}

Describe "getQueryString" {
  It "should combine a hashtable into a query string serial" {
    $form = @{
      "a" = "x"
      "b" = "y"
      "c" = "&S<>"
    }
    getQueryString $form | Should Be "a=x&b=y&c=%26S%3c%3e"
  }
}

Describe "getUnixTimeStamp" {
  It "should transfer a DateTime to unix Timestamp" {
    getUnixTimeStamp("1970-01-01T00:00:00Z") | Should Be 0
    getUnixTimeStamp("1989-07-25T00:00:00Z") | Should Be 617328000000
  }
}

Describe "getDotNetDateTime" {
  It "should transfer a unix Timestamp to DataTime" {
    getDotNetDateTime(0) | Should Be (Get-Date -Date "1970-01-01T00:00:00Z").ToUniversalTime()
    getDotNetDateTime(617328000000) | Should Be (Get-Date -Date "1989-07-25T00:00:00Z").ToUniversalTime()
  }
}

Describe "invokeSumoAPI" {
  $session = [SumoAPISession]::new("https://localhost/", $null)
  $headers = @{
    "content-type" = "application/json"
    "accept"       = "application/text"
  }
  $query = @{
    "a" = "x"
    "b" = "y"
    "c" = "&S<>"
  }
  
  It "should call cmdlet with query string" {
    $res = invokeSumoAPI -session $session -headers $headers -method Get -function "foo/bar" -query $query -cmdlet (Get-Command mockHttpCmdlet)
    $res | Should Not Be BeNullOrEmpty
    $res.Headers | Should Be $headers
    $res.Method | Should Be "Get"
    $res.Uri | Should Be "https://localhost/foo/bar?a=x&b=y&c=%26S%3c%3e"
  }

  It "should call Invoke-WebRequest with payload" {
    $body = ConvertTo-Json (New-Object -TypeName psobject @{ "collector" = "my collector" })
    $res = invokeSumoAPI -session $session -headers $headers -method Post -function "foo/bar" -query $query -body $body -cmdlet (Get-Command mockHttpCmdlet)
    $res | Should Not Be BeNullOrEmpty
    $res.Headers | Should Be $headers
    $res.Method | Should Be "Post"
    $res.Uri | Should Be "https://localhost/foo/bar?a=x&b=y&c=%26S%3c%3e"
    $res.Body | Should Be $body
  }
}

Describe "invokeSumoWebRequest" {
  
  It "should call with Invoke-WebRequest" {
    
    Mock invokeSumoAPI {} -Verifiable -ParameterFilter { $cmdlet -and $cmdlet -eq (Get-Command Invoke-WebRequest -Module Microsoft.PowerShell.Utility) }

    invokeSumoWebRequest -session $null -headers @{} -method Get -function "foo/bar" -content @{}
    Assert-MockCalled invokeSumoAPI -Exactly 1 -Scope It
    invokeSumoWebRequest -session $null -headers @{} -method Post -function "foo/bar" -content @{}
    Assert-MockCalled invokeSumoAPI -Exactly 2 -Scope It
  }
}

Describe "invokeSumoRestMethod" {
  
  It "should call with Invoke-RestMethod" {

    Mock invokeSumoAPI {} -Verifiable -ParameterFilter { $cmdlet -and $cmdlet -eq (Get-Command Invoke-RestMethod -Module Microsoft.PowerShell.Utility) }

    invokeSumoRestMethod -session $session -headers @{} -method Get -function "foo/bar" -content @{}
    Assert-MockCalled invokeSumoAPI -Exactly 1 -Scope It
    invokeSumoRestMethod -session $session -headers @{} -method Post -function "foo/bar" -content @{}
    Assert-MockCalled invokeSumoAPI -Exactly 2 -Scope It
  }
}

Describe "startSearchJob" {

  It "should call invokeSumoAPI with correct parameters" {
    
    $_query = "_sourceCategory=service"
    $_from = (Get-Date "2018-08-08T00:00:00Z").AddDays(-1)
    $_to = (Get-Date "2018-08-08T00:00:00Z")
    $_timeZone = "Asia/Shanghai"

    Mock invokeSumoAPI {} -Verifiable -ParameterFilter {
      $method -eq [Microsoft.PowerShell.Commands.WebRequestMethod]::Post -and `
        $function -eq "search/jobs" -and `
        !$query -and $body -and `
        $cmdlet -eq (Get-Command Invoke-RestMethod -Module Microsoft.PowerShell.Utility) 
    }

    startSearchJob $null $_query $_from $_to $_timeZone
    Assert-MockCalled invokeSumoAPI -Exactly 1 -Scope It
  }
}

function setMockArgsForMessages($id, $count) {
  $Global:__mockArgs = @{id = $id; count = $count; ttype = "messages"}
  $Global:__mockArgs["statusTemplate"] = @'
  {
    "state":"DONE GATHERING RESULTS",
    "messageCount":COUNT,
    "histogramBuckets":[],
    "pendingErrors":[],
    "pendingWarnings":[]
  }
'@.Replace("COUNT", $count)
  $Global:__mockArgs["resultTemplate"] = @'
  {
    "fields":[
      {
        "name":"_sourcecategory",
        "fieldType":"string",
        "keyField":true
      },
      {
        "name":"_count",
        "fieldType":"int",
        "keyField":false
      }
    ]
  }
'@
  $Global:__mockArgs["entryTemplate"] = @'
  {
    "map":{
      "_messageid":"INDEX",
      "_raw":"2013-01-28 13:09:11,INDEX -0800 INFO - Line of INDEX"
    }
  }
'@
  $Global:__mockArgs["functionTemplate"] = "search/jobs/ID/messages"
}

function setMockArgsForRecords($id, $count) {
  $Global:__mockArgs = @{id = $id; count = $count; ttype = "records"}
  $Global:__mockArgs["statusTemplate"] = @'
  {
    "state":"DONE GATHERING RESULTS",
    "histogramBuckets":[],
    "pendingErrors":[],
    "pendingWarnings":[],
    "recordCount":COUNT
  }
'@
  $Global:__mockArgs["resultTemplate"] = @'
  {
    "fields":[
      {
        "name":"_sourcecategory",
        "fieldType":"string",
        "keyField":true
      },
      {
        "name":"_count",
        "fieldType":"int",
        "keyField":false
      }
    ]
  }
'@
  $Global:__mockArgs["entryTemplate"] = @'
  {
    "map":{
      "_count":"INDEX",
      "_sourcecategory":"service"
    }
  }
'@
  $Global:__mockArgs["functionTemplate"] = "search/jobs/ID/records"
}

function mockPagedResult() {
  Mock invokeSumoRestMethod {
    $count = $Global:__mockArgs["count"]
    $result = ConvertFrom-Json $Global:__mockArgs["statusTemplate"].Replace("COUNT", $count)
    Write-Verbose ($result | ConvertTo-Json)
    $result
  } -ParameterFilter {
    $id = $Global:__mockArgs["id"]
    if ($function -eq "search/jobs/$id") {
      Write-Verbose "Mock calling $function"
      $true
    } else {
      $false
    }
  }
  Mock invokeSumoRestMethod {
    $count = $Global:__mockArgs["count"]
    $ttype = $Global:__mockArgs["ttype"]
    $resultTemplate =  $Global:__mockArgs["resultTemplate"]
    $entryTemplate =  $Global:__mockArgs["entryTemplate"]
    $result = ConvertFrom-Json $resultTemplate
    $offset = $query["offset"]
    $limit = $query["limit"]
    [array]$messages = @()
    for ($i = 0; $i -lt $limit ; $i += 1) {
      $index = $offset + $i
      if ($index -lt $count) {
        $map = ConvertFrom-Json $entryTemplate.Replace("INDEX", $index)
        $messages += $map
      }
    }
    Write-Verbose ("Mocking $($messages.Count) results...")
    $result | Add-Member -MemberType NoteProperty -Name $ttype -Value $messages
    Write-Verbose ($result | ConvertTo-Json)
    $result
  } -ParameterFilter {
    $id = $Global:__mockArgs["id"]
    if ($function -eq $Global:__mockArgs["functionTemplate"].Replace("ID", $id)) {
      Write-Verbose "Mock calling $function - Querry $($query["offset"]), $($query["limit"])"
      $true
    } else {
      $false
    }
  }
}

Describe "getSearchResult" {

  It "should throw exception if result is not ready" {
    
    Mock invokeSumoRestMethod {
      ConvertFrom-Json @'
      {
        "state":"NOT STARTED"
      }
'@
    } -ParameterFilter { $function -eq "search/jobs/0" }
    
    {
      getSearchResult -session $null -id 0 -limit 1 -type Record
    } | Should -Throw "Result is not ready"
  }

  It "should return message results" {

    setMockArgsForMessages -id 0 -count 3
    mockPagedResult
    $result = getSearchResult -session $null -id 0 -limit 3 -type "Message" -page 100
    $Global:__mockArgs = $null

    $result | Should Not BeNullOrEmpty
    $result.Count | Should Be 3
    $result[0]._messageid | Should Be "0"
  } 
  
  It "should return record results" {

    setMockArgsForRecords -id 1 -count 5
    mockPagedResult
    $result = getSearchResult -session $null -id 1 -type "Record" -page 100
    $Global:__mockArgs = $null

    $result | Should Not BeNullOrEmpty
    $result.Count | Should Be 5
    $result[3]._count | Should Be 3
  }
  
  It "should return only limit items even if result has more" {
    
    setMockArgsForRecords -id 2 -count 5
    mockPagedResult
    $result = getSearchResult -session $null -id 2 -limit 2 -type "Record" -page 100
    $Global:__mockArgs = $null

    $result | Should Not BeNullOrEmpty
    $result.Count | Should Be 2
    $result[1]._count | Should Be 1
  } 

  It "should return empty array if there is no result" {
    
    setMockArgsForRecords -id 3 -count 0
    mockPagedResult
    $result = getSearchResult -session $null -id 3 -type "Record" -page 100
    $Global:__mockArgs = $null
    
    $result | Should Not Be Null
    $result.Count | Should Be 0

  }

  It "should return all results if more than one page" {
    
    setMockArgsForRecords -id 4 -count 55
    mockPagedResult
    $result = getSearchResult -session $null -id 4 -type "Record" -page 10
    $Global:__mockArgs = $null
    
    $result.Count | Should Be 55
    $result[49]._count | Should Be 49
    $result[54]._count | Should Be 54

  }

  It "should truncate to limit if more results returned" {
    
    setMockArgsForRecords -id 5 -count 55
    mockPagedResult
    $result = getSearchResult -session $null -id 5 -type "Record" -limit 50 -page 10
    $Global:__mockArgs = $null
    
    $result.Count | Should Be 50
    $result[49]._count | Should Be 49
  }

  It "should stop at total if limit is larger than total" {

    setMockArgsForRecords -id 6 -count 47
    mockPagedResult
    $result = getSearchResult -session $null -id 6 -type "Record" -limit 50 -page 10
    $Global:__mockArgs = $null
    
    $result.Count | Should Be 47
    $result[46]._count | Should Be 46
  }

  It "should truncate to limit if not fill up last page" {
    
    setMockArgsForRecords -id 5 -count 55
    mockPagedResult
    $result = getSearchResult -session $null -id 5 -type "Record" -limit 47 -page 10
    $Global:__mockArgs = $null
    
    $result.Count | Should Be 47
    $result[46]._count | Should Be 46
  }
}

Describe "convertCollectorToJson" {

  It "should convert valid collector PSObject to json" {
    $obj = New-Object -TypeName psobject -Property @{
      "collectorType" = "Hosted"
      "name"          = "My Hosted Collector"
      "description"   = "An example Hosted Collector"
      "category"      = "HTTP Collection"
      "timeZone"      = "UTC"
    }
    $result = convertCollectorToJson $obj
    $result | Should Not BeNullOrEmpty
    $expected = @'
    {
      "collector": {
        "description": "An example Hosted Collector",
        "timeZone": "UTC",
        "collectorType": "Hosted",
        "category": "HTTP Collection",
        "name": "My Hosted Collector"
      }
    }
'@
    comparePSObjects (ConvertFrom-Json $result).collector (ConvertFrom-Json $expected).collector | Should Be $null
  }

  It "should remove unexpected fields" {
    $obj = New-Object -TypeName PSObject -Property @{
      "collectorType" = "Hosted"
      "name"          = "My Hosted Collector"
      "description"   = "An example Hosted Collector"
      "category"      = "HTTP Collection"
      "timeZone"      = "UTC"
      "id"            = 100772723
      "alive"         = $true
    }
    $result = convertCollectorToJson $obj
    $result | Should Not BeNullOrEmpty
    $expected = @'
    {
      "collector": {
        "description": "An example Hosted Collector",
        "collectorType": "Hosted",
        "category": "HTTP Collection",
        "timeZone": "UTC",
        "name": "My Hosted Collector"
      }
    }
'@
    comparePSObjects (ConvertFrom-Json $result).collector (ConvertFrom-Json $expected).collector | Should Be $null
  }
}

Describe "convertSourceToJson" {

  It "should convert valid source PSObject to json" {
    $obj = New-Object -TypeName psobject -Property @{
      "sourceType" = "SystemStats"
      "name"       = "Host_Metrics"
      "interval"   = 60000
      "hostName"   = "my_host"
      "metrics"    = @("CPU_User", "CPU_Sys")
    }
    $result = convertSourceToJson $obj
    $result | Should Not BeNullOrEmpty
    $expected = @'
    {
      "source": {
        "sourceType": "SystemStats",
        "name": "Host_Metrics",
        "interval": 60000,
        "hostName": "my_host",
        "metrics": ["CPU_User", "CPU_Sys"]
      }
    }
'@
    $lhs = (ConvertFrom-Json $result).source
    $rhs = (ConvertFrom-Json $expected).source
    comparePSObjects $lhs $rhs | Should Be $null
  }

  It "should remove collectorId, id and alive fields" {
    $obj = New-Object -TypeName PSObject -Property @{
      "collectorId"                = 1234567
      "id"                         = 101792472
      "name"                       = "collector_gc"
      "category"                   = "collector_gc"
      "hostName"                   = "nite-receiver-1"
      "automaticDateParsing"       = $true
      "multilineProcessingEnabled" = $true
      "useAutolineMatching"        = $true
      "forceTimeZone"              = $false
      "filters"                    = @()
      "cutoffTimestamp"            = 0
      "encoding"                   = "UTF-8"
      "pathExpression"             = "/usr/sumo/logs/collector/collector.gc.log*"
      "blacklist"                  = @()
      "sourceType"                 = "LocalFile"
      "alive"                      = $true
    }
    $result = convertSourceToJson $obj
    $result | Should Not BeNullOrEmpty
    $expected = @'
    {
      "source":{
        "name":"collector_gc",
        "category":"collector_gc",
        "hostName":"nite-receiver-1",
        "automaticDateParsing":true,
        "multilineProcessingEnabled":true,
        "useAutolineMatching":true,
        "forceTimeZone":false,
        "filters":[],
        "cutoffTimestamp":0,
        "encoding":"UTF-8",
        "pathExpression":"/usr/sumo/logs/collector/collector.gc.log*",
        "blacklist":[],
        "sourceType":"LocalFile"
      }
    }
'@
    $lhs = (ConvertFrom-Json $result).source
    $rhs = (ConvertFrom-Json $expected).source
    comparePSObjects $lhs $rhs | Should Be $null
  }
}