. $PSScriptRoot/../Common/Global.ps1

Describe "Get-Source" {
  $PSDefaultParameterValues = @{ 'It:Skip' = !($AccessId -and $AccessKey) }

  BeforeEach {
    cleanup
  }

  AfterEach {
    cleanup
  }

  It "should get single source by id" {
    $cid = (testCollector).id
    $sid = (testSource $cid).id
    $res = Get-Source $cid $sid
    $res | Should Not BeNullOrEmpty
    $res -isnot [array] | Should Be $true
    $res.id | Should Be $sid
    $res.collectorId | Should Be $cid
  }

  It "should get all sources in collector with pipeline-in collector" {
    $cid = (testCollector).id
    @(1..10) | ForEach-Object { testSource $cid "$_" }
    $res = Get-Collector $cid | Get-Source
    $res | Should Not BeNullOrEmpty
    $res.Count | Should Be 10
    $res | ForEach-Object {
      $_.id | Should Not BeNullOrEmpty
      $_.collectorId | Should Be $cid
    }    
  }
  
  It "should get all sources in collector by name pattern" {
    $cid = (testCollector).id
    @(1..3) | ForEach-Object { testSource $cid "A$_" }
    @(1..7) | ForEach-Object { testSource $cid "B$_" }
    $res = Get-Source $cid -NamePattern "Example_HTTP_Source_A"
    $res | Should Not BeNullOrEmpty
    $res.Count | Should Be 3
  }
}

Describe "New-Source" {
  $PSDefaultParameterValues = @{ 'It:Skip' = !($AccessId -and $AccessKey) }

  BeforeEach {
    cleanup
  }

  AfterEach {
    cleanup
  }

  It "should create source with valid json" {
    $json = @'
    {
      "source":{
         "sourceType":"HTTP",
         "name":"Example1",
         "messagePerRequest": true
      }
   }
'@
    $cid = (testCollector).id
    $res = New-Source $cid -Json $json
    $res | Should Not BeNullOrEmpty
    $res -isnot [array] | Should Be $true
    $res.id | Should Not BeNullOrEmpty
    $res.collectorId | Should Not BeNullOrEmpty
  }

  It "should create source with valid source object" {
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
    $cid = (testCollector).id
    $res = New-Source $cid -Source $obj
    $res | Should Not BeNullOrEmpty
    $res -isnot [array] | Should Be $true
    $res.id | Should Not BeNullOrEmpty
    $res.collectorId | Should Not BeNullOrEmpty
  }

  It "should create source with pipeline-in collector" {
    $res = New-Collector -Json @'
    {
      "collector":{
        "collectorType":"Hosted",
        "name":"PowerShell_Test",
        "description":"An example Hosted Collector",
        "category":"HTTP Collection",
        "timeZone":"UTC"
      }
    }
'@ | New-Source -Json @'
{
  "source":{
     "sourceType":"HTTP",
     "name":"Example1",
     "messagePerRequest": true
  }
}
'@
    $res | Should Not BeNullOrEmpty
    $res -isnot [array] | Should Be $true
    $res.id | Should Not BeNullOrEmpty
    $res.collectorId | Should Not BeNullOrEmpty
  }

  It "should create source from a copy from another collector" {
    $cid1 = (testCollector "1").id
    $cid2 = (testCollector "2").id
    $sid1 = (testSource $cid1).id
    $source = Get-Source $cid1 $sid1
    $res = New-Source $cid2 -Source $source
    $res | Should Not BeNullOrEmpty
    $res -isnot [array] | Should Be $true
    $res.id | Should Not BeNullOrEmpty
    $res.collectorId | Should Be $cid2
  }

}