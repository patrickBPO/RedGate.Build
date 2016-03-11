#requires -Version 2 -Modules Pester

Describe 'New-TempDir' {

    Context 'A newly created temporary directory' {
        $TempDir = New-TempDir

        It 'should exist' {
            $TempDir | Should Exist
        }

        It 'should contain \.temp\' {
            $TempDir | Should Match '\\\.temp\\'
        }
    }
}
