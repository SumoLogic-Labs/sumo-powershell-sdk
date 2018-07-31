. $PSScriptRoot/../Common/Global.ps1

Describe "Start-SearchJob" {

  It "should startSearchJob with correct parameters with time range" {
    Mock startSearchJob {} -Verifiable -ParameterFilter {
      $Query -eq "q" -and $From -eq (Get-Date "1981-02-19T00:00:00Z") -and `
      $To -eq (Get-Date "1989-07-25T00:00:00Z") -and `
      $TimeZone -eq "Asia/Shanghai"
    } -ModuleName $ModuleName 

    {
      Start-SearchJob -Query "q" -From (Get-Date "1981-02-19T00:00:00Z") -To (Get-Date "1989-07-25T00:00:00Z") -TimeZone "Asia/Shanghai"
    } | Should -Throw "Job creation fail"
    Assert-MockCalled startSearchJob -Exactly 1 -Scope It -ModuleName $ModuleName
  }

  It "should throw exception if time range not valid" {
    Mock startSearchJob {} -Verifiable -ModuleName $ModuleName

    {
      Start-SearchJob -Query "q" -From (Get-Date "1989-07-25T00:00:00Z") -To (Get-Date "1981-02-19T00:00:00Z") -TimeZone "Asia/Shanghai"
    } | Should -Throw "Time range [07/24/1989 17:00:00 to 02/18/1981 16:00:00] is illegal"
    Assert-MockCalled startSearchJob -Exactly 0 -Scope It -ModuleName $ModuleName
  }

  It "should startSearchJob with a valid timespan in last" {
    Mock startSearchJob {} -Verifiable -ParameterFilter {} -ModuleName $ModuleName 

    {
      Start-SearchJob -Query "q" -Last "00:20:00"
    } | Should -Throw "Job creation fail"
    Assert-MockCalled startSearchJob -Exactly 1 -Scope It -ModuleName $ModuleName
  }

  It "should throw exception if job status not available" {
    Mock startSearchJob {
      @{ "id" = 7 }
    } -Verifiable -ModuleName $ModuleName
    Mock invokeSumoRestMethod {} -Verifiable -ParameterFilter { $function -eq "search/jobs/7" } -ModuleName $ModuleName
    {
      Start-SearchJob -Query "q" -Last "00:20:00"
    } | Should -Throw "Cannot get search job status"
    Assert-MockCalled startSearchJob -Exactly 1 -Scope It -ModuleName $ModuleName
    Assert-MockCalled invokeSumoRestMethod -Exactly 1 -Scope It -ModuleName $ModuleName
  }

  It "should throw exception if job cancelled" {
    Mock startSearchJob {
      @{ "id" = 7 }
    } -Verifiable -ModuleName $ModuleName
    Mock invokeSumoRestMethod {
      @{ "state" = "CANCELED" }
    } -Verifiable -ParameterFilter { $function -eq "search/jobs/7" } -ModuleName $ModuleName
    {
      Start-SearchJob -Query "q" -Last "00:20:00"
    } | Should -Throw "The search job has been canceled"
    Assert-MockCalled startSearchJob -Exactly 1 -Scope It -ModuleName $ModuleName
    Assert-MockCalled invokeSumoRestMethod -Exactly 1 -Scope It -ModuleName $ModuleName
  }

  It "should throw exception if job paused by system" {
    Mock startSearchJob {
      @{ "id" = 7 }
    } -Verifiable -ModuleName $ModuleName
    Mock invokeSumoRestMethod {
      @{ "state" = "FORCE PAUSED" }
    } -Verifiable -ParameterFilter { $function -eq "search/jobs/7" } -ModuleName $ModuleName
    {
      Start-SearchJob -Query "q" -Last "00:20:00"
    } | Should -Throw "Query is paused by the system"
    Assert-MockCalled startSearchJob -Exactly 1 -Scope It -ModuleName $ModuleName
    Assert-MockCalled invokeSumoRestMethod -Exactly 1 -Scope It -ModuleName $ModuleName
  }

  It "should create search job and query result by id" {
    Mock startSearchJob {
      @{ "id" = 7 }
    } -Verifiable -ModuleName $ModuleName
    Mock invokeSumoRestMethod {
      $script:called += 1
      if ($script:called -eq 1) {
        @{ "state" = "NOT STARTED" }
      } elseif ($script:called -eq 2) {
        @{ "state" = "GATHERING RESULTS" }
      } else {
        @{ "state" = "DONE GATHERING RESULTS" }
      }
    } -Verifiable -ParameterFilter { $function -eq "search/jobs/7" } -ModuleName $ModuleName
    $script:called = 0
    $res = Start-SearchJob -Query "q" -Last "00:20:00"
    $res | Should Not BeNullOrEmpty
    Assert-MockCalled startSearchJob -Exactly 1 -Scope It -ModuleName $ModuleName
    Assert-MockCalled invokeSumoRestMethod -Exactly 3 -Scope It -ModuleName $ModuleName
  }
}
