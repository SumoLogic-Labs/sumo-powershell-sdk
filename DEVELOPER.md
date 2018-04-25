# Developer Guide
This is the guide for developers who want contribute the code to this module. If you just want use this module in your environment, please refer to the [readme file](README.md).

## Prerequisite
  * [Download](https://github.com/PowerShell/PowerShell) and install latest PowerShell Core environment (it's different from the PowerShell on Windows)
  * Install and import necessary modules (for running test and doc generating)
  ```PowerShell
  PS >Install-Module -Name PSScriptAnalyzer
  PS >Install-Module -Name Pester
  PS >Install-Module -Name platyPS
  PS >Import-Module -Name PSScriptAnalyzer
  PS >Import-Module -Name Pester
  PS >Import-Module -Name platyPS
  ```
  * Clone/Download this repository to a local directory, and start developing
  * Make sure unit test added under `src/test` for new feature
  * Make sure in code help doc updated
  * Make sure module definition file (`src/main/SumoLogic-Core/SumoLogic-Core.psd1`) updated for exposing the feature
  * Unit test passed
  ```PowerShell
  PS >Invoke-Pester src/test
  ```
  * Generate mark-down help documents
  ```PowerShell
  PS >Import-Module ./src/main/SumoLogic-Core/SumoLogic-Core.psd1
  PS >New-MarkdownHelp -Module SumoLogic-Core -OutputFolder docs
  ```
