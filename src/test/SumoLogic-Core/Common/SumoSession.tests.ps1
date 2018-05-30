. $PSScriptRoot/../Common/Global.ps1

Describe "New-SumoSession" {
  $PSDefaultParameterValues = @{ 'It:Skip' = !($AccessId) }

  It "should create SumoAPISession with valid accessId/Key" {
    $res = New-SumoSession -AccessId $AccessId -AccessKeyAsSecureString $AccessKeyAsSecureString
    $res | Should Not BeNullOrEmpty
  }

  It "should create SumoAPISession with valid credential" {
    $cred = New-Object System.Management.Automation.PSCredential ($AccessId, $AccessKeyAsSecureString)
    $res = New-SumoSession -Credential $cred
    $res | Should Not BeNullOrEmpty
  }

}
