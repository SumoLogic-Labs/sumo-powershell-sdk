. $PSScriptRoot/../Common/Global.ps1

Describe "Get-UpgradeVersion" {
  $PSDefaultParameterValues = @{ 'It:Skip' = !($AccessId -and $AccessKey) }

  BeforeAll {
    New-SumoSession -AccessId $AccessId -AccessKey $AccessKey
  }

  It "should get the latest version string" {
    $res = Get-UpgradeVersion
    $res | Should Not BeNullOrEmpty
    $res -is [string] | Should Be $true
    $res -match "^\d+\.\d+-\d+$" | Should Be $true
  }

  It "should get all available versions in string list" {
    $res = Get-UpgradeVersion -ListAvailable
    $res | Should Not BeNullOrEmpty
    $res -is [array] | Should Be $true
    $res | ForEach-Object { $_ -match "^\d+\.\d+-\d+$" | Should Be $true }
  }
  
}

Describe "Get-UpgradeableCollector" {

  BeforeAll {
    New-SumoSession -AccessId $AccessId -AccessKey $AccessKey
  }

  It "should call sumo API with query strings" {
    Mock invokeSumoRestMethod -Verifiable { 
      New-Object -TypeName psobject -Property @{
        "collectors" = @{
          "session" = $session
          "function" = $function
          "query" = $query
          "method" = $method
        }
      }
    } -ModuleName "SumoLogic"
    $res = Get-UpgradeableCollector
    $res | Should Not BeNullOrEmpty
    $res.function | Should Be "collectors/upgrades/collectors"
    $expected = @{}
    compareHashtables $res.query $expected | Should Be $null
    $res = Get-UpgradeableCollector -Offset 0 -Limit 5
    $res | Should Not BeNullOrEmpty
    $res.function | Should Be "collectors/upgrades/collectors"
    $expected = @{
      "offset" = 0
      "limit" = 5
    }
    compareHashtables $res.query $expected | Should Be $null
    $res = Get-UpgradeableCollector -TargetVersion 19.209-29 -Offset 0 -Limit 5
    $res | Should Not BeNullOrEmpty
    $res.function | Should Be "collectors/upgrades/collectors"
    $expected = @{
      "offset" = 0
      "limit" = 5
      "toVersion" = "19.209-29"
    }
    compareHashtables $res.query $expected | Should Be $null
  }
}
