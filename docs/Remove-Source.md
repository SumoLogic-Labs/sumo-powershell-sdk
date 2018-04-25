---
external help file: SumoLogic-Core-help.xml
Module Name: SumoLogic-Core
online version: https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/Remove-Source.md
schema: 2.0.0
---

# Remove-Source

## SYNOPSIS
Remove a source

## SYNTAX

```
Remove-Source [-Session <SumoAPISession>] [-CollectorId] <Int64> [-SourceId] <Int64> [-Force] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Remove source from specific collector

## EXAMPLES

### EXAMPLE 1
```
Get-Source -CollectorId 12345 -NamePattern "Web Log File" | Remove-Source
```

Remove source(s) which name contains "Web Log File" and in collector with id 12345

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

### -CollectorId
The id of collector in long

```yaml
Type: Int64
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SourceId
The id of source in long

```yaml
Type: Int64
Parameter Sets: (All)
Aliases: id

Required: True
Position: 2
Default value: 0
Accept pipeline input: True (ByPropertyName)
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

### PSObject to present source(s)

## OUTPUTS

### None

## NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter

## RELATED LINKS

[https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/Remove-Source.md](https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/Remove-Source.md)

[https://help.sumologic.com/APIs/01Collector-Management-API/](https://help.sumologic.com/APIs/01Collector-Management-API/)

