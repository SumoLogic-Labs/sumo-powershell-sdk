---
external help file: SumoLogic-Core-help.xml
Module Name: SumoLogic-Core
online version: https://help.sumologic.com/APIs/01Collector-Management-API/
schema: 2.0.0
---

# New-Source

## SYNOPSIS
Create a source in specific collector

## SYNTAX

### ByObject
```
New-Source [-Session <SumoAPISession>] [-CollectorId] <Int64> [[-Source] <PSObject>] [-Force] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### ByJson
```
New-Source [-Session <SumoAPISession>] [-CollectorId] <Int64> [[-Json] <String>] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Create a new source in specific collector with json string or PSObject with source definition

## EXAMPLES

### EXAMPLE 1
```
New-Source -CollectorId 12345 -Source $source
```

Create a source under collector 12345 with the definition in $source

### EXAMPLE 2
```
Get-Content source.json -Raw | New-Source -CollectorId 12345
```

Create a source under collector 12345 with the definition in source.json

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

### -Source
A PSObject contains source definition

```yaml
Type: PSObject
Parameter Sets: ByObject
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Json
A string contains source definition in json format

```yaml
Type: String
Parameter Sets: ByJson
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
{{Fill Force Description}}

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

## OUTPUTS

## NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter

## RELATED LINKS

[https://help.sumologic.com/APIs/01Collector-Management-API/](https://help.sumologic.com/APIs/01Collector-Management-API/)

