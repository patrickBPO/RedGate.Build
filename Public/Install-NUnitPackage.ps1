<#
.SYNOPSIS
  Install NUnit.Runners to RedGate.Build\packages
.DESCRIPTION
  Install the NUnit.Runners nuget package to RedGate.Build\packages
#>
function Install-NUnitPackage {
  [CmdletBinding()]
  param(
    # The version of the nuget package containing the NUnit executables (NUnit.Runners)
    [string] $Version = $DefaultNUnitVersion
  )
 
  $packageName = "NUnit.Console" #Contains exe from 3.0 onwards
  if ($Version.StartsWith("2.")) {
    $packageName = "NUnit.Runners"
  }
  Install-Package $packageName $Version
}
