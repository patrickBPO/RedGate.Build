<#
.SYNOPSIS
    Return the TargetFrameworkVersion value set in a VS project file

.DESCRIPTION
    Open the project file, read and return the value of TargetFrameworkVersion
#>
function Get-ProjectTargetFramework {
    [CmdletBinding()]
    param(
        # The path to a .csproj or .vbproj file. (msbuild format)
        [string] $ProjectFile
    )

    Write-Verbose "Project: $ProjectFile. Retrieving TargetFrameworkVersion"
    (([xml](Get-Content $ProjectFile)).project.propertygroup.TargetFrameworkVersion | select -first 1).tostring()
}
