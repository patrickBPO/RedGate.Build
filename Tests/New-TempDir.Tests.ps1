#requires -Version 2 -Modules Pester

Describe 'New-TempDir' {

    AfterAll {
        if (Test-Path "$env:Temp\RedGate.Build") {
            Remove-Item "$env:Temp\RedGate.Build" -Force -Recurse
        }
    }

    Context 'A newly created temporary directory' {
        $TempDir = New-TempDir

        It 'should exist' {
            $TempDir | Should Exist
        }

        It 'should reside inside "%TEMP%\RedGate.Build"' {
            ([System.IO.Path]::GetDirectoryName($TempDir)) | Should Be "$env:TEMP\RedGate.Build"
        }
    }
}
