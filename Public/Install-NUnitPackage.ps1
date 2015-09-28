function Install-NUnitPackage {
  [CmdletBinding()]
  param(
    # The version of the nuget package containing the NUnit executables (NUnit.Runners)
    [string] $Version = '2.6.2'
  )

  Install-Package NUnit.Runners $Version
}
