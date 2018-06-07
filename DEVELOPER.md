# Developer Guide

This is the guide for developers who want contribute the code to this module. If you just want use this module in your environment, please refer to the [readme file](README.md).

## Prerequisite

- [Download](https://github.com/PowerShell/PowerShell) and install latest PowerShell Core environment (it's different from the PowerShell on Windows)
- Install and import necessary modules (for running test and doc generating)

```PowerShell
Install-Module -Name PSScriptAnalyzer
Install-Module -Name Pester
Install-Module -Name platyPS
Import-Module -Name PSScriptAnalyzer
Import-Module -Name Pester
Import-Module -Name platyPS
```

- Clone/Download this repository to a local directory, and start developing

## Before Submit PR

- Make sure unit test added under `src/test` for new feature
- Make sure in code help annotations updated
- Make sure module definition file (`src/main/SumoLogic-Core/SumoLogic-Core.psd1`) updated for exposing the feature
- Run unit test

```PowerShell
Invoke-Pester src/test
```

- Generate markdown help documents

```PowerShell
Import-Module ./src/main/SumoLogic-Core/SumoLogic-Core.psd1 -Force
New-MarkdownHelp -Module SumoLogic-Core -Force -OutputFolder docs
```
