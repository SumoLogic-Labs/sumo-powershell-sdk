# SumoLogic PowerShell Core Module
The PowerShell Core module for managing collectors/sources, upgrading collectors, searching logs, etc.
This is a community-supported PowerShell Core module forked from https://github.com/SumoLogic/sumo-powershell-sdk and working with SumoLogic [REST API](https://help.sumologic.com/APIs).
It is free and open sourced, subject to the terms of the Apache 2.0 license.

## Getting Started

### 1. Create a Sumo Logic account and get API access Id/Key
* Create a [Sumo Logic](https://www.sumologic.com/) free account if you currently don't have one.
* Create an access Id/Key pair following this [instruction](https://help.sumologic.com/Manage/Security/Access_Keys)
* Record the access Id/Key; they will be used to authenticate to Sumo Logic web service when creating session.

### 2. Install PowerShell module to your machine
* Install [PowerShell Core](https://github.com/PowerShell/PowerShell) 6.0 or higher. 
* Install module:
```PowerShell
# Download and install remotely from PowerShell Gallery
PS> Save-Module -Name SumoLogic-Core -Path <path> # Save locally
PS> Install-Module -Name SumoLogic-Core # Install to module repository, may need root/administrator priveldge
# Alternatively, from local github clone
PS> Import-Module $repo/src/main/SumoLogic-Core
```

### 3. Read help document of cmdlets
https://github.com/SumoLogic/sumo-powershell-sdk/tree/ps_gallery/docs

### 4. Start to use cmdlets
```PowerShell
PS> Get-Command -Module SumoLogic-Core # Navigate all commands in the module
PS> Get-Help Get-Collector -Full # Get help and samples for cmdlets
...
```

## Issues and Feature Request
Report any issue or idea through [Git Hub](https://github.com/SumoLogic/sumo-powershell-sdk)
