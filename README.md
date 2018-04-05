# Sumo Logic PowerShell SDK

This is a community-supported Windows PowerShell Module to work with the Sumo Logic [REST API](https://help.sumologic.com/APIs).
It is free and open source, subject to the terms of the Apache 2.0 license.

## Getting Started

### 1. Create a Sumo Logic account and get API access Id/Key
Create a [Sumo Logic](https://www.sumologic.com/) free account if you currently don't have one.
<br />
Create an access Id/Key pair following this [instruction](https://help.sumologic.com/Manage/Security/Access_Keys)
<br />
Record the access Id/Key; they will be used to authenticate to Sumo Logic web service when creating session.

### 2. Install Cmdlet module to your machine
Following this [instruction](https://msdn.microsoft.com/en-us/library/dd878350(v=vs.85).aspx) to install PowerShell Module files under `sumologic` to your machine. 
<br />
__NOTE__: This module requires PowerShell 3.0 or higher to work.

### 3. Run samples
Launch `Sample.ps1` under `sample` folder and try some examples 

### 4. Get-Collector For Accounts Over 1000 Collectors
Results returned from the SumoLogic collector API default to a 1000 limit. 
This means if you have more than 1000 collectors you need to use -Limit and -Offset arguments or you will get incomplete results.

For example say we more than 1000 collectors, and several hundred collectors with 'test' in the name property. The code below demonstrates how adding -Limit and -Offset will fix the problem that the default limit 1000 returns an incomplete result set.

```
# This returns 56 results - ONLY the collectors matching test from the first 1000 returned by the API.
(Get-collector | where {$_.name -match 'test' } ).count
56

# Now setting a limit of 10000 we get the complete result set of 219 matching string 'test' by name
(Get-collector -Limit 10000 -Offset 0  | where {$_.name -match 'test' } ).count                                                219

 ```

## Issues and Feature Request
Report any issue or idea through [Git Hub](https://github.com/SumoLogic/sumo-powershell-sdk)


