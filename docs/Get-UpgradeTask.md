---
external help file: SumoLogic-Core-help.xml
Module Name: SumoLogic-Core
online version: https://help.sumologic.com/APIs/01Collector-Management-API/
schema: 2.0.0
---

# Get-UpgradeTask

## SYNOPSIS
Get the status of collector upgrade task

## SYNTAX

```
Get-UpgradeTask [-Session <SumoAPISession>] [-UpgradeId] <Int64> [<CommonParameters>]
```

## DESCRIPTION
Get the status of collector upgrade task by Id

## EXAMPLES

### EXAMPLE 1
```
Get-UpgradeTask -Id 78912
```

Get upgrade status for the task 78912 (which from the result of Start-UpgradeTask cmdlet)

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### PSObject to present upgrade task or upgrade task id in long

## OUTPUTS

### PSObject to present upgrade tasks

## NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter

## RELATED LINKS

[https://help.sumologic.com/APIs/01Collector-Management-API/](https://help.sumologic.com/APIs/01Collector-Management-API/)

