---
external help file: SumoLogic-Core-help.xml
Module Name: SumoLogic-Core
online version: https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/Start-UpgradeTask.md
schema: 2.0.0
---

# Start-UpgradeTask

## SYNOPSIS
Start a collector upgrade task request

## SYNTAX

```
Start-UpgradeTask [-Session <SumoAPISession>] [-CollectorId] <Int64> [[-Version] <String>] [-Force] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Start a collector upgrade task to upgrade collector(s) to another version

## EXAMPLES

### EXAMPLE 1
```
Start-UpgradeTask -CollectorId 12345 -ToVersion 19.208-19
```

Submit a collector upgrade task request for upgrading collector with id 12345 to version 19.209-19

### EXAMPLE 2
```
Get-UpgradeableCollector | Start-UpgradeTask
```

Submit upgrade tasks for upgrading all collectors in current orgnization to latest version

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

### -CollectorId
The id of collector in long

```yaml
Type: Int64
Parameter Sets: (All)
Aliases: id

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Version
A string contains collector version want upgrade/downgrade to

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Do not confirm before running

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### PSObject to present collector

## OUTPUTS

### PSObject to present collector upgrade task

## NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter

## RELATED LINKS

[https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/Start-UpgradeTask.md](https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/Start-UpgradeTask.md)

[https://help.sumologic.com/APIs/01Collector-Management-API/](https://help.sumologic.com/APIs/01Collector-Management-API/)

