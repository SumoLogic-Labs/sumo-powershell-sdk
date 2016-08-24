#Requires -RunAsAdministrator
Param(
    $Deployment,
    $AccessID,
    $AccessKey,
    $InstallFolder,
    $CollectorName,
    $RunAsUser,
    $RunAsPassword,
    $SourceJson,
    $ExtraInstall4JParameters
)

Add-Type -TypeDefinition @"
   public enum SumoDeployment
   {
       Prod,
       Sydney,
       Dublin,
       US2,
       US4
   }
"@

$Script:collectorEndpoints = @{
    [SumoDeployment]::Prod = 'https://collectors.sumologic.com/'
    [SumoDeployment]::Sydney = 'https://collectors.au.sumologic.com/'
    [SumoDeployment]::Dublin = 'https://collectors.eu.sumologic.com/'
    [SumoDeployment]::US2 = 'https://collectors.us2.sumologic.com/'
    [SumoDeployment]::US4 = 'https://collectors.us4.sumologic.com/'
}

$Script:apiEndpoints = @{
    [SumoDeployment]::Prod = 'https://api.sumologic.com/api/v1/'
    [SumoDeployment]::Sydney = 'https://api.au.sumologic.com/api/v1/'
    [SumoDeployment]::Dublin = 'https://api.eu.sumologic.com/api/v1/'
    [SumoDeployment]::US2 = 'https://api.us2.sumologic.com/api/v1/'
    [SumoDeployment]::US4 = 'https://api.us4.sumologic.com/api/v1/'
}

$Script:headers = @{
    'content-type' = 'application/json'
    'accept' = 'application/json'
}

function Get-Installer {
    $is64Bit = [environment]::Is64BitOperatingSystem
    $url = $Script:collectorEndpoints[$Script:Deployment] + "rest/download/"
    if ($is64Bit) {
        $url += 'win64'
        $arch = 'Windows 64-bit'
    } else {
        $url += 'windows'
        $arch = 'Windows 32-bit'
    }
    $output = "$env:temp\collector_installer.exe"
    $start_time = Get-Date
    Import-Module BitsTransfer
    Start-BitsTransfer -Source $url -Destination $output
    Write-Information "Downloaded Sumo Logic Collector ($arch) from $Script:Deployment; taken $((Get-Date).Subtract($start_time).Seconds) second(s)."
    Get-Item "$env:temp\collector_installer.exe"
}

function Read-Deployment {
    while (!$result) {
        $result = Read-Host "Select a deployment (Prod, Sydney, Dublin, US2, US4) [Prod]"
        if ($result -eq '') {
            $result = 'Prod'
        }
        Try {
            $deploy = [SumoDeployment]$result
        } catch {
            Write-Error 'Not a valid Input'
            $result = $null
        }
    }
    $Script:Deployment = $deploy
}

function Read-AccessKey {
    $retry = 0
    while (($retry -lt 3) -and (!$AccessID -or !$AccessKey)) {
        Trap { Continue }
        $accId = Read-Host "Input Access ID"
        $accKey = Read-Host "Input Access Key"
        $endpoint = $Script:apiEndpoints[$Script:Deployment]
        $sec = ConvertTo-SecureString $accKey -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential ($accId, $sec)

        $url = $endpoint + "collectors?offset=0&limit=1"
        $res = Invoke-WebRequest -Uri $url -Headers $Script:headers -Method Get -Credential $cred -SessionVariable webSession
        if (!$res -or ($res.StatusCode -ne 200)) {
            $retry += 1
            Write-Error 'Authentication failed'
        } else {
            $Script:AccessID = $accId
            $Script:AccessKey = $accKey
        }
    }
    if (!$Script:AccessID -or !$Script:AccessKey) {
        exit
    }
}

function Read-Parameter($name, $defaultValue) {
    if ($defaultValue) {
        $msg = "$name[$defaultValue]"
    } else {
        $msg = "$name"
    }
    $prompt = Read-Host $msg
    if ($defaultValue -and ($prompt -eq '')) {
        $prompt = $defaultValue
    }
    Set-Variable -Scope Script -Name $name -Value $prompt
}

if (!$InstallFolder) {
    Read-Parameter "InstallFolder" "$env:ProgramFiles\Sumo Logic Collector"
}
if (!$CollectorName) {
    Read-Parameter "CollectorName" $env:COMPUTERNAME
}
if (!$Deployment) {
    Read-Deployment
} else {
    $Script:Deployment = [SumoDeployment]$Deployment
}
if (!$AccessKey -or !$AccessID) {
    Read-AccessKey
}

$installer = Get-Installer

$args = "-q", "-console", "-dir", """$InstallFolder""", "-Vsumo.accessid=$AccessID", "-Vsumo.accesskey=$AccessKey", "-Vcollector.url=$($Script:collectorEndpoints[$Deployment])", "-Vcollector.name=$CollectorName"

if ($SourceJson) {
    $args += "-Vsources=$SourceJson"
}
if ($RunAsUser -and $RunAsPassword) {
    $args += "-VrunAs.username=$RunAsUser"
    $args += "-VwinRunAs.password=$RunAsPassword"
}
if ($ExtraInstall4JParameters) {
    $args += $ExtraInstall4JParameters
}

Start-Process -FilePath $Installer.FullName -ArgumentList $args -Wait
