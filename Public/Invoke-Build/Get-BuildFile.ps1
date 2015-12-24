<#
.SYNOPSIS
    Recursively find the first valid build script file in parent folders.
.DESCRIPTION
    Get-BuildFile looks for .build.ps1 or build.ps1 files.
    It looks in parent folders starting from the folder passed in as -CurrentFolder
    if -CurrentFolder is not set, Get-BuildFile will start from the folder where the RedGate.Build module is installed in.
#>
function Get-BuildFile {
    [CmdletBinding()]
    param(
        # The folder to start looking in for .build.ps1 or build.ps1 files.
        [Parameter(ValueFromPipeline)]
        [string] $CurrentFolder = $_ModuleDir
    )
    begin {
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -Name 'VerbosePreference'

        if(!$script:GetBuildFileStartingFolder) {
            $script:GetBuildFileStartingFolder = $CurrentFolder
        }
    }
    process {
        if([String]::IsNullOrEmpty($CurrentFolder)) {
            throw "Could not find a default .build.ps1 or build.ps1 file in $GetBuildFileStartingFolder or its parents. Giving up..."
        }

        Write-Verbose "Looking for default build file in $CurrentFolder"

        if(Test-Path "$CurrentFolder\.build.ps1") {
            return Get-Item "$CurrentFolder\.build.ps1"
        }
        if(Test-Path "$CurrentFolder\build.ps1") {
            return Get-Item "$CurrentFolder\build.ps1"
        }

        $CurrentFolder | Split-Path | Get-BuildFile
    }
    end {
        $script:GetBuildFileStartingFolder = $null
    }
}
