<#
.SYNOPSIS
    Return the OutputPath value set in a VS project file

.DESCRIPTION
    Open the project file, read and return the value of OutputPath
#>
function Get-ProjectTargetFramework {
    param(
        # The path to a .csproj or .vbproj file. (msbuild format)
        [string] $ProjectFile
    )

    (([xml](Get-Content $ProjectFile)).project.propertygroup.OutputPath | select -first 1).tostring()
}
