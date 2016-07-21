#requires -Version 4 -Modules Pester

$FullPathToModuleRoot = Resolve-Path $PSScriptRoot\..\..\..

Describe 'Invoke-NUnitForAssembly' {

    Context 'Nunit 4.0' {
        It "should throw Unexpected NUnit version" {
            { Invoke-NUnitForAssembly -Assembly 'myassembly.dll' -NUnitVersion '4.0' } | Should Throw "Unexpected NUnit version '4.0'. This function only supports Nunit v2"
        }
    }

    Context 'Nunit 3.0' {
        It "should throw Unexpected NUnit version" {
            { Invoke-NUnitForAssembly -Assembly 'myassembly.dll' -NUnitVersion '3.0' } | Should Throw "NUnit version '3.0' is not supported by this function. Use Invoke-NUnit3ForAssembly instead."
        }
    }
}
