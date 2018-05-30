# SumoLogic PowerShell Core Module

[![Build status](https://ci.appveyor.com/api/projects/status/t22p5jaq164ixqq1?svg=true)](https://ci.appveyor.com/project/bin3377/sumo-powershell-sdk)  [![powershellgallery](https://img.shields.io/powershellgallery/v/SumoLogic-Core.svg)](https://www.powershellgallery.com/packages/SumoLogic-Core)

The PowerShell Core module for managing collectors/sources, upgrading collectors, searching logs, etc.
This is a community-supported PowerShell Core module forked from https://github.com/SumoLogic/sumo-powershell-sdk and working with SumoLogic [REST API](https://help.sumologic.com/APIs).
It is free and open sourced, subject to the terms of the Apache 2.0 license.

| TLS Deprecation Notice |
| --- |
| In keeping with industry standard security best practices, as of May 31, 2018, the Sumo Logic service will only support TLS version 1.2 going forward. Verify that all connections to Sumo Logic endpoints are made from software that supports TLS 1.2. |

## Getting Started

### 1. Create a Sumo Logic account and get API access Id/Key

- Create a [Sumo Logic](https://www.sumologic.com/) free account if you currently don't have one.
- Create an access Id/Key pair following this [instruction](https://help.sumologic.com/Manage/Security/Access_Keys)
- Record the access Id/Key; they will be used to authenticate to Sumo Logic web service when creating session.

### 2. Install PowerShell module to your machine

- With Windows PowerShell 5.0+, or
- Install [PowerShell Core](https://github.com/PowerShell/PowerShell) 6.0 or higher.
- Install module:

```PowerShell
# Download and install remotely from PowerShell Gallery
Save-Module -Name SumoLogic-Core -Path <path> # Save locally
Install-Module -Name SumoLogic-Core # Install to module repository, may need root/administrator priveldge
# Alternatively, from local github clone
Import-Module $repo/src/main/SumoLogic-Core
```

### 3. Read help document of cmdlets

```PowerShell
Get-Help Get-Collector -Full # Get help and samples for cmdlets
```

[Online version](https://github.com/SumoLogic/sumo-powershell-sdk/tree/master/docs)

### 4. Start to use cmdlets

```PowerShell
Get-Command -Module SumoLogic-Core # Navigate all commands in the module
```

## Issues and Feature Request

Report any issue or idea through [Git Hub](https://github.com/SumoLogic/sumo-powershell-sdk)
