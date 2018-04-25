---
external help file: SumoLogic-Core-help.xml
Module Name: SumoLogic-Core
online version: https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/Get-UpgradeVersion.md
schema: 2.0.0
---

# Get-UpgradeVersion

## SYNOPSIS
Get the collector version(s) for upgrading

## SYNTAX

```
Get-UpgradeVersion [[-Session] <SumoAPISession>] [-ListAvailable]
```

## DESCRIPTION
Get the latest version string of collector from SumoLogic server and it can be used for upgrading collector in following process

## EXAMPLES

### EXAMPLE 1
```
Get-UpgradeVersion
```

Get a string contains latest version of collector for upgrading

### EXAMPLE 2
```
Get-UpgradeVersion -ListAvailable
```

Get all available versions for upgrading/downgrading in a string list

## PARAMETERS

### -Session
An instance of SumoAPISession which contains API endpoint and credential

```yaml
Type: SumoAPISession
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $sumoSession
Accept pipeline input: False
Accept wildcard characters: False
```

### -ListAvailable
If true, return a list of string with all available collector versions

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### Not accepted

## OUTPUTS

### string (for latest upgrade version) all string array (for available upgrade versions)

## NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter

## RELATED LINKS

[https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/Get-UpgradeVersion.md](https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/Get-UpgradeVersion.md)

[https://help.sumologic.com/APIs/01Collector-Management-API/](https://help.sumologic.com/APIs/01Collector-Management-API/)

