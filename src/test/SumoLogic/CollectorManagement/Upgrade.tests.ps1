. $PSScriptRoot/../Common/Global.ps1

Describe "Get-UpgradeVersion" {
  $PSDefaultParameterValues = @{ 'It:Skip' = !($AccessId -and $AccessKey) }

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

  It "should call sumo API with query strings" {
    Mock invokeSumoRestMethod -Verifiable { 
      New-Object -TypeName psobject -Property @{
        "collectors" = @{
          "session"  = $session
          "function" = $function
          "query"    = $query
          "method"   = $method
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
      "limit"  = 5
    }
    compareHashtables $res.query $expected | Should Be $null
    $res = Get-UpgradeableCollector -TargetVersion 19.209-29 -Offset 0 -Limit 5
    $res | Should Not BeNullOrEmpty
    $res.function | Should Be "collectors/upgrades/collectors"
    $expected = @{
      "offset"    = 0
      "limit"     = 5
      "toVersion" = "19.209-29"
    }
    compareHashtables $res.query $expected | Should Be $null
  }
}

Describe "Start-UpgradeTask" {

  It "should call sumo API" {
    Mock invokeSumoRestMethod -Verifiable { 
      New-Object -TypeName psobject -Property @{
        "collector" = @{}
      }
    } -ModuleName "SumoLogic" -ParameterFilter { $function -eq "collectors/7" }
    Mock invokeSumoRestMethod -Verifiable {
      New-Object -TypeName psobject -Property @{
        "id" = 3
      }
    } -ModuleName "SumoLogic" -ParameterFilter { $function -eq "collectors/upgrades" }
    Mock invokeSumoRestMethod -Verifiable {
      New-Object -TypeName psobject -Property @{
        "upgrade" = @{}
      }
    } -ModuleName "SumoLogic" -ParameterFilter { $function -eq "collectors/upgrades/3" }
    Mock getCollectorUpgradeStatus -Verifiable {} -ModuleName "SumoLogic"
    Start-UpgradeTask -CollectorId 7
    Assert-MockCalled getCollectorUpgradeStatus -Exactly 1 -Scope It -ModuleName "SumoLogic"     
  }
}

Describe "Get-UpgradeTask" {

  It "should get upgrade status as expected" {
    Mock invokeSumoRestMethod -Verifiable { 
      New-Object -TypeName psobject -Property @{
        "upgrade" = New-Object -TypeName psobject -Property @{
          "id"          = 7
          "collectorId" = 3
          "requestTime" = 123456
          "status"      = 2
        }
      }
    } -ModuleName "SumoLogic" -ParameterFilter { $function -eq "collectors/upgrades/7" }
    Mock invokeSumoRestMethod -Verifiable { 
      New-Object -TypeName psobject -Property @{
        "collector" = New-Object -TypeName psobject -Property @{
          "name"             = "myName"
          "osName"           = "myOsName"
          "osVersion"        = "myOsVersion"
          "collectorVersion" = "myCollectorVersion"
          "alive"            = $true
          "lastSeenAlive"    = 654321
        }
      }
    } -ModuleName "SumoLogic" -ParameterFilter { $function -eq "collectors/3" }
    $res = Get-UpgradeTask -UpgradeId 7
    $res | Should Not BeNullOrEmpty
    $expected = New-Object -TypeName psobject -Property @{
      "collectorId"      = 3
      "id"               = 7
      "status"           = 2
      "collectorName"    = "myName"
      "osName"           = "myOsName"
      "osVersion"        = "myOsVersion"
      "collectorVersion" = "myCollectorVersion"
      "alive"            = $true
      "requestTime"      = (Get-Date "1/1/70 12:02:03 AM")
      "lastHeartbeat"    = (Get-Date "1/1/70 12:10:54 AM")
      "message"          = "Upgrade completed and success "
    }
    comparePSObjects $res $expected | Should Be $null
  }
}