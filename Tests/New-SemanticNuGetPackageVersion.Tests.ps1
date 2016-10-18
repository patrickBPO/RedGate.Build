#requires -Version 2 -Modules Pester

Describe 'New-SemanticNuGetPackageVersion' {
    Context 'When IsDefaultBranch is true' {
        It 'should return a semantic version for a 3-part version' {
            New-SemanticNuGetPackageVersion -Version '1.3.5' -IsDefaultBranch $True -BranchName 'master' | Should Be '1.3.5'
        }
        It 'should return a semantic version for a 4-part version, ignoring the revision number' {
            New-SemanticNuGetPackageVersion -Version '1.3.5.7' -IsDefaultBranch $True -BranchName 'master' | Should Be '1.3.5'
        }
    }
    Context 'For a 3-part version number, when IsDefaultBranch is false' {
        It 'should return a semantic version with branch suffix' {
            New-SemanticNuGetPackageVersion -Version '1.3.5' -IsDefaultBranch $False -BranchName 'SomeBranch' | Should Be '1.3.5-SomeBranch'
        }
        It 'should return a semantic version with truncated branch suffix, for a long branch name' {
            New-SemanticNuGetPackageVersion -Version '1.3.5' -IsDefaultBranch $False -BranchName 'SomeBranchSomeBranchSomeBranch' | Should Be '1.3.5-SomeBranchSomeBranch'
        }
    }
    Context 'For a 4-part version number, when IsDefaultBranch is false' {
        It 'should return a semantic version with branch suffix that includes the revision number' {
            New-SemanticNuGetPackageVersion -Version '1.3.5.7' -IsDefaultBranch $False -BranchName 'SomeBranch' | Should Be '1.3.5-SomeBranch0007'
        }
        It 'should return a semantic version with branch suffix that includes the revision number with fewer digits, when the revision suffix length is reduced' {
            New-SemanticNuGetPackageVersion -Version '1.3.5.7' -IsDefaultBranch $False -BranchName 'SomeBranch' -RevisionSuffixLength 2 | Should Be '1.3.5-SomeBranch07'
        }
        It 'should return a semantic version with branch suffix that excludes the revision number, when the revision suffix length is zero' {
            New-SemanticNuGetPackageVersion -Version '1.3.5.7' -IsDefaultBranch $False -BranchName 'SomeBranch' -RevisionSuffixLength 0 | Should Be '1.3.5-SomeBranch'
        }
        It 'should return a semantic version with truncated branch suffix that includes the revision number, for a long branch name' {
            New-SemanticNuGetPackageVersion -Version '1.3.5.7' -IsDefaultBranch $False -BranchName 'SomeBranchSomeBranchSomeBranch' | Should Be '1.3.5-SomeBranchSomeBr0007'
        }
        It 'should return a semantic version with branch suffix that excludes the revision number, when the revision suffix length is zero' {
            New-SemanticNuGetPackageVersion -Version '1.3.5.7' -IsDefaultBranch $False -BranchName 'SomeBranch' -RevisionSuffixLength 0 | Should Be '1.3.5-SomeBranch'
        }
    }
    Context 'Parameter validation' {
        It 'should throw for a null Version' {
            { New-SemanticNuGetPackageVersion -Version $Null -IsDefaultBranch $True -BranchName 'master' } | Should Throw
        }
        It 'should throw for a 2-part Version' {
            { New-SemanticNuGetPackageVersion -Version '1.3' -IsDefaultBranch $True -BranchName 'master' } | Should Throw
        }
        It 'should throw for a null BranchName' {
            { New-SemanticNuGetPackageVersion -Version '1.3.5' -IsDefaultBranch $True -BranchName $Null } | Should Throw
        }
        It 'should throw for an empty BranchName' {
            { New-SemanticNuGetPackageVersion -Version '1.3.5' -IsDefaultBranch $True -BranchName '' } | Should Throw
        }
        It 'should throw for a negative RevisionSuffixLength' {
            { New-SemanticNuGetPackageVersion -Version '1.3.5' -IsDefaultBranch $True -BranchName 'master' -RevisionSuffixLength -1 } | Should Throw
        }
        It 'should throw for an excessively large RevisionSuffixLength' {
            { New-SemanticNuGetPackageVersion -Version '1.3.5' -IsDefaultBranch $True -BranchName 'master' -RevisionSuffixLength 7 } | Should Throw
        }
    }
}
