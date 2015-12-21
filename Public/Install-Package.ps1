<#
.SYNOPSIS
  Install a Nuget Package to the RedGate.Build\packages\ folder
.DESCRIPTION
  Install a Nuget Package to the RedGate.Build\packages folder
  and return the full path of the folder where the package was extracted to.
#>
function Install-Package {
  [CmdletBinding()]
  param(
    # The name/id of the nuget package to install
    [Parameter(Mandatory=$true)]
    [string] $Name,
    # The version of the nuget package to install
    [Parameter(Mandatory=$true)]
    [string] $Version
  )

  if( -not(Test-Path "$PackagesDir\$Name.$Version")) {
    # Install the package (only if not already there). Print any nuget.exe output to the verbose stream
    Write-Verbose "Installing $Name.$Version to $PackagesDir" -verbose
    Execute-Command -ScriptBlock {
      & $NugetExe install $Name -Version $Version -OutputDirectory $PackagesDir -PackageSaveMode nuspec | Write-Verbose
    }
  }

  # Return the folder where the package was installed
  "$PackagesDir\$Name.$Version" | Resolve-Path
}
