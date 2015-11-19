<#
.SYNOPSIS
  Update the dependencies versions inside a given nuspec file.
.DESCRIPTION
  Update the dependencies versions inside the nuspec files by looking
  at the list of nuget packages that are being used in the VS solution.
#>
function Update-NuspecDependenciesVersions {
    [CmdletBinding()]
    param(
        # The path to the .nuspec that is going to be updated
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeLine = $True)]
        [string] $NuspecFilePath,

        # A list of nuget packages.config file paths.
        [Parameter(Mandatory = $True, Position = 1)]
        [string[]] $PackagesConfigPaths,

        # A hashtable of package id/versions we DO want to override in the nuspec.
        [Hashtable] $PackageVersionOverride
    )

    begin {
        # Load the nuget packages
        $nugetPackages = Get-NugetPackagesFromConfigFiles -PackagesConfigPaths $PackagesConfigPaths

        # Add/Override packages using versions from $PackageVersionOverride
        if( $PackageVersionOverride ) {
            $PackageVersionOverride.Keys | ForEach {
                $packageToOverride = $nugetPackages | where Id -eq $_
                if($packageToOverride) {
                    # found existing package. Override its version
                    $packageToOverride.Version = $PackageVersionOverride[$_]
                } else {
                    #this package is not listed. Add it.
                    $nugetPackages += [PSCustomObject] @{
                        Id = $_
                        Version = $PackageVersionOverride[$_]
                    }
                }
            }
        }
    }

    process {
        Write-Verbose "Processing $NuspecFilePath"
        $NuspecFilePath = Resolve-Path $NuspecFilePath

        $nuspec = [xml] (Get-Content $NuspecFilePath)
        $nuspec.package.metadata.dependencies.group.dependency | ForEach {
            # Update the version of the dependency with the one from $nugetPackages
            $_.version = $nugetPackages |
                where Id -eq $_.id |
                select -ExpandProperty Version |
                Get-DependencyVersionRange
            Write-Verbose "Set dependency of $($_.id) to $($_.version)"
        }
        $nuspec.Save($NuspecFilePath)
        Write-Verbose "Processed $NuspecFilePath"
    }

}
