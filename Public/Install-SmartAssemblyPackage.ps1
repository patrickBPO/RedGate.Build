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

  $SAFolder = Install-Package SmartAssembly $SmartAssemblyVersion

  if($env:TEAMCITY_VERSION -eq $null) {
    # Running on a dev machine, if the package contains a SmartAssembly.settings file, ignore it (by deleting it)
    #   (because SmartAssembly.settings Options could be set to connet to a central SQL database.
    #   and we don't want to pollute it with developer build data.)
    if(Test-Path "$SAFolder\tools\SmartAssembly.settings" ) {
      Remove-Item "$SAFolder\tools\SmartAssembly.settings" -Force | Out-Null
    }
  }

  $SAFolder
}
