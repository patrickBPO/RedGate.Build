#requires -Version 4 -Modules Pester

$FullPathToModuleRoot = Resolve-Path $PSScriptRoot\..\..

. "$FullPathToModuleRoot\Private\NUnit.ps1"

Describe 'Build-NUnitCommandLineArguments' {

    function Nunit2Parameters($assembly, $TestResult = 'TestResult') {
        "$assembly /result=`"$assembly.$TestResult.xml`" /out=`"$assembly.$TestResult.TestOutput.txt`" /err=`"$assembly.$TestResult.TestError.txt`" /nologo /nodots /noshadow /labels"
    }

    function Nunit3Parameters($assembly, $TestResult = 'TestResult') {
        "$assembly --result=`"$assembly.$TestResult.xml`" --out=`"$assembly.$TestResult.TestOutput.txt`" --err=`"$assembly.$TestResult.TestError.txt`" --noheader --labels=On"
    }

    Context 'Nunit 2.6.4 with minimum arguments' {
        $result = Build-NUnitCommandLineArguments `
            -AssemblyPath 'my-test-assembly.dll' `
            -NUnitVersion '2.6.4'

        It 'should return the right value' {
            $result -join ' ' | Should Be (Nunit2Parameters 'my-test-assembly.dll')
        }
    }

    Context 'Nunit 2.6.4 with all arguments' {
        $result = Build-NUnitCommandLineArguments `
            -AssemblyPath 'my-test-assembly.dll' `
            -NUnitVersion '2.6.4' `
            -x86 $true `
            -FrameworkVersion 'net-4.0' `
            -ExcludedCategories 'exclude1', 'exclude2' `
            -IncludedCategories 'include1', 'include2' `
            -TestResultFilenamePattern 'SpecialPattern'

        It 'should return the right value' {
            $result -join ' ' | Should Be "$(Nunit2Parameters 'my-test-assembly.dll' 'SpecialPattern') /framework=net-4.0 /exclude=exclude1;exclude2 /include=include1;include2"
        }
    }

    Context 'Nunit 3.0.0 with minimum arguments' {
        $result = Build-NUnitCommandLineArguments `
            -AssemblyPath 'my-test-assembly.dll' `
            -NUnitVersion '3.0.0'

        It 'should return the right value' {
            $result -join ' ' | Should Be (Nunit3Parameters 'my-test-assembly.dll')
        }
    }

    Context 'Nunit 3.0.0 with all arguments' {
        $result = Build-NUnitCommandLineArguments `
            -AssemblyPath 'my-test-assembly.dll' `
            -NUnitVersion '3.0.0' `
            -x86 $true `
            -FrameworkVersion 'net-4.0' `
            -ExcludedCategories 'exclude1', 'exclude2' `
            -IncludedCategories 'include1', 'include2' `
            -TestResultFilenamePattern 'SpecialPattern'

        It 'should return the right value' {
            $result -join ' ' | Should Be "$(Nunit3Parameters 'my-test-assembly.dll' 'SpecialPattern') --x86 --framework=net-4.0 --exclude=exclude1;exclude2 --include=include1;include2"
        }
    }
}
