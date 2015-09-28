function Install-Package {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string] $Name,
    [Parameter(Mandatory=$true)]
    [string] $Version
  )
  # Always display the verbose stream so that we don't lose the nuget output. It could prove handy when things go wrong.
  $local:VerbosePreference = 'Continue'

  if( -not(Test-Path "$PackagesDir\$Name.$Version")) {
    # Install the package (only if not already there). Print any nuget.exe output to the verbose stream
    & $NugetExe install $Name -Version $Version -OutputDirectory $PackagesDir -PackageSaveMode nuspec | Write-Verbose
  }

  # Return the folder where the package was installed
  "$PackagesDir\$Name.$Version" | Resolve-Path
}
