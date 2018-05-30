---
external help file: SumoLogic-Core-help.xml
Module Name: SumoLogic-Core
online version: https://github.com/SumoLogic/sumo-powershell-sdk/blob/master/docs/New-Collector.md
schema: 2.0.0
---

# New-Collector

## SYNOPSIS
Create a hosted collector

## SYNTAX

### ByObject
```
New-Collector [-Session <SumoAPISession>] [[-Collector] <PSObject>] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### ByJson
```
New-Collector [-Session <SumoAPISession>] [[-Json] <String>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Create a new hosted collector with json string or PSObject with collector definition

## EXAMPLES

### EXAMPLE 1
```
New-Collector -Collector $collector
```

Create a collector with the definition in $collector

### EXAMPLE 2
```
Get-Content collector.json -Raw | New-Collector
```

Create a collector with the definition in collector.json

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

### -Collector
A PSObject contains collector definition

```yaml
Type: PSObject
Parameter Sets: ByObject
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Json
A string contains collector definition in json format

```yaml
Type: String
Parameter Sets: ByJson
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
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

### PSObject to present collector (for copy an existing collector) or JSON string

## OUTPUTS

### PSObject to present collector(s)

## NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter
Only "Hosted" collector can be created with API

## RELATED LINKS

[https://github.com/SumoLogic/sumo-powershell-sdk/blob/master/docs/New-Collector.md](https://github.com/SumoLogic/sumo-powershell-sdk/blob/master/docs/New-Collector.md)

[https://help.sumologic.com/APIs/01Collector-Management-API/](https://help.sumologic.com/APIs/01Collector-Management-API/)

