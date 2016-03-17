<#
.SYNOPSIS
Computes a list of nuget packages used by a Visual Studio project file.

.DESCRIPTION
The list of nuget package is generated based on the values of the <HintPath /> property
of every <reference /> used in the project.

This is useful to ensure that packages.config for our projects contain ALL the right nuget packages.

.EXAMPLE
'C:\myproject.csproj' | Get-ExpectedNugetPackagesFromProjectHintPaths
Retrieve the list of nuget packages that are likely to be used by myproject.csproj.
#>
function Get-NugetPackagesFromProject {
    [CmdletBinding()]
    param(
        # The path to a visual studio project. (.csproj or vbproj)
        # Msbuild format
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, Position = 0)]
        [string] $ProjectFilePath
    )

    process {
        #   get a list of nuget package id/version that are in used based on the values of HintPaths.
        Write-Verbose "loading $ProjectFilePath"
        $hintpaths = @(([xml](Get-Content $ProjectFilePath)).project.itemgroup.reference.hintpath | where { $_ -ne $null })

        $hintpaths | Extract-NugetPackageFromHintPath
    }
}
