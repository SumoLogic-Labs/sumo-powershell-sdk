---
external help file: SumoLogic-Core-help.xml
Module Name: SumoLogic-Core
online version: https://help.sumologic.com/APIs/01Collector-Management-API/
schema: 2.0.0
---

# Get-Source

## SYNOPSIS
Get the information of source(s)

## SYNTAX

### ById (Default)
```
Get-Source [-Session <SumoAPISession>] [-CollectorId] <Int64> [[-SourceId] <Int64>] [<CommonParameters>]
```

### ByName
```
Get-Source [-Session <SumoAPISession>] [-CollectorId] <Int64> [[-NamePattern] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get the information of source(s) based on collector id and source id or source name pattern

## EXAMPLES

### EXAMPLE 1
```
Get-Source -CollectorId 12345
```

Get all sources for collector with id 12345

### EXAMPLE 2
```
Get-Source -CollectorId 12345 -NamePattern "Web Log File"
```

Get source(s) which name contains "Web Log File" and in collector with id 12345

### EXAMPLE 3
```
Get-Collector -NamePattern "IIS" | Get-Source -NamePattern "Web Log File"
```

Get all sources which name contains "Web Log File" in all collector(s) wich name contains "IIS"

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
Aliases: id

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
Parameter Sets: ById
Aliases:

Required: False
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -NamePattern
A string contains a regular expression which used to search source(s) by name

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: False
Position: 2
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

