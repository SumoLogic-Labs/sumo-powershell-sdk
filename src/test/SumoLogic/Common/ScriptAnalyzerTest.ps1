
$scriptSources = Get-ChildItem -Path $ModuleRoot -Filter '*.ps1' -Recurse
Import-Module PSScriptAnalyzer
$exceptionList = @{
  "New-SumoSession.ps1" = "PSAvoidUsingConvertToSecureStringWithPlainText";
}
function inExceptionList($record) {
  Write-Host "$($record.ScriptName)(LN:$($record.Line)) - $($record.Severity):$($record.RuleName)"
  Write-Host $record.Message
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
