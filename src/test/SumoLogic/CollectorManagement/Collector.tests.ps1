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
  }
  $res = New-Collector -Collector $obj
  $res | Should Not BeNullOrEmpty
  $res
}

if (!($AccessId -and $AccessKey)) {
  "This test require working access id/key defined in `$Global:AccessId and `$Global:AccessKey"
} else {
  
  Describe "New-Collector" {

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
      $res = New-Collector -Json $json
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
      $res = New-Collector -Collector $obj
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

    BeforeEach {
      cleanup
    }

    AfterEach {
      cleanup
    }

    It "should remove collector by id" {
      $res = testCollector
      Remove-Collector -Id $res.id -Force
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

    BeforeEach {
      cleanup
    }

    AfterEach {
      cleanup
    }

    It "should remove collector by id" {
    }
  }
}