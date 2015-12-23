#requires -Version 4.0

<#
.SYNOPSIS
  Returns all the nuget packages listed in a list of packages.config
.DESCRIPTION
  Read all the packages.config files and return a list of Nuget packages
.EXAMPLE
  Get-NugetPackagesFromConfigFiles -PackagesConfigPaths 'project1\packages.config', 'project2\packages.config'
  Returns all the packages listed in both project1\packages.config and project2\packages.config
#>
function Get-NugetPackagesFromConfigFiles {
    [CmdletBinding()]
    param(
        # A list of nuget packages.config file paths.
        [Parameter(Mandatory = $True, Position = 0)]
        [string[]] $PackagesConfigPaths
    )

    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -Name 'VerbosePreference'

    $packagesConfigs = @(Resolve-Path $PackagesConfigPaths)

    $nugetPackages = $packagesConfigs | ForEach {
        # get the nuget packages from the package config file
        ([xml](Get-Content $_)).packages.package | ForEach {
          [pscustomobject] @{
            Id=$_.id
            Version=$_.version
          }
        }
    } | Sort Id, Version -Unique

    Write-Verbose @"
All nuget packages found:

$($nugetPackages | Out-String)
"@

    $nugetPackages
}
