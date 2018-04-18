. $PSScriptRoot/../Common/Global.ps1

if (!($AccessId -and $AccessKey)) {
  "This test require working access id/key defined in `$Global:AccessId and `$Global:AccessKey"
}
else {
  Describe "New-SumoSession" {
    
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
}