---
external help file: SumoLogic-Core-help.xml
Module Name: SumoLogic-Core
online version: https://help.sumologic.com/APIs/Search-Job-API/About-the-Search-Job-API
schema: 2.0.0
---

# Start-SearchJob

## SYNOPSIS
Start a search job

## SYNTAX

### ByLast (Default)
```
Start-SearchJob [-Session <Object>] [[-Query] <String>] [-Last <TimeSpan>] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### ByTimeRange
```
Start-SearchJob [-Session <Object>] [[-Query] <String>] -From <DateTime> -To <DateTime> [-TimeZone <String>]
 [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Start a search job and waiting for the result fetched

## EXAMPLES

### EXAMPLE 1
```
Start-SearchJob -Query "_sourceCategory=service ERROR" -Last "00:30:00"
```

Search all results in last 30 minutes with "ERROR" in "service" category

## PARAMETERS

### -Session
An instance of SumoAPISession which contains API endpoint and credential

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $Script:sumoSession
Accept pipeline input: False
Accept wildcard characters: False
```

### -Query
The query used for the search in string

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Last
A time span for query recent results

```yaml
Type: TimeSpan
Parameter Sets: ByLast
Aliases:

Required: False
Position: Named
Default value: [TimeSpan]::FromMinutes(15)
Accept pipeline input: False
Accept wildcard characters: False
```

### -From
Query with a time range start from

```yaml
Type: DateTime
Parameter Sets: ByTimeRange
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -To
Query with a time range end to

```yaml
Type: DateTime
Parameter Sets: ByTimeRange
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimeZone
Time zone used for time range query

```yaml
Type: String
Parameter Sets: ByTimeRange
Aliases:

Required: False
Position: Named
Default value: UTC
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

### Not accepted

## OUTPUTS

### PSObject to present search job

## NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter
This call will wait until done gathering results or hit a failure.
See link page for details

## RELATED LINKS

[https://help.sumologic.com/APIs/Search-Job-API/About-the-Search-Job-API](https://help.sumologic.com/APIs/Search-Job-API/About-the-Search-Job-API)

