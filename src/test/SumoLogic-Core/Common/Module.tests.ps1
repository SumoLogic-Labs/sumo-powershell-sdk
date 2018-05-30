. $PSScriptRoot/Global.ps1
. $ModuleRoot/Lib/Definitions.ps1

$exportedCommands = (Get-Command -Module $ModuleName)
$docRoot = Get-Item "$TestRoot\..\..\..\docs"

Describe "$($ModuleName) Module" {
  It "should be loaded" {
    Get-Module $ModuleName | Should Not BeNullOrEmpty
  }

  It "should contains expected commands" {
    $exportedCommands.Length | Should Be 16
  }

  foreach ($command in $exportedCommands) {
    Context $command {
      It "should have proper in-module help" {
        $help = Get-Help $command.Name
        $help.description | Should Not BeNullOrEmpty
        $help.Synopsis | Should Not BeNullOrEmpty
        $help.examples | Should Not BeNullOrEmpty
        $help.relatedLinks.navigationLink.uri[0] | Should Be "https://github.com/SumoLogic/sumo-powershell-sdk/blob/master/docs/$command.md"
      }

      It "should have proper online help" {
        $helpFile = Get-Item (Join-Path $docRoot "$command.md")
        $helpFile.Exists | Should Be $true
        $text = Get-Content $helpFile -Raw
        $text.Contains("{{") | Should Be $false
      }
    }
  }
}
