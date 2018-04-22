. $PSScriptRoot/Global.ps1
. $ModuleRoot/Lib/Definitions.ps1

$exportedCommands = (Get-Command -Module $ModuleName)

Describe "$($ModuleName) Module" {
  It "should be loaded" {
    Get-Module $ModuleName | Should Not BeNullOrEmpty
  }

  It "should contains expected commands" {
    $exportedCommands.Length | Should Be 16
  }

  foreach ($command in $exportedCommands) {
    Context $command {
      It "should have proper help" {
        $help = Get-Help $command.Name
        $help.description | Should Not BeNullOrEmpty
        $help.Synopsis | Should Not BeNullOrEmpty
        $help.examples | Should Not BeNullOrEmpty
      }
    }
  }
}
