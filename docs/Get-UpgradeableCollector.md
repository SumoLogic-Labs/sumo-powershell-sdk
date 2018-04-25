---
external help file: SumoLogic-Core-help.xml
Module Name: SumoLogic-Core
online version: https://help.sumologic.com/APIs/01Collector-Management-API/
schema: 2.0.0
---

# Get-UpgradeableCollector

## SYNOPSIS
Get the information of collector(s) elegible for upgrading

## SYNTAX

```
Get-UpgradeableCollector [[-Session] <SumoAPISession>] [[-TargetVersion] <String>] [[-Offset] <Int32>]
 [[-Limit] <Int32>]
```

## DESCRIPTION
Get the information of collector(s) which can be upgraded to specific version.
The result can also be retrieved in pages if there are many collectors in your organization

## EXAMPLES

### EXAMPLE 1
```
Get-UpgradeableCollector
```

Get all collectors in current organization can be upgraded to latest version

### EXAMPLE 2
```
Get-UpgradeableCollector -TargetVersion 19.209-8
```

Get all collectors in current organization can be upgraded/downgraded to version 19.209-8

### EXAMPLE 3
```
Get-UpgradeableCollector -Offset 100 -Limit 50
```

Get all collectors in current organization can be upgraded to latest version in page; return 50 results from begin from the 100th result

## PARAMETERS

### -Session
An instance of SumoAPISession which contains API endpoint and credential

```yaml
Type: SumoAPISession
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $sumoSession
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetVersion
A string contains version of collector you want upgrade to.
If not specified, the latest version will be used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Offset
The offset used for paging result

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
The limit (e.g.
page size) used for paging result

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### Not accepted

## OUTPUTS

### PSObject to present collector(s) (elegible for upgrading)

## NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter

## RELATED LINKS

[https://help.sumologic.com/APIs/01Collector-Management-API/](https://help.sumologic.com/APIs/01Collector-Management-API/)

