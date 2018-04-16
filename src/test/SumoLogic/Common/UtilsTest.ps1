. $PSScriptRoot/Global.ps1
. $ModuleRoot/Lib/Definitions.ps1
. $ModuleRoot/Lib/Utils.ps1

function convertFromJson($json) {
  $hashtable = @{}
  (ConvertFrom-Json $json).PSObject.Properties | ForEach-Object { $hashtable[$_.Name] = $_.Value }
  $hashtable
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
  $session = New-Object -TypeName SumoAPISession -Property @{ Endpoint = "https://localhost/"; WebSession = $null }
  $headers = @{
    "content-type" = "application/json"
    "accept"       = "application/text"
  }
  $payload = @{
    "a" = "x"
    "b" = "y"
    "c" = "&S<>"
  }
  
  It "should call cmdlet with query string if in Get method" {
    $res = invokeSumoAPI -session $session -headers $headers -method Get -function "foo/bar" -content $payload -cmdlet (Get-Command mockHttpCmdlet)
    $res | Should Not Be BeNullOrEmpty
    $res.Headers | Should Be $headers
    $res.Method | Should Be "Get"
    $res.Uri | Should Be "https://localhost/foo/bar?a=x&b=y&c=%26S%3c%3e"
  }

  It "should call Invoke-WebRequest with payload if in Post method" {
    $res = invokeSumoAPI -session $session -headers $headers -method Post -function "foo/bar" -content $payload -cmdlet (Get-Command mockHttpCmdlet)
    $res | Should Not Be BeNullOrEmpty
    $res.Headers | Should Be $headers
    $res.Method | Should Be "Post"
    $res.Uri | Should Be "https://localhost/foo/bar"
    $res.Body | Should Be (ConvertTo-Json $payload)
  }
}

Describe "invokeSumoWebRequest" {
  
  $session = New-Object -TypeName SumoAPISession -Property @{ Endpoint = "https://localhost/"; WebSession = $null }
  
  It "should call with Invoke-WebRequest" {
    Mock invokeSumoAPI {} -ParameterFilter { $cmdlet -and $cmdlet -eq (Get-Command Invoke-WebRequest -Module Microsoft.PowerShell.Utility) }
    invokeSumoWebRequest -session $session -headers @{} -method Get -function "foo/bar" -content @{}
    Assert-MockCalled invokeSumoAPI -Exactly 1 -Scope It
    invokeSumoWebRequest -session $session -headers @{} -method Post -function "foo/bar" -content @{}
    Assert-MockCalled invokeSumoAPI -Exactly 2 -Scope It
  }
}

Describe "invokeSumoRestMethod" {
  
  $session = New-Object -TypeName SumoAPISession -Property @{ Endpoint = "https://localhost/"; WebSession = $null }
  
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
    
    $_session = New-Object -TypeName SumoAPISession -Property @{ Endpoint = "https://localhost/"; WebSession = $null }
    $_query = "_sourceCategory=service"
    $_from = (Get-Date "2018-08-08T00:00:00Z").AddDays(-1)
    $_to = (Get-Date "2018-08-08T00:00:00Z")
    $_timeZone = "Asia/Shanghai"

    Mock invokeSumoAPI {} -ParameterFilter {
      $session -eq $_session -and `
        $method -eq [Microsoft.PowerShell.Commands.WebRequestMethod]::Post -and `
        $function -eq "search/jobs" -and `
        $content["query"] -eq $_query -and `
        $content["from"] -eq 1533600000000 -and `
        $content["to"] -eq 1533686400000 -and `
        $content["timeZone"] -eq $_timeZone -and `
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