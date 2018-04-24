. $PSScriptRoot/Global.ps1

$scriptSources = Get-ChildItem -Path $ModuleRoot -Filter '*.ps1' -Recurse
Import-Module PSScriptAnalyzer
$exceptionList = @{
  "Utils.ps1" = "PSAvoidUsingWriteHost"
  "Wait-UpgradeTask.ps1" = "PSAvoidUsingWriteHost"
}
function inExceptionList($record) {
  Write-Verbose "$($record.ScriptName)(LN:$($record.Line)) - $($record.Severity):$($record.RuleName)"
  Write-Verbose $record.Message
  $exceptionList[$record.ScriptName] -contains $record.RuleName 
}

Describe "Script Source analysis" {
  foreach ($scriptSource in $scriptSources) {
    Context "Source $($scriptSource.Name)" {
      $records = Invoke-ScriptAnalyzer -Path $scriptSource.FullName | Where-Object { -not (inExceptionList $_) }
      it "should have no errors" {
        $records | Should BeNullOrEmpty
      }
    }
  }
}
