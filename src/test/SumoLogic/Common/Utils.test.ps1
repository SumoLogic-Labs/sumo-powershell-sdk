. $PSScriptRoot/Global.ps1
. $ModuleRoot/Lib/Definitions.ps1
. $ModuleRoot/Lib/Utils.ps1

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
    if ($lhs[$key] -ne $rhs[$key]) {
      New-Object -TypeName psobject -Property @{
        "Key"   = $prop
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
    getFullName($obj) | Should Be "collector_gc [0000000006113AD8]"
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
  
  $session = [SumoAPISession]::new("https://localhost/", $null)
  
  It "should call with Invoke-WebRequest" {
    Mock invokeSumoAPI {} -ParameterFilter { $cmdlet -and $cmdlet -eq (Get-Command Invoke-WebRequest -Module Microsoft.PowerShell.Utility) }
    invokeSumoWebRequest -session $session -headers @{} -method Get -function "foo/bar" -content @{}
    Assert-MockCalled invokeSumoAPI -Exactly 1 -Scope It
    invokeSumoWebRequest -session $session -headers @{} -method Post -function "foo/bar" -content @{}
    Assert-MockCalled invokeSumoAPI -Exactly 2 -Scope It
  }
}

Describe "invokeSumoRestMethod" {
  
  $session = [SumoAPISession]::new("https://localhost/", $null)
  
  It "should call with Invoke-RestMethod" {
    Mock invokeSumoAPI {} -ParameterFilter { $cmdlet -and $cmdlet -eq (Get-Command Invoke-RestMethod -Module Microsoft.PowerShell.Utility) }
    invokeSumoRestMethod -session $session -headers @{} -method Get -function "foo/bar" -content @{}
    Assert-MockCalled invokeSumoAPI -Exactly 1 -Scope It
    invokeSumoRestMethod -session $session -headers @{} -method Post -function "foo/bar" -content @{}
    Assert-MockCalled invokeSumoAPI -Exactly 2 -Scope It
  }
}

Describe "startSearchJob" {
  It "should call invokeSumoAPI with correct parameters" {
    
    $_session = [SumoAPISession]::new("https://localhost/", $null)
    $_query = "_sourceCategory=service"
    $_from = (Get-Date "2018-08-08T00:00:00Z").AddDays(-1)
    $_to = (Get-Date "2018-08-08T00:00:00Z")
    $_timeZone = "Asia/Shanghai"

    Mock invokeSumoAPI {} -ParameterFilter {
      $session -eq $_session -and `
        $method -eq [Microsoft.PowerShell.Commands.WebRequestMethod]::Post -and `
        $function -eq "search/jobs" -and `
        $query["query"] -eq $_query -and `
        $query["from"] -eq 1533600000000 -and `
        $query["to"] -eq 1533686400000 -and `
        $query["timeZone"] -eq $_timeZone -and `
        $cmdlet -eq (Get-Command Invoke-RestMethod -Module Microsoft.PowerShell.Utility) 
    }
    startSearchJob $_session $_query $_from $_to $_timeZone
    Assert-MockCalled invokeSumoAPI -Exactly 1 -Scope It
  }
}

Describe "getSearchResult" {
  
  It "should throw exception if result is not ready" {
    Mock invokeSumoRestMethod {
      New-Object -TypeName psobject -Property @{ state = "NOT STARTED" }
    } -ParameterFilter { $function -eq "search/jobs/0" }
    {
      getSearchResult -session $null -id 0 -limit 1 -type "Record"
    } | Should -Throw "Result is not ready"
  }

  It "should return message results" {
    Mock invokeSumoRestMethod {
      ConvertFrom-Json @'
    {
      "state":"DONE GATHERING RESULTS",
      "messageCount":3,
      "histogramBuckets":[],
      "pendingErrors":[],
      "pendingWarnings":[],
      "recordCount":3
    }
'@
    } -ParameterFilter { $function -eq "search/jobs/0" }

    Mock invokeSumoRestMethod {
      ConvertFrom-Json @'
    {
      "fields":[
        {
          "name":"_messageid",
          "fieldType":"long",
          "keyField":false
        },
        {
          "name":"_raw",
          "fieldType":"string",
          "keyField":false
        }
      ],
      "messages":[
        {
          "map":{
            "_messageid":"-9223372036854773763",
            "_raw":"2013-01-28 13:09:10,333 -0800 INFO Line 1"
          }
        },
        {
          "map":{
            "_messageid":"-9223372036854773764",
            "_raw":"2013-01-28 13:09:11,333 -0800 INFO Line 2"
          }
        },
        {
          "map":{
            "_messageid":"-9223372036854773765",
            "_raw":"2013-01-28 13:19:11,333 -0800 INFO Line 3"
          }
        }
      ]
    }
'@
    } -ParameterFilter { $function -eq "search/jobs/0/messages" }
    $result = getSearchResult -session $null -id 0 -limit 3 -type "Message"
    $result | Should Not BeNullOrEmpty
    $result.Count | Should Be 3
    $result[0]._messageid | Should Be "-9223372036854773763"
  } 
  
  It "should return record results" {
    Mock invokeSumoRestMethod {
      ConvertFrom-Json @'
    {
      "state":"DONE GATHERING RESULTS",
      "messageCount":3,
      "histogramBuckets":[],
      "pendingErrors":[],
      "pendingWarnings":[],
      "recordCount":3
    }
'@
    } -ParameterFilter { $function -eq "search/jobs/0" }

    Mock invokeSumoRestMethod {
      ConvertFrom-Json @'
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
      ],
      "records":[
        {
          "map":{
            "_count":"90",
            "_sourcecategory":"service"
          }
        },
        {
          "map":{
            "_count":"80",
            "_sourcecategory":"service"
          }
        },
        {
          "map":{
            "_count":"70",
            "_sourcecategory":"service"
          }
        }
      ]
    }
'@
    } -ParameterFilter { $function -eq "search/jobs/0/records" }
    $result = getSearchResult -session $null -id 0 -limit 3 -type "Record"
    $result | Should Not BeNullOrEmpty
    $result.Count | Should Be 3
    $result[0]._count | Should Be 90
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
        "sourceType":"LocalFile",
      }
    }
'@
    $lhs = (ConvertFrom-Json $result).source
    $rhs = (ConvertFrom-Json $expected).source
    comparePSObjects $lhs $rhs | Should Be $null
  }
}