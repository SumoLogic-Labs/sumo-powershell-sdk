---
external help file: SumoLogic-Core-help.xml
Module Name: SumoLogic-Core
online version: https://help.sumologic.com/APIs/01Collector-Management-API/
schema: 2.0.0
---

# Get-Collector

## SYNOPSIS
Get the information of collector(s)

## SYNTAX

### ById (Default)
```
Get-Collector [-Session <SumoAPISession>] [[-Id] <Int64>] [<CommonParameters>]
```

### ByName
```
Get-Collector [-Session <SumoAPISession>] [-NamePattern <String>] [<CommonParameters>]
```

### ByPage
```
Get-Collector [-Session <SumoAPISession>] -Offset <Int32> -Limit <Int32> [<CommonParameters>]
```

## DESCRIPTION
Get the information of collector(s) based on id or name pattern.
The result can also be retrieved in pages if there are many collectors in your organization

## EXAMPLES

### EXAMPLE 1
```
Get-Collector
```

Get all collectors in current organization

### EXAMPLE 2
```
Get-Collector -Id 12345
```

Get collector with id 12345

### EXAMPLE 3
```
Get-Collector -NamePattern "IIS"
```

Get all collector(s) which name contains "IIS"

### EXAMPLE 4
```
Get-Collector -Offset 100 -Limit 50
```

Get all collectors in current organization in page; return 50 results from begin from the 100th result

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

### -Id
The id of collector in long

```yaml
Type: Int64
Parameter Sets: ById
Aliases:

Required: False
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -NamePattern
A string contains a regular expression which used to search collector(s) by name

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Offset
The offset used for paging result

```yaml
Type: Int32
Parameter Sets: ByPage
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
The limit (e.g.
page size) used for paging result

```yaml
Type: Int32
Parameter Sets: ByPage
Aliases:

Required: True
Position: Named
Default value: 0
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

