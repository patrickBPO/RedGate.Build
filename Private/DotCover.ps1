function Build-DotCoverCommandLineArguments
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string] $AssemblyPath,
    [string[]] $ExcludedCategories = @(),
    [string[]] $IncludedCategories = @(),
    [string] $DotCoverFilters,
    # The version of the nuget package containing the NUnit executables (NUnit.Runners)
    [string] $NUnitVersion = '2.6.2',
    #If set, return path to nunit-console-x86.exe.
    #By default, use nunit-console.exe
    [switch] $x86
  )

  $NunitArguments = (Build-NUnitCommandLineArguments `
    -AssemblyPath $AssemblyPath `
    -ExcludedCategories $ExcludedCategories `
    -IncludedCategories $IncludedCategories) `
    -replace '"', '\"'

  if( $DotCoverFilters) {
    $DotCoverFilters = "/Filters=$DotCoverFilters"
  }

  return "cover",
    "/TargetExecutable=`"$(Get-NUnitConsoleExePath -NUnitVersion $NUnitVersion -x86:$x86.IsPresent)`"",
    "/TargetArguments=`"$NunitArguments`"",
    "/Output=`"$AssemblyPath.coverage.snap`"",
    $DotCoverFilters
}

function Get-DotCoverExePath {
  [CmdletBinding()]
  param(
    # The version of the nuget package containing DotCover.exe (JetBrains.dotCover.CommandLineTools)
    [string] $DotCoverVersion = '3.2.0'
  )

  Write-Verbose "Using DotCover version $DotCoverVersion"
  $DotCoverFolder = Install-DotCoverPackage $DotCoverVersion

  "$DotCoverFolder\tools\dotcover.exe" | Resolve-Path
}
