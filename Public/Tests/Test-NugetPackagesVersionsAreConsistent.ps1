#requires -Version 4.0

<#
.SYNOPSIS
  Test for nuget packages having duplicate versions accross a list of packages.config
.DESCRIPTION
  From a list of packages.config file, test for nuget packages
  that are listed with more than a single version.
  If packages with more than a single version are found, an exception is thrown.
.EXAMPLE
  Test-NugetPackagesVersionsAreConsistent -PackagesConfigPaths 'project1\packages.config', 'project2\packages.config'
  Will throw an error if one or more nuget packages are used in both project1 and project2 with 2 different versions.
.EXAMPLE
  Test-NugetPackagesVersionsAreConsistent -PackagesConfigPaths (Get-ChildItem D:\myproject packages.config -Recurse | select -ExpandProperty fullname)
  Will throw an error if one or more nuget packages are used in all the packages.config files recursively found under the D:\myproject folder.
#>
function Test-NugetPackagesVersionsAreConsistent {
  [CmdletBinding()]
  param(
    # A list of nuget packages.config file paths.
    [Parameter(Mandatory = $True, Position = 0)]
    [string[]] $PackagesConfigPaths
  )

  $nugetPackages = Get-NugetPackagesFromConfigFiles -PackagesConfigPaths $packagesConfigs

  # Get all packages that have more than 1 version.
  $packagesWithInconsistentVersions = $nugetPackages | where { $id = $_.Id; return @($nugetPackages | ? id -eq $id ).count -gt 1 }

  if($packagesWithInconsistentVersions) {
    throw @"
Some nuget packages with inconsistent versions were found:

$($packagesWithInconsistentVersions | Out-String)
"@
  }
}
