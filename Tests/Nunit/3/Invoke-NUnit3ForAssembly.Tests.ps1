#requires -Version 4 -Modules Pester

$FullPathToModuleRoot = Resolve-Path $PSScriptRoot\..\..\..

Describe 'Invoke-NUnit3ForAssembly' {

    Context 'Nunit 2.6.4' {
        It "should throw Unexpected NUnit version" {
            { Invoke-NUnit3ForAssembly -Assembly 'myassembly.dll' -NUnitVersion '2.6.4' } | Should Throw "Unexpected NUnit version '2.6.4'. This function only supports Nunit v3"
        }
    }

}
