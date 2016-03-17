#requires -Version 4 -Modules Pester

. $PSScriptRoot\..\..\Private\VisualStudio\Extract-NugetPackageFromHintPath.ps1

Describe 'Extract-NugetPackageFromHintPath' {

    function ExtractNugetPackageFromHintPathAndAssert($hintpath, $expecteId, $expectedVersion) {
        $package = Extract-NugetPackageFromHintPath -HintPath $hintpath
        $package | Should Not BeNullOrEmpty
        $package.Id | Should Be $expecteId
        $package.Version | Should Be $expectedVersion
    }

    It 'should throw exception when HintPath is null or empty' {
      {Extract-NugetPackageFromHintPath -HintPath ''} | Should Throw
      {Extract-NugetPackageFromHintPath -HintPath $null} | Should Throw
    }

    It 'should handle a simple package name/number' {
        ExtractNugetPackageFromHintPathAndAssert 'packages\MyNugetPackage.1.2.3\lib\mydll' 'MyNugetPackage' '1.2.3'
        ExtractNugetPackageFromHintPathAndAssert 'packages\MyNugetPackage.1.2.3.4\lib\mydll' 'MyNugetPackage' '1.2.3.4'
    }

    It 'should handle a package with numbers at the end of its name' {
        ExtractNugetPackageFromHintPathAndAssert  'packages\MyNugetPackage32.1.2.3\lib\mydll' 'MyNugetPackage32' '1.2.3'
    }

    It 'should handle a package with dots in the name' {
        ExtractNugetPackageFromHintPathAndAssert  'packages\MyNugetPackage.Suffix.AnotherSuffix.1.2.3\lib\mydll' 'MyNugetPackage.Suffix.AnotherSuffix' '1.2.3'
    }

    It 'should handle a package with a version following semver v1' {
        ExtractNugetPackageFromHintPathAndAssert  'packages\MyNugetPackage.1.2.3-prerelease4\lib\mydll' 'MyNugetPackage' '1.2.3-prerelease4'
    }

    It 'should handle a package with a version following semver v2' {
        ExtractNugetPackageFromHintPathAndAssert  'packages\MyNugetPackage.1.2.3-prerelease.4+metadata\lib\mydll' 'MyNugetPackage' '1.2.3-prerelease.4+metadata'
    }

    #It 'should handle a single number version' {
    #    Get-DependencyVersionRange '1' | Should Be '[1]'
    #}
    #
    #It 'should handle a 3 part number version' {
    #    Get-DependencyVersionRange '1.2.3' | Should Be '[1.2.3, 2.0.0)'
    #}
    #
    #It 'should handle a 3 part number version with suffix' {
    #    Get-DependencyVersionRange '1.2.3-suffix' -verbose | Should Be '[1.2.3-suffix, 2.0.0-suffix)'
    #}
}
