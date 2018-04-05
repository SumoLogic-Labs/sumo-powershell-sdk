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
    [parameter(Mandatory = $true, Position = 0)]
    [SumoDeployment]$Deployment,
    [parameter(ParameterSetName = "ByPSCredential", Mandatory = $true, ValueFromPipeline = $true)]
    [PSCredential]$Credential,
    [parameter(ParameterSetName = "ByAccessKey", Mandatory = $true)]
    [string]$AccessId,
    [parameter(ParameterSetName = "ByAccessKey", Mandatory = $true)]
    [string]$AccessKey,
    [switch]$ForceUpdate = $false
  )
  process {
    $endpoint = $Script:apiPoints[$Deployment]
    if ("ByAccessKey" -eq $PSCmdlet.ParameterSetName) {
      $secpasswd = ConvertTo-SecureString $AccessKey -AsPlainText -Force
      $Credential = New-Object System.Management.Automation.PSCredential ($AccessId, $secpasswd)
    }
    $url = $endpoint + "collectors?offset=0&limit=1"
    $res = Invoke-WebRequest -Uri $url -Headers $Script:headers -Method Get `
      -Credential $Credential -SessionVariable webSession
    if ($res.StatusCode -eq 200) {
      $session = getSession $endpoint $webSession $res
      $session
    }
    else {
      $null
    }
  }
  end {
    if ($ForceUpdate -or $PSCmdlet.ShouldProcess("The default session will be overwritten, continue?")) {
      $Script:sumoSession = $session
    }
  }
}
