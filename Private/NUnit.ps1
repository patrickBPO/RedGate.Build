function Build-NUnitCommandLineArguments {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string] $AssemblyPath,
        [string] $FrameworkVersion,
        [string[]] $ExcludedCategories = @(),
        [string[]] $IncludedCategories = @(),
        [string] $TestResultFilenamePattern = 'TestResult'
    )

    $params = $AssemblyPath,
        "/result=`"$AssemblyPath.$TestResultFilenamePattern.xml`"",
        '/nologo',
        '/nodots',
        '/noshadow',
        '/labels',
        "/out:`"$AssemblyPath.$TestResultFilenamePattern.TestOutput.txt`"",
        "/err:`"$AssemblyPath.$TestResultFilenamePattern.TestError.txt`""

    if($FrameworkVersion) {
        $params += "/framework:$FrameworkVersion"
    }

    #add the /exclude param if $ExcludedCategories is not empty:
    if($ExcludedCategories) {
        $params += "/exclude:$($ExcludedCategories -join ';')"
    }

    #add the /include param if $IncludedCategories is not empty:
    if($IncludedCategories) {
        $params += "/include:$($IncludedCategories -join ';')"
    }

    return $params
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
	
	$nunitBase = 'nunit'
	if (!$NUnitVersion.StartsWith("2.")) {
		# Version 3 puts the major version in front, let's assume that's a trend
		$nunitBase += $NUnitVersion.Split(".")[0]
	}
	
	$nunitConsole = '-console'
    if($x86.IsPresent) {
        $nunitConsole += '-x86'
    }	
	
    $nunitExec = $nunitBase + $nunitConsole + '.exe'

    Write-Verbose "Using NUnit version $NUnitVersion"
    $NUnitFolder = Install-NUnitPackage $NUnitVersion

    "$NUnitFolder\tools\$nunitExec" | Resolve-Path
}
