#requires -Version 2 -Modules Pester

Describe 'New-NuGetPackageVersion' {
    Context 'When IsDefaultBranch is true' {
        It 'should return the Version' {
            New-NuGetPackageVersion -Version '1.2.3.4' -IsDefaultBranch $True -BranchName 'master' | Should Be '1.2.3.4'
        }
    }
    Context 'When IsDefaultBranch is false' {
        it 'should throw when BranchName is empty' {
            { New-NuGetPackageVersion -Version '1.2.3.4' -IsDefaultBranch $False -BranchName '' } | Should Throw
        }
        it 'should use the BranchName without the revision number as the pre-release suffix' {
            New-NuGetPackageVersion -Version '1.2.3.4' -IsDefaultBranch $False -BranchName 'SomeBranch' | Should Be '1.2.3.4-SomeBranch'
        }
        it 'should shorten the pre-release suffix (by truncating) if the BranchName is too long' {
            New-NuGetPackageVersion -Version '1.2.3.4' -IsDefaultBranch $False -BranchName 'SomeBranchNameThatsTooLong' | Should Be '1.2.3.4-SomeBranchNameThatsT'
        }
        it 'should replace "/" in the pre-release suffix by "-"' {
            New-NuGetPackageVersion -Version '1.2.3.4' -IsDefaultBranch $False -BranchName 'build/fixing-it' | Should Be '1.2.3.4-build-fixing-it'
        }
        it 'should remove invalid characters from the pre-release suffix' {
            New-NuGetPackageVersion -Version '1.2.3.4' -IsDefaultBranch $False -BranchName 'invalid\\$%£/chars;+=_' | Should Be '1.2.3.4-invalid-chars'
        }
    }
}
