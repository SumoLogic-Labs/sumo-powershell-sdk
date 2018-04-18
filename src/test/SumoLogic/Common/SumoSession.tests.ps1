. $PSScriptRoot/../Common/Global.ps1

Describe "New-SumoSession" {
  $PSDefaultParameterValues = @{ 'It:Skip' = !($AccessId -and $AccessKey) }

  It "should create SumoAPISession with valid accessId/Key" {
    $res = New-SumoSession -AccessId $AccessId -AccessKey $AccessKey
    $res | Should Not BeNullOrEmpty
  }

  It "should create SumoAPISession with valid credential" {
    $secpasswd = ConvertTo-SecureString $AccessKey -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ($AccessId, $secpasswd)
    $res = New-SumoSession -Credential $cred
    $res | Should Not BeNullOrEmpty
  }

}
