---
external help file: SumoLogic-Core-help.xml
Module Name: SumoLogic-Core
online version: https://github.com/SumoLogic/sumo-powershell-sdk/blob/master/docs/Set-Collector.md
schema: 2.0.0
---

# Set-Collector

## SYNOPSIS
Update the properties of a collector

## SYNTAX

```
Set-Collector [-Session <SumoAPISession>] [-Collector] <PSObject> [-Passthru] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Update the properties of a collector with fields in PSObject

## EXAMPLES

### EXAMPLE 1
```
Set-Collector -Collector $collector
```

Update collector with the properties in $collector

### EXAMPLE 2
```
Set-Collector -Collector $collector -Passthru
```

Update collector with the properties in $collector and return the updated result from server

## PARAMETERS

### -Session
An instance of SumoAPISession which contains API endpoint and credential

```yaml
Type: SumoAPISession
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $Script:sumoSession
Accept pipeline input: False
Accept wildcard characters: False
```

### -Collector
A PSObject contains collector definition

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Passthru
Return back the result after updating

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

### PSObject to present collector (if -Passthru)

## NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter
The input collector must contains a valid id field

## RELATED LINKS

[https://github.com/SumoLogic/sumo-powershell-sdk/blob/master/docs/Set-Collector.md](https://github.com/SumoLogic/sumo-powershell-sdk/blob/master/docs/Set-Collector.md)

[https://help.sumologic.com/APIs/01Collector-Management-API/](https://help.sumologic.com/APIs/01Collector-Management-API/)

