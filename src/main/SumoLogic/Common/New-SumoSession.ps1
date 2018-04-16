<#
.SYNOPSIS
    Session
.DESCRIPTION
    Open a Sumo session.
.EXAMPLE
    New-SumoSession
#>

function New-SumoSession {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact="Low")]
  param(
    [parameter(ParameterSetName = "ByPSCredential", Mandatory = $true, ValueFromPipeline = $true)]
    [PSCredential]$Credential,
    [parameter(ParameterSetName = "ByAccessKey", Mandatory = $true)]
    [string]$AccessId,
    [parameter(ParameterSetName = "ByAccessKey", Mandatory = $true)]
    [string]$AccessKey,
    [switch]$ForceUpdate = $false
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
      $secpasswd = ConvertTo-SecureString $AccessKey -AsPlainText -Force
      $Credential = New-Object System.Management.Automation.PSCredential ($AccessId, $secpasswd)
    }
    $session = getSession $Credential
  }
  end {
    if ($session -and ($ForceUpdate -or $PSCmdlet.ShouldProcess("The default connection in current session will be updated. Continue?"))) {
      $Script:sumoSession = $session
    }
  }
}
