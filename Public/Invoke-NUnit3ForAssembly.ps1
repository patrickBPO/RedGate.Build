<#
.SYNOPSIS
  Execute NUnit tests from a single assembly using NUnit 3
.DESCRIPTION
  1. Install required Nuget Packages to get nunit3-console.exe and dotcover.exe
  2. Use nunit3-console.exe and dotcover.exe to execute NUnit tests with dotcover coverage
.EXAMPLE
  Invoke-NUnit3ForAssembly -AssemblyPath .\bin\debug\test.dll -NUnitVersion '3.0.0'
    Execute the NUnit tests from test.dll using nunit 3.0.0 (nuget package will be installed if need be.).
.EXAMPLE
  Invoke-NUnit3ForAssembly -AssemblyPath .\bin\debug\test.dll -NUnitVersion '3.0.0' -EnableCodeCoverage
    Execute the NUnit tests from test.dll and wrap nunit3-console.exe with dotcover.exe to provide code coverage.
    Code coverage report will be saved as .\bin\debug\test.dll.coverage.snap
.NOTES
  See also: Merge-CoverageReports
#>
function Invoke-NUnit3ForAssembly {
  [CmdletBinding()]
  param(
    # The path of the assembly to execute tests from
    [Parameter(Mandatory=$true)]
    [string] $AssemblyPath,
    # The version of the nuget package containing the NUnit executables (NUnit.Console)
    [string] $NUnitVersion = '3.0.0',
    # If specified, pass --x86 to nunit3-console
    [switch] $x86,
    # If specified, Framework version to be used for tests. (pass --framework=XX to nunit3-console)
    [ValidateSet($null, 'mono', 'mono-4.0', 'net-2.0', 'net-3.5', 'net-4.0')]
    [string] $FrameworkVersion,
    # NUnit3 Test selection EXPRESSION indicating what tests will be run
    # example: "method =~ /DataTest*/ && cat = Slow"
    [string] $Where,
    # The pattern used to generate the test result filename.
    # For MyAssembly.Test.dll, if TestResultFilenamePattern is 'TestResult',
    # the test result filename would be 'MyAssembly.Test.dll.TestResult.xml'
    [string] $TestResultFilenamePattern = 'TestResult',
    # If set, enable code coverage using dotcover
    [bool] $EnableCodeCoverage = $false,
    # The version of the nuget package containing DotCover.exe (JetBrains.dotCover.CommandLineTools)
    [string] $DotCoverVersion = $DefaultDotCoverVersion,
    # The dotcover filters passed to dotcover.exe
    [string] $DotCoverFilters = '',
    # The dotcover filters passed to dotcover.exe
    [string] $DotCoverAttributeFilters = '',
    # If set, do not import test results automatically to Teamcity.
    # In this case it is the responsibility of the caller to call 'TeamCity-ImportNUnitReport "$AssemblyPath.$TestResultFilenamePattern.xml"'
    [switch] $DotNotImportResultsToTeamcity
  )

  Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -Name 'VerbosePreference'

  $AssemblyPath = Resolve-Path $AssemblyPath

  Write-Output "Executing tests from $AssemblyPath. (code coverage enabled: $EnableCodeCoverage)"

  try {

    $NunitArguments = Build-NUnit3CommandLineArguments `
      -AssemblyPath $AssemblyPath `
      -x86 $x86.IsPresent `
      -FrameworkVersion $FrameworkVersion `
      -TestResultFilenamePattern $TestResultFilenamePattern

    $NunitExecutable = Get-NUnit3ConsoleExePath -NUnitVersion $NUnitVersion

    if( $EnableCodeCoverage ) {

      Invoke-DotCoverForExecutable `
        -TargetExecutable $NunitExecutable `
        -TargetArguments $NunitArguments `
        -OutputFile "$AssemblyPath.$TestResultFilenamePattern.coverage.snap" `
        -DotCoverVersion $DotCoverVersion `
        -Filters $DotCoverFilters `
        -AttributeFilters $DotCoverAttributeFilters

    } else {

      Execute-Command {
        & $NunitExecutable $NunitArguments
      }

    }

  } finally {
    if(-not $DotNotImportResultsToTeamcity.IsPresent) {
      TeamCity-ImportNUnitReport "$AssemblyPath.$TestResultFilenamePattern.xml"
    }

    # Tell teamcity to keep our test output logs as well. This could come in handy
    $assemblyFilename = Split-Path $AssemblyPath -Leaf
    # $AssemblyPath.$TestResultFilenamePattern.*x* ? That's a horrible way to only get the .xml and .txt file in 1 line.
    # (and skip the *.coverage.snap file if any)
    # Teamcity doesn't seem to let you add files to an existing zipped file.... oh well...
    TeamCity-PublishArtifact "$AssemblyPath.$TestResultFilenamePattern.*x* => logs/tests/$assemblyFilename.$TestResultFilenamePattern/logs.zip"
  }

}
