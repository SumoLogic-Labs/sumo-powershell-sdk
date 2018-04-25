---
external help file: SumoLogic-Core-help.xml
Module Name: SumoLogic-Core
online version: https://help.sumologic.com/APIs/01Collector-Management-API/
schema: 2.0.0
---

# New-SumoSession

## SYNOPSIS
Session

## SYNTAX

### ByPSCredential
```
New-SumoSession -Credential <PSCredential> [-ForceUpdate] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByAccessKey
```
New-SumoSession -AccessId <String> -AccessKeyAsSecureString <SecureString> [-ForceUpdate] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Open a Sumo session.

## EXAMPLES

### EXAMPLE 1
```
New-SumoSession
```

## PARAMETERS

### -Credential
{{Fill Credential Description}}

```yaml
Type: PSCredential
Parameter Sets: ByPSCredential
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -AccessId
{{Fill AccessId Description}}

```yaml
Type: String
Parameter Sets: ByAccessKey
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AccessKeyAsSecureString
{{Fill AccessKeyAsSecureString Description}}

```yaml
Type: SecureString
Parameter Sets: ByAccessKey
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ForceUpdate
{{Fill ForceUpdate Description}}

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

## RELATED LINKS
