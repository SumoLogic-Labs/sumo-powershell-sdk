---
external help file: SumoLogic-Core-help.xml
Module Name: SumoLogic-Core
online version: https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/Set-Source.md
schema: 2.0.0
---

# Set-Source

## SYNOPSIS
Update the configuration of a source

## SYNTAX

```
Set-Source [-Session <SumoAPISession>] [-Source] <Object> [-Passthru] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Update the configuration of a source with fields in PSObject

## EXAMPLES

### EXAMPLE 1
```
Set-Source -Source $source
```

Update source with the properties in $source

### EXAMPLE 2
```
Set-Source -Source $source -Passthru
```

Update source with the properties in $source and return the updated result from server

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

### -Source
A PSObject contains source definition

```yaml
Type: Object
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

### PSObject to present source

## OUTPUTS

### PSObject to present source (if -Passthru)

## NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter
The input collector must contains a valid id field

## RELATED LINKS

[https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/Set-Source.md](https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/Set-Source.md)

[https://help.sumologic.com/APIs/01Collector-Management-API/](https://help.sumologic.com/APIs/01Collector-Management-API/)

