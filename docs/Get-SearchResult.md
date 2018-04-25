---
external help file: SumoLogic-Core-help.xml
Module Name: SumoLogic-Core
online version: https://help.sumologic.com/APIs/Search-Job-API/About-the-Search-Job-API
schema: 2.0.0
---

# Get-SearchResult

## SYNOPSIS
Get the result of search

## SYNTAX

```
Get-SearchResult [-Session <Object>] [-Id] <Object> [-Type <SumoSearchResultType>] [-Limit <Int32>]
 [<CommonParameters>]
```

## DESCRIPTION
Get the result of a search job.
It could be in messages (for log search) or in records (for aggregating)

## EXAMPLES

### EXAMPLE 1
```
Start-SearchJob -Query "_sourceCategory=service ERROR" -Last "00:30:00" | Get-SearchResult -Type Message
```

Search all results in last 30 minutes with "ERROR" in "service" category and return the messages

### EXAMPLE 2
```
Start-SearchJob -Query "| count _sourceCategory" -Last "00:30:00" | Get-SearchResult -Type Record
```

Return the number of messages for each source category in last 30 minutes

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

### -Id
The search job id, which from the result of Start-SearchJob

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Type
Can be "Message" or "Record"

```yaml
Type: SumoSearchResultType
Parameter Sets: (All)
Aliases:
Accepted values: Message, Record

Required: False
Position: Named
Default value: Message
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
Only return last x entries of results if specified

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### PSObject to present search job

## OUTPUTS

### PSObject to present records or messages

## NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter
This call will wait until done gathering results or hit a failure.
See link page for details

## RELATED LINKS

[https://help.sumologic.com/APIs/Search-Job-API/About-the-Search-Job-API](https://help.sumologic.com/APIs/Search-Job-API/About-the-Search-Job-API)

