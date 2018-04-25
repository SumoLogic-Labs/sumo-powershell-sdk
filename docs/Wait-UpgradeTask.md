---
external help file: SumoLogic-Core-help.xml
Module Name: SumoLogic-Core
online version: https://help.sumologic.com/APIs/01Collector-Management-API/
schema: 2.0.0
---

# Wait-UpgradeTask

## SYNOPSIS
Wait the upgrade task of collector complete

## SYNTAX

```
Wait-UpgradeTask [-Session <SumoAPISession>] [-UpgradeId] <Int64> [-RefreshMs <Int64>] [-Quiet]
 [<CommonParameters>]
```

## DESCRIPTION
Wait the upgrade task to complete and return the result of upgrade

## EXAMPLES

### EXAMPLE 1
```
Wait-UpgradeTask -Id 78912
```

Blocking current session until the upgrade task 78912 complete and return the result

### EXAMPLE 2
```
Start-UpgradeTask -CollectorId 12345 -Version 19.216-22 | Wait-UpgradeTask
```

Submit upgrade request on collector 12345 to version 19.216-22 and wait it complete

### EXAMPLE 3
```
Get-UpgradeableCollector | Start-UpgradeTask | Wait-UpgradeTask
```

Submit upgrade requests on all available collectors to latest version and wait them complete

## PARAMETERS

### -Session
An instance of SumoAPISession which contains API endpoint and credential

```yaml
Type: SumoAPISession
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $sumoSession
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpgradeId
The id of upgrade task in long

```yaml
Type: Int64
Parameter Sets: (All)
Aliases: id

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -RefreshMs
The interval of refreshing status in milliseconds, default is 500

```yaml
Type: Int64
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 500
Accept pipeline input: False
Accept wildcard characters: False
```

### -Quiet
If set, the status of upgrade will not be printed on console

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter

## RELATED LINKS

[https://help.sumologic.com/APIs/01Collector-Management-API/](https://help.sumologic.com/APIs/01Collector-Management-API/)

