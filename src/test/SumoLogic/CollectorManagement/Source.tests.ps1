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

Describe "New-Source" {
  $PSDefaultParameterValues = @{ 'It:Skip' = !($AccessId -and $AccessKey) }

  BeforeEach {
    cleanup
  }

  AfterEach {
    cleanup
  }

  It "should create collector with valid json" {
  }
}