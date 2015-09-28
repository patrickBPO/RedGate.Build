function Build-NUnitCommandLineArguments {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string] $AssemblyPath,
    [string[]] $ExcludedCategories = @(),
    [string[]] $IncludedCategories = @()
  )

  $additionalParams = @()
  #build the /exclude param:
  if($ExcludedCategories) {
    $additionalParams += "/exclude:" + ($ExcludedCategories -join ';')
  }

  if($IncludedCategories) {
    $additionalParams += "/include:" + ($IncludedCategories -join ';')
  }

  return $AssemblyPath,
    $additionalParams,
    "/result=`"$AssemblyPath.TestResult.xml`"",
    '/nologo',
    '/nodots',
    '/noshadow',
    '/labels',
    "/out:`"$AssemblyPath.TestOutput.txt`"",
    "/err:`"$AssemblyPath.TestError.txt`""

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
