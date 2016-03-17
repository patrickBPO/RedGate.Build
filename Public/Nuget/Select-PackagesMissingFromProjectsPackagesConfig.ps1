<#
.SYNOPSIS
List the nuget packages that are missing from a VS project's packages.config file.
.DESCRIPTION
This guesses what packages should be referenced based on the values of the <HintPath /> properties.
#>
function Select-PackagesMissingFromProjectsPackagesConfig {
    [CmdletBinding()]
    param(
        # The path to a .vbproj or .csproj file. (Visual Studio, msbuild format)
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, Position = 0)]
        [string] $ProjectFile
    )
    process {

        Write-Verbose "Processing project: $ProjectFile"

        # Load the nuget packages from packages.config
        $nugetPackageFile = $ProjectFile | Split-Path | Join-Path -ChildPath packages.config
        $nugetPackagesFromConfig = Get-NugetPackagesFromConfigFiles -PackagesConfigPaths $nugetPackageFile -verbose:$false -ErrorAction Continue

        $nugetPackagesFromProject = $ProjectFile | Get-NugetPackagesFromProject
        # find expected packages that are missing from packages.config
        $nugetPackagesFromProject | foreach {
            $expectedPackage = $_
            if( ($nugetPackagesFromConfig | where { $_.Id -eq $expectedPackage.Id -and $_.Version -eq $expectedPackage.Version }) -eq $null) {
                # We can't find this package in packages.config. Output it.
                $expectedPackage
            }
        }
    }
}
