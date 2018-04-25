---
external help file: SumoLogic-Core-help.xml
Module Name: SumoLogic-Core
online version: https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/New-SumoSession.md
schema: 2.0.0
---

# New-SumoSession

## SYNOPSIS
Create a session for following cmdlets

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
Create a SumoAPISession object for connecting Sumo Logic API endpoint and store it for current script

## EXAMPLES

### EXAMPLE 1
```
New-SumoSession -Credential $cred
```

Create a session with $cred

### EXAMPLE 2
```
New-SumoSession -AccessId $AccessId -AccessKeyAsSecureString (Read-Host -AsSecureString)
```

Create a session with $AccessId and $AccessKey read from console

## PARAMETERS

### -Credential
A PS credential contains access id and access key information

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
A string contains access id from Sumo Logic

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
A secured string contains access key from Sumo Logic

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
Do not confirm before update the default session

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

### PSCredential contains access id and access key

## OUTPUTS

### SumoAPISession contains endpoint and credential to access the endpoint

## NOTES

## RELATED LINKS

[https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/New-SumoSession.md](https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/New-SumoSession.md)

[https://help.sumologic.com/APIs/General-API-Information](https://help.sumologic.com/APIs/General-API-Information)

