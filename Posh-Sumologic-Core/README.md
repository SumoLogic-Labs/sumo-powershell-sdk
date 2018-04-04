# Posh-Sumologic-Core
Sumologic Powershell Core module.

## To test/debug:
Download module -> run Posh-Sumologic-Core.sandbox.ps1 to load.

## Install via PowershellLibrary
```powershell
PowerShellGet\Install-Module Posh-SumologicCore -Scope CurrentUser
```

## cmdlets
```powershell
NAME
    Get-Collector

SYNOPSIS
    Collector


SYNTAX
    Get-Collector [-Session <Object>] [[-Id] <Int64>] [<CommonParameters>]

    Get-Collector [-Session <Object>] [-NamePattern <String>] [<CommonParameters>]

    Get-Collector [-Session <Object>] -Offset <Int32> -Limit <Int32> [<CommonParameters>]


DESCRIPTION
    Get collector/s details.


PARAMETERS
    -Session <Object>

    -Id <Int64>

    -NamePattern <String>

    -Offset <Int32>

    -Limit <Int32>

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>Get-Collector
```

```powershell
NAME
    Get-SearchResult

SYNOPSIS
    Get results


SYNTAX
    Get-SearchResult [-Session <Object>] [-Id] <Object> [-Type {Message | Record}] [-Limit <Int32>] [<CommonParameters>]


DESCRIPTION
    Call results of a search.


PARAMETERS
    -Session <Object>

    -Id <Object>

    -Type

    -Limit <Int32>

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>Get-SearchResult
```

```powershell
NAME
    Get-Source

SYNOPSIS
    Source


SYNTAX
    Get-Source [-Session <Object>] -CollectorId <Int64> [[-SourceId] <Int64>] [<CommonParameters>]

    Get-Source [-Session <Object>] -CollectorId <Int64> [-NamePattern <String>] [<CommonParameters>]

    Get-Source [-Session <Object>] -CollectorId <Int64> -Offset <Int32> -Limit <Int32> [<CommonParameters>]


DESCRIPTION
    Get sources.


PARAMETERS
    -Session <Object>

    -CollectorId <Int64>

    -SourceId <Int64>

    -NamePattern <String>

    -Offset <Int32>

    -Limit <Int32>

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>Get-Source
```

```powershell
NAME
    New-SumoSession

SYNOPSIS
    Session


SYNTAX
    New-SumoSession [-Deployment] {Prod | Sydney | Dublin | US2} -Credential <PSCredential> [<CommonParameters>]

    New-SumoSession [-Deployment] {Prod | Sydney | Dublin | US2} -AccessId <String> -AccessKey <String> [<CommonParameters>]


DESCRIPTION
    Open a Sumo session.


PARAMETERS
    -Deployment

    -Credential <PSCredential>

    -AccessId <String>

    -AccessKey <String>

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>New-SumoSession
```

```powershell
NAME
    Remove-Collector

SYNOPSIS
    Collector


SYNTAX
    Remove-Collector [-Session <Object>] [-Id] <Int64> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIPTION
    Remove collector/s.


PARAMETERS
    -Session <Object>

    -Id <Int64>

    -Force [<SwitchParameter>]

    -WhatIf [<SwitchParameter>]

    -Confirm [<SwitchParameter>]

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>Remove-Collector
```

```powershell
NAME
    Remove-Source

SYNOPSIS
    Source


SYNTAX
    Remove-Source [[-Session] <Object>] [-CollectorId] <Int64> [-SourcId] <Int64> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIPTION
    Remove sources.


PARAMETERS
    -Session <Object>

    -CollectorId <Int64>

    -SourcId <Int64>

    -Force [<SwitchParameter>]

    -WhatIf [<SwitchParameter>]

    -Confirm [<SwitchParameter>]

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>Remove-Source
```

```powershell
NAME
    Set-Collector

SYNOPSIS
    Collector


SYNTAX
    Set-Collector [[-Session] <Object>] [-Collector] <Object> [-Passthru] [<CommonParameters>]


DESCRIPTION
    Set collector/s info.


PARAMETERS
    -Session <Object>

    -Collector <Object>

    -Passthru [<SwitchParameter>]

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>Set-Collector
```    

```powershell
NAME
    Set-Source

SYNOPSIS
    Source


SYNTAX
    Set-Source [[-Session] <Object>] [-Source] <Object> [-Passthru] [<CommonParameters>]


DESCRIPTION
    Edit sources.


PARAMETERS
    -Session <Object>

    -Source <Object>

    -Passthru [<SwitchParameter>]

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>Set-Source
```
