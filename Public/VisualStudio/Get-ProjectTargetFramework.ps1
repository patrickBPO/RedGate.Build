<#
.SYNOPSIS
    Return the TargetFrameworkVersion value set in a VS project file

.DESCRIPTION
    Open the project file, read and return the value of TargetFrameworkVersion
#>
function Get-ProjectTargetFramework {
    param(
        # The path to a .csproj or .vbproj file. (msbuild format)
        [string] $ProjectFile
    )

    (([xml](Get-Content $ProjectFile)).project.propertygroup.TargetFrameworkVersion | select -first 1).tostring()
}
