<#
.SYNOPSIS
Create a session for following cmdlets

.DESCRIPTION
Create a SumoAPISession object for connecting Sumo Logic API endpoint and store it for current script

.PARAMETER Credential
A PS credential contains access id and access key information

.PARAMETER AccessId
A string contains access id from Sumo Logic

.PARAMETER AccessKeyAsSecureString
A secured string contains access key from Sumo Logic

.PARAMETER ForceUpdate
Do not confirm before update the default session

.EXAMPLE
New-SumoSession -Credential $cred
Create a session with $cred

.EXAMPLE
New-SumoSession -AccessId $AccessId -AccessKeyAsSecureString (Read-Host -AsSecureString)
Create a session with $AccessId and $AccessKey read from console

.INPUTS
PSCredential contains access id and access key

.OUTPUTS
SumoAPISession contains endpoint and credential to access the endpoint

.NOTES

.LINK
https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/New-SumoSession.md

.LINK
https://help.sumologic.com/APIs/General-API-Information
#>

function New-SumoSession {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "Low")]
  param(
    [parameter(ParameterSetName = "ByPSCredential", Mandatory = $true, ValueFromPipeline = $true)]
    [PSCredential]$Credential,
    [parameter(ParameterSetName = "ByAccessKey", Mandatory = $true)]
    [string]$AccessId,
    [parameter(ParameterSetName = "ByAccessKey", Mandatory = $true)]
    [SecureString]$AccessKeyAsSecureString,
    [switch]$ForceUpdate
  )
  begin {
    # TLS 1.1+ is not enabled by default in Windows PowerShell, but it is
    # required to communicate with the Sumo Logic API service.
    # Enable it if needed
    if ([System.Net.ServicePointManager]::SecurityProtocol -ne [System.Net.SecurityProtocolType]::SystemDefault) {
      Write-Warning "Enabling TLS 1.2 usage via [System.Net.ServicePointManager]::SecurityProtocol"
      [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
    }
  }
  process {
    if ("ByAccessKey" -eq $PSCmdlet.ParameterSetName) {
      $Credential = New-Object System.Management.Automation.PSCredential ($AccessId, $AccessKeyAsSecureString)
    }
    $session = getSession $Credential
    $session
  }
  end {
    if ($session -and ($ForceUpdate -or $PSCmdlet.ShouldProcess("The default connection in current session will be updated. Continue?"))) {
      $Script:sumoSession = $session
    }
  }
}
