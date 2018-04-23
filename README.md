# Sumo Logic PowerShell SDK

This is a community-supported Windows PowerShell Module to work with the Sumo Logic [REST API](https://help.sumologic.com/APIs).
It is free and open sourced, subject to the terms of the Apache 2.0 license.

| TLS Deprecation Notice |
| --- |
| In keeping with industry standard security best practices, as of May 31, 2018, the Sumo Logic service will only support TLS version 1.2 going forward. Verify that all connections to Sumo Logic endpoints are made from software that supports TLS 1.2. |

## Getting Started

### 1. Create a Sumo Logic account and get API access Id/Key
* Create a [Sumo Logic](https://www.sumologic.com/) free account if you currently don't have one.
* Create an access Id/Key pair following this [instruction](https://help.sumologic.com/Manage/Security/Access_Keys)
* Record the access Id/Key; they will be used to authenticate to Sumo Logic web service when creating session.

### 2. Install Cmdlet module to your machine
* Install [PowerShell Core 6.0](https://github.com/PowerShell/PowerShell)
* Install module:
```PowerShell
PS> Install-Module $gitrepo/src/main/SumoLogic -Force # From local clone
PS> Save-Module -Name SumoLogic -Path <path> # Or, install remotely from PowerShell Gallery
PS> Install-Module -Name SumoLogic
```
__NOTE__: This module requires PowerShell Core 6.0 or higher to work.

### 3. Start to use cmdlets
```PowerShell
PS> Get-Command -Module SumoLogic # Navigate all commands in the module:
PS> Get-Help Get-Collector -Full # Get help and samples for cmdlets
PS> New-SumoSession -AccessId xxx -AccessKey xxxxxxxx # Creating session
PS> Get-Collector # List all collectors
```

## Issues and Feature Request
Report any issue or idea through [Git Hub](https://github.com/SumoLogic/sumo-powershell-sdk)

## Run unit tests
