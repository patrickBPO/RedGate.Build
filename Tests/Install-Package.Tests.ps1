#requires -Version 4 -Modules Pester

$FullPathToModuleRoot = Resolve-Path $PSScriptRoot\..

Describe 'Install-Package' {

    if(Test-Path "$FullPathToModuleRoot\packages") {
        Remove-Item "$FullPathToModuleRoot\packages" -Force -Recurse
    }

    Context 'Happy Path - NUnit.Runners' {
        $result = Install-Package -Name NUnit.Runners -Version 2.6.4

        It 'should install the package and return the full path to the folder where the package was installed to' {
            $result | Should Be "$FullPathToModuleRoot\packages\NUnit.Runners.2.6.4"
            $result | Should Exist
        }
    }

    Context 'Happy Path - 7-Zip.CommandLine' {
        $result = Install-Package -Name '7-Zip.CommandLine' -Version 9.20.0

        It 'should install the package and return the full path to the folder where the package was installed to' {
            $result | Should Be "$FullPathToModuleRoot\packages\7-Zip.CommandLine.9.20.0"
            $result | Should Exist
        }
    }

}
