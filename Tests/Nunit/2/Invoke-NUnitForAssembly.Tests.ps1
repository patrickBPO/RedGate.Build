#requires -Version 4 -Modules Pester

$FullPathToModuleRoot = Resolve-Path $PSScriptRoot\..\..\..

Describe 'Invoke-NUnitForAssembly' {

    $tempFolder = New-Item "$FullPathToModuleRoot\.temp\nunit" -ItemType Directory -Force -Verbose

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

    function Compile-NUnitTests() {
        Install-Package -Name NUnit.Runners -Version 2.6.4
        $nunit = "$FullPathToModuleRoot\packages\NUnit.Runners.2.6.4"
        @'
using NUnit.Framework;

namespace Tests
{
    [TestFixture]
    public class SampleTests
    {
        [Test] public void AlwaysGreen() {}
    }
}
'@  | Out-File $tempFolder\nunit-test.cs

        Copy-Item $nunit\tools\nunit.framework.dll -Destination $tempFolder
        $compiler = 'C:\Program Files (x86)\MSBuild\14.0\Bin\csc.exe'
        $compiler | Should Exist
        & $compiler /target:library /out:$tempFolder\nunit-test.dll $tempFolder\nunit-test.cs /reference:$tempFolder\nunit.framework.dll 2>&1 > $tempFolder\nunit-test.out.txt
        $LASTEXITCODE | Should Be 0
    }

    Context 'Run real NUnit tests' {
        Compile-NUnitTests

        It 'Should not throw exceptions when TestResultFilenamePattern is empty' {
            Invoke-NUnitForAssembly `
                -AssemblyPath $tempFolder\nunit-test.dll `
                -NUnitVersion '2.6.4' `
                -TestResultFilenamePattern $null
        }

    }
}
