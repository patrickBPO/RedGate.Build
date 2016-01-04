#requires -Version 4 -Modules Pester

. $PSScriptRoot\..\..\Private\ScriptParams\Get-ScriptParameters.ps1

Describe 'Get-ScriptParameters' {

    Context 'When a script has no parameter' {
        @"
[CmdletBinding()]
param()
Write-Output 'this is a script with no params'
"@  | Set-Content -Path 'TestDrive:\noparams.ps1'

        It 'should return nothing' {
            Get-ScriptParameters -File 'TestDrive:\noparams.ps1' | Should BeNullOrEmpty
        }
    }

    Context 'When a script has a single parameter' {
        @"
[CmdletBinding()]
param(
    [string] `$ThisIsMyParameter = 'default value'
)
Write-Output 'this is a script with 1 param'
"@  | Set-Content -Path 'TestDrive:\oneparam.ps1'

        It 'should return 1 parameter' {
            $result = @(Get-ScriptParameters -File 'TestDrive:\oneparam.ps1')
            $result.Count | Should Be 1
            $result[0].Name | Should Be 'ThisIsMyParameter'
            $result[0].ParameterType | Should Be 'string'
        }
    }

Context 'When a script has multiple parameters' {
        @"
[CmdletBinding()]
param(
    [string] `$ThisIsMyParameter = 'default value',
    [int] `$ThisIsMySecondParameter,
    [switch] `$WhatIf
)
Write-Output 'this is a script with 2 params'
"@  | Set-Content -Path 'TestDrive:\twoparams.ps1'

        It 'should return 2 parameters (and -WhatIf should be ignored)' {
            $result = @(Get-ScriptParameters -File 'TestDrive:\twoparams.ps1')
            $result.Count | Should Be 2
            $result[0].Name | Should Be 'ThisIsMyParameter'
            $result[0].ParameterType | Should Be 'string'
            $result[1].Name | Should Be 'ThisIsMySecondParameter'
            $result[1].ParameterType | Should Be 'int'
        }
    }
}
