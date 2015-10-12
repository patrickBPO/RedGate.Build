<#
.SYNOPSIS
  Install SmartAssembly to RedGate.Build\packages
#>
function Install-SmartAssemblyPackage {
  [CmdletBinding()]
  param(
    # The version of the nuget package containing the Smart Assembly executables
    [string] $SmartAssemblyVersion = $DefaultSmartAssemblyVersion
  )

  Install-Package SmartAssembly $SmartAssemblyVersion
}
