<#
.SYNOPSIS
    Return the OutputPath value set in a VS project file

.DESCRIPTION
    Open the project file, read and return the value(s) of OutputPath
#>
function Get-ProjectOutputPaths {
    param(
        # The path to a .csproj or .vbproj file. (msbuild format)
        [string] $ProjectFile
    )

    (LoadProjectFile $ProjectFile).Project.PropertyGroup.OutputPath | where { $_ -ne $null }
}
