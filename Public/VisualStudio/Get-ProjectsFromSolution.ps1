<#
.SYNOPSIS
    List the projects from a Visual Studio solution file

.DESCRIPTION
    List all the projects from a Visual Studio solution file
    as well as display some of their property. (TargetFrameworkVersion)
#>
function Get-ProjectsFromSolution
{
    [CmdletBinding()]
    Param
    (
        # The path to a Visual Studio solution file (.sln)
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        $SolutionFile
    )
    Process
    {
        # Crude parameter checking
        $SolutionFile = Resolve-Path $SolutionFile

        # Project files are relative to the solution directory.
        # So get in the directory to be able to resolve project files path.
        Split-Path $SolutionFile | Push-Location
        try {

            # Trust me, this gets .[cs|vb]proj files referenced in $SolutionFile
            (
                ((Get-Content $SolutionFile) -like 'Project(*') | ForEach { ($_ -split ',')[1] }
            ) -like '*.*proj*' |
                ForEach {
                    $filepath = $_.Trim(' "')
                    [pscustomobject] @{
                        Project = (Resolve-Path $filepath).Path
                    }
                }
        } finally {
            Pop-Location
        }
    }
}
