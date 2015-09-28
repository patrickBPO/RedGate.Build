function Invoke-NUnitForAssembly {
  [CmdletBinding()]
  param(
    # The path of the assembly to execute tests from
    [Parameter(Mandatory=$true)]
    [string] $AssemblyPath,
    # The version of the nuget package containing the NUnit executables (NUnit.Runners)
    [string] $NUnitVersion = '2.6.2',
    # Whether to use nunit x86 or nunit x64 (default)
    [switch] $x86,
    # A list of excluded test categories
    [string[]] $ExcludedCategories = @(),
    # A list of incuded test categories
    [string[]] $IncludedCategories = @(),
    # If set, enable code coverage using dotcover
    [bool] $EnableCodeCoverage = $false,
    # The version of the nuget package containing DotCover.exe (JetBrains.dotCover.CommandLineTools)
    [string] $DotCoverVersion = '3.2.0',
    # The dotcover filters passed to dotcover.exe
    [string] $DotCoverFilters = '',
    # If set, do not import test results automatically to Teamcity.
    # In this case it is the responsibility of the caller to call 'TeamCity-ImportNUnitReport "$AssemblyPath.TestResult.xml"'
    [switch] $DotNotImportResultsToTeamcity
  )

  $AssemblyPath = Resolve-Path $AssemblyPath

  Write-Output "Executing tests from $AssemblyPath. (code coverage enabled: $EnableCodeCoverage)"

  try {

    if( $EnableCodeCoverage ) {

      $DotCoverArguments = Build-DotCoverCommandLineArguments -AssemblyPath $AssemblyPath `
        -ExcludedCategories $ExcludedCategories `
        -IncludedCategories $IncludedCategories `
        -DotCoverFilters $DotCoverFilters `
        -NUnitVersion $NUnitVersion `
        -x86:$x86.IsPresent

      Execute-Command (Get-DotCoverExePath -DotCoverVersion $DotCoverVersion) $DotCoverArguments

    } else {

      $NunitArguments = Build-NUnitCommandLineArguments `
        -AssemblyPath $AssemblyPath `
        -ExcludedCategories $ExcludedCategories `
        -IncludedCategories $IncludedCategories

      Execute-Command (Get-NUnitConsoleExePath -NUnitVersion $NUnitVersion -x86:$x86.IsPresent) $NunitArguments

    }

  } finally {
    if(-not $DotNotImportResultsToTeamcity.IsPresent) {
      TeamCity-ImportNUnitReport "$AssemblyPath.TestResult.xml"
    }
  }

}
