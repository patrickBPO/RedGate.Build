#requires -Version 4 -Modules Pester

Describe 'Format-WarningsAndErrors' {
    
    Context 'When InputObject is not an error or a warning' {
        It 'should return InputObject unchanged - $null' {
            Format-WarningsAndErrors -InputObject $null | Should Be $null
        }
        It 'should return InputObject unchanged - empty string' {
            Format-WarningsAndErrors -InputObject '' | Should Be $null
        }
        It 'should return InputObject unchanged - non-empty string' {
            Format-WarningsAndErrors -InputObject 'allez les bleus' | Should Be 'allez les bleus'
        }
    }

    Context 'When InputObject contains a warning' {
        It 'should not return any pipeline output' {
            Format-WarningsAndErrors `
                -InputObject 'myfile.cs(10,2) : warning LALA123 : why bother ? We''ll probably ignore it anyway...' `
                -WarningAction SilentlyContinue | Should Be $null
        }
        It 'should return InputObject as a warning' {
            Format-WarningsAndErrors `
                -InputObject 'myfile.cs(10,2) : warning LALA123 : why bother ? We''ll probably ignore it anyway...' `
                -WarningAction Continue 3>&1 | Should Be 'myfile.cs(10,2) : warning LALA123 : why bother ? We''ll probably ignore it anyway...'
        }
    }

    Context 'When InputObject contains an error' {
        It 'should not return any pipeline output' {
            Format-WarningsAndErrors `
                -InputObject 'myfile.cs(10,2) : error LALA123 : Arrrgggghhh Who broke the build ??' `
                -ErrorAction SilentlyContinue | Should Be $null
        }
        It 'should return InputObject as a warning' {
            Format-WarningsAndErrors `
                -InputObject 'myfile.cs(10,2) : error LALA123 : Arrrgggghhh Who broke the build ??' `
                -ErrorAction Continue 2>&1 | Should Be 'myfile.cs(10,2) : error LALA123 : Arrrgggghhh Who broke the build ??'
        }
    }

    Context 'When Pipeline is used' {
        It 'should process all the pipeline' {
            'line 1', 'line 2' | Format-WarningsAndErrors | Should Be @('line 1', 'line 2')
        }
        It 'should process multiple warnings and errors' {
            'line 1',
            'myfile.cs(10,2) : warning LALA123 : why bother ? We''ll probably ignore it anyway...',
            'myfile.cs(10,2) : error LALA123 : Arrrgggghhh Who broke the build ??' |
                Format-WarningsAndErrors -ErrorAction Continue -WarningAction Continue *>&1 |
                Should Be @(
                    'line 1',
                    'myfile.cs(10,2) : warning LALA123 : why bother ? We''ll probably ignore it anyway...',
                    'myfile.cs(10,2) : error LALA123 : Arrrgggghhh Who broke the build ??'
                )
        }
    }
}
