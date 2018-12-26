# SumoLogic PowerShell Module

[![Build status](https://ci.appveyor.com/api/projects/status/w4l6bgj56dxlaoen?svg=true)](https://ci.appveyor.com/project/bin3377/sumo-powershell-sdk)  [![powershellgallery](https://img.shields.io/powershellgallery/v/SumoLogic-Core.svg?logo=PowerShell&logoColor=C0C0C0)](https://www.powershellgallery.com/packages/SumoLogic-Core)

The SumoLogic PowerShell module is for using PowerShell to manage collectors/sources, upgrade collectors, and search logs with [SumoLogic API](https://help.sumologic.com/APIs)
This is a community-supported PowerShell module, free and open sourced; subject to the terms of the Apache 2.0 license.

## Getting Started

### 1. Create a SumoLogic account and get API access Id/Key

- Create a [SumoLogic](https://www.sumologic.com/) free account if you currently don't have one.
- Create an access Id/Key pair following this [instruction](https://help.sumologic.com/Manage/Security/Access_Keys)
- Record the access Id/Key; they will be used to authenticate to SumoLogic web service when creating session.

### 2. Install PowerShell module to your machine

- With Windows PowerShell 5.0+ (on Windows), or
- Install [PowerShell Core](https://github.com/PowerShell/PowerShell) 6.0 or higher.
- Install module:

```PowerShell
# Download and install remotely from PowerShell Gallery
Save-Module -Name SumoLogic-Core -Path <path> # Save locally
Install-Module -Name SumoLogic-Core # Install to module repository, may need root/administrator privilege
# Alternatively, from local github clone
Import-Module $repo/src/main/SumoLogic-Core
```

### 3. Read help document of cmdlets

```PowerShell
Get-Help Get-Collector -Full # Get help and samples for cmdlets
```

[Online version](https://github.com/SumoLogic/sumo-powershell-sdk/tree/master/docs)

### 4. Start to use cmdlets

#### Setup a session connecting to SumoLogic deployment

Before calling any API function, you need to setup a `SumoSession` and store it into current PowerShell session

```PowerShell
$cred = Get-Credential # Following the prompt, input access ID as User and access Key as Password
New-SumoSession -Credential $cred # This cmdlet will try to use the access Key/ID to connect to correct deployment

# You can also using string to pass access Key/Id as following, but it is not recommended since it will expose the access key as plain text
$accessId = "<access key>"
$accessKeyAsSecureString = ConvertTo-SecureString "<access Id>" -AsPlainText -Force
New-SumoSession -AccessId $accessId -AccessKeyAsSecureString $accessKeyAsSecureString | Out-Null

# If necessary, using a specific API endpoint with environment variable
$env:SUMOLOGIC_API_ENDPOINT="https://api.de.sumologic.com/api/v1/"
```

**NOTE:**

- If you want specific the deployment to connect, set environment variable `SUMOLOGIC_API_ENDPOINT` as the value of "API endpoint" in [this page](https://help.sumologic.com/APIs/General-API-Information/Sumo-Logic-Endpoints-and-Firewall-Security).
- You can also store the `SumoSession` into a variable and call following cmdlets with the parameter `SumoAPISession` for switching context between different deployments/accounts

#### Navigate the cmdlets to use

```PowerShell
Get-Command -Module SumoLogic-Core # Navigate all commands in the module
Get-Collector # For example, Query all collectors in current account
```

## Issues and Feature Request

Report any issue or idea through [Github](https://github.com/SumoLogic/sumo-powershell-sdk)

### TLS 1.2 Requirement

Sumo Logic only accepts connections from clients using TLS version 1.2 or greater. To utilize the content of this repo, ensure that it's running in an execution environment that is configured to use TLS 1.2 or greater.
