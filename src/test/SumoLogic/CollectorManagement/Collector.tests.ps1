. $PSScriptRoot/../Common/Global.ps1

function cleanup {
  New-SumoSession -AccessId $AccessId -AccessKey $AccessKey | Out-Null
  Get-Collector -NamePattern "PowerShell_Test.*"| Remove-Collector -Force
}

function testCollector {
  $obj = New-Object -TypeName psobject -Property @{
    "collectorType" = "Hosted"
    "name"          = "PowerShell_Test"
    "description"   = "An example Hosted Collector"
    "category"      = "HTTP Collection"
    "timeZone"      = "UTC"
  }
  $res = New-Collector -Collector $obj
  $res | Should Not BeNullOrEmpty
  $res
}

Describe "New-Collector" {
  $PSDefaultParameterValues = @{ 'It:Skip' = !($AccessId -and $AccessKey) }

  BeforeEach {
    cleanup
  }

  AfterEach {
    cleanup
  }

  It "should create collector with valid json" {
    $json = @'
      {
        "collector":{
          "collectorType":"Hosted",
          "name":"PowerShell_Test",
          "description":"An example Hosted Collector",
          "category":"HTTP Collection",
          "timeZone":"UTC"
        }
      }
'@
    $res = New-Collector $json
    $res | Should Not BeNullOrEmpty
    $res.name | Should Be "PowerShell_Test"
  }

  It "should create collector with valid collector object" {
    $obj = New-Object -TypeName psobject -Property @{
      "collectorType" = "Hosted"
      "name"          = "PowerShell_Test"
      "description"   = "An example Hosted Collector"
      "category"      = "HTTP Collection"
    }
    $res = New-Collector $obj
    $res | Should Not BeNullOrEmpty
    $res.name | Should Be "PowerShell_Test"
  }

  It "should create collector with pipeline input" {
    $res = New-Object -TypeName psobject -Property @{
      "collectorType" = "Hosted"
      "name"          = "PowerShell_Test"
      "description"   = "An example Hosted Collector"
      "category"      = "HTTP Collection"
    } | New-Collector
    $res | Should Not BeNullOrEmpty
    $res.name | Should Be "PowerShell_Test"
  }

  It "should create collector with only name changed" {
    $res = testCollector
    $res.name = "PowerShell_Test_1"
    $res1 = New-Collector -Collector $res
    $res1 | Should Not BeNullOrEmpty
    $res1.name | Should Be "PowerShell_Test_1"
  }
}

Describe "Remove-Collector" {
  $PSDefaultParameterValues = @{ 'It:Skip' = !($AccessId -and $AccessKey) }

  BeforeEach {
    cleanup
  }

  AfterEach {
    cleanup
  }

  It "should remove collector by id" {
    $res = testCollector
    Remove-Collector $res.id -Force
    {
      Get-Collector -Id $res.id
    } | Should -Throw "Response status code does not indicate success: 404 (Not Found)."
  }

  It "should remove collector from pipeline" {
    $res = testCollector
    Get-Collector -Id $res.id | Remove-Collector -Force
    {
      Get-Collector -Id $res.id
    } | Should -Throw "Response status code does not indicate success: 404 (Not Found)."
  }
}

Describe "Set-Collector" {
  $PSDefaultParameterValues = @{ 'It:Skip' = !($AccessId -and $AccessKey) }

  BeforeEach {
    cleanup
  }

  AfterEach {
    cleanup
  }

  It "should update collector properties" {
    $collector = testCollector
    $collector.name = "PowerShell_Test_Modified"
    $collector.description = "new description"
    $collector.category = "new category"
    $collector.timeZone = "America/Los_Angeles"
    Set-Collector $collector -Force
    $updated = Get-Collector $collector.id
    $updated | Should Not BeNullOrEmpty
    $updated.name | Should Be "PowerShell_Test_Modified"
    $updated.description | Should Be "new description"
    $updated.category | Should Be "new category"
    $updated.timeZone | Should Be "America/Los_Angeles"
  }

  It "should update collector from pipeline" {
    $collector = testCollector
    $collector.name = "PowerShell_Test_Modified"
    $collector.description = "new description"
    $collector.category = "new category"
    $collector.timeZone = "America/Los_Angeles"
    $collector | Set-Collector -Force
    $updated = Get-Collector $collector.id
    $updated | Should Not BeNullOrEmpty
    $updated.name | Should Be "PowerShell_Test_Modified"
    $updated.description | Should Be "new description"
    $updated.category | Should Be "new category"
    $updated.timeZone | Should Be "America/Los_Angeles"
  }

  It "should update collector and return it if with -Passthru" {
    $collector = testCollector
    $collector.name = "PowerShell_Test_Modified"
    $collector.description = "new description"
    $collector.category = "new category"
    $collector.timeZone = "America/Los_Angeles"
    $updated = $collector | Set-Collector -Force -Passthru
    $updated | Should Not BeNullOrEmpty
    $updated.name | Should Be "PowerShell_Test_Modified"
    $updated.description | Should Be "new description"
    $updated.category | Should Be "new category"
    $updated.timeZone | Should Be "America/Los_Angeles"
  }
}
