function Get-SmartAssemblyComPath {
  [CmdletBinding()]
  param(
    # The version of the nuget package containing the Smart Assembly executables
    [string] $SmartAssemblyVersion = $_DefaultSmartAssemblyVersion
  )

  Write-Verbose "Using Smart Assembly version $SmartAssemblyVersion"
  $SAFolder = Install-SmartAssemblyPackage $SmartAssemblyVersion

  "$SAFolder\tools\smartassembly.com" | Resolve-Path
}
