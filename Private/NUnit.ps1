function Build-NUnitCommandLineArguments {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string] $AssemblyPath,
        [Parameter(Mandatory=$true)]
        [string] $NUnitVersion,
        [string] $FrameworkVersion,
        [string[]] $ExcludedCategories = @(),
        [string[]] $IncludedCategories = @(),
        [string] $TestResultFilenamePattern = 'TestResult'
    )

    if($NUnitVersion.StartsWith("2.")){
        $paramPrefix = "/"
    } else {
        $paramPrefix = "--"
    }

    $params = $AssemblyPath,
        "$($paramPrefix)result=`"$AssemblyPath.$TestResultFilenamePattern.xml`"",
        "$($paramPrefix)out=`"$AssemblyPath.$TestResultFilenamePattern.TestOutput.txt`"",
        "$($paramPrefix)err=`"$AssemblyPath.$TestResultFilenamePattern.TestError.txt`""

    if($NUnitVersion.StartsWith("2.")) {
        $params += '/nologo',
        '/nodots',
        '/noshadow',
        '/labels'
    } else {
        $params += '--noheader',
            '--labels=On'
    }

    if($FrameworkVersion) {
        $params += "$($paramPrefix)framework=$FrameworkVersion"
    }

    #add the /exclude param if $ExcludedCategories is not empty:
    if($ExcludedCategories) {
        $params += "$($paramPrefix)exclude=$($ExcludedCategories -join ';')"
    }

    #add the /include param if $IncludedCategories is not empty:
    if($IncludedCategories) {
        $params += "$($paramPrefix)include=$($IncludedCategories -join ';')"
    }

    return $params
}

function Get-NUnitConsoleExePath {
    [CmdletBinding()]
    param(
        # The version of the nuget package containing the NUnit executables (NUnit.Runners)
        [string] $NUnitVersion = $DefaultNUnitVersion,

        # If set, return path to nunit-console-x86.exe.
        # By default, use nunit-console.exe.
        # Note that this will not do anything if -NUnitVersion is 3+.
        # That's because there is not nunit3-console-x86.exe. (instead nunit3-console.exe takes a --x86 parameter)
        [switch] $x86
    )

	$nunitBase = 'nunit'
	if (!$NUnitVersion.StartsWith("2.")) {
		# Version 3 puts the major version in front, let's assume that's a trend
		$nunitBase += $NUnitVersion.Split(".")[0]
	}

	$nunitConsole = '-console'
    if($x86.IsPresent -and $NUnitVersion.StartsWith("2.")) {
        $nunitConsole += '-x86'
    }

    $nunitExec = $nunitBase + $nunitConsole + '.exe'

    Write-Verbose "Using NUnit version $NUnitVersion"
    $NUnitFolder = Install-NUnitPackage $NUnitVersion

    "$NUnitFolder\tools\$nunitExec" | Resolve-Path
}
