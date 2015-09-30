function Build-NUnitCommandLineArguments {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string] $AssemblyPath,
    [string[]] $ExcludedCategories = @(),
    [string[]] $IncludedCategories = @(),
    [string] $TestResultFilenamePattern = 'TestResult'
  )

  $nugetParams = $AssemblyPath,
    "/result=`"$AssemblyPath.$TestResultFilenamePattern.xml`"",
    '/nologo',
    '/nodots',
    '/noshadow',
    '/labels',
    "/out:`"$AssemblyPath.TestOutput.txt`"",
    "/err:`"$AssemblyPath.TestError.txt`""

  #add the /exclude param if $ExcludedCategories is not empty:
  if($ExcludedCategories) {
    $nugetParams += "/exclude:$($ExcludedCategories -join ';')"
  }

  #add the /include param if $IncludedCategories is not empty:
  if($IncludedCategories) {
    $nugetParams += "/include:$($IncludedCategories -join ';')"
  }

  return $nugetParams
}

function Get-NUnitConsoleExePath {
  [CmdletBinding()]
  param(
    # The version of the nuget package containing the NUnit executables (NUnit.Runners)
    [string] $NUnitVersion = $DefaultNUnitVersion,

    #If set, return path to nunit-console-x86.exe.
    #By default, use nunit-console.exe
    [switch] $x86
  )

  $nunitExec = 'nunit-console.exe'
  if($x86.IsPresent) {
    $nunitExec = 'nunit-console-x86.exe'
  }

  Write-Verbose "Using NUnit version $NUnitVersion"
  $NUnitFolder = Install-NUnitPackage $NUnitVersion

  "$NUnitFolder\tools\$nunitExec" | Resolve-Path
}
