#requires -Version 4 -Modules Pester

$FullPathToModuleRoot = Resolve-Path $PSScriptRoot\..\..\..

. "$FullPathToModuleRoot\Private\NUnit.ps1"

Describe 'Get-NUnitConsoleExePath' {

    Context 'Nunit 2.6.4' {
        $result = Get-NUnitConsoleExePath -NUnitVersion '2.6.4'

        It 'should return the right path' {
            $result | Should Be "$FullPathToModuleRoot\packages\NUnit.Runners.2.6.4\tools\nunit-console.exe"
        }
    }

    Context 'Nunit 2.6.4 -x86' {
        $result = Get-NUnitConsoleExePath -NUnitVersion '2.6.4' -x86

        It 'should return the right path' {
            $result | Should Be "$FullPathToModuleRoot\packages\NUnit.Runners.2.6.4\tools\nunit-console-x86.exe"
        }
    }

    Context 'Nunit 3.0.0' {
        It "should throw Unexpected NUnit version" {
            { Get-NUnitConsoleExePath -NUnitVersion '3.0.0' } | Should Throw "Unexpected NUnit version '3.0.0'. This function only supports Nunit v2"
        }
    }

}
