function Get-NUnitConsoleExePath {
    [CmdletBinding()]
    param(
        # The version of the nuget package containing the NUnit executables (NUnit.Runners)
        [string] $NUnitVersion = $DefaultNUnitVersion,

        #If set, return path to nunit-console-x86.exe.
        #By default, use nunit-console.exe
        [switch] $x86
    )

    if(!$NunitVersion.StartsWith('2.')) {
        throw "Unexpected NUnit version '$NUnitVersion'. This function only supports Nunit v2"
    }

    $nunitExec = 'nunit-console.exe'
    if($x86.IsPresent) {
        $nunitExec = 'nunit-console-x86.exe'
    }

    Write-Verbose "Using NUnit version $NUnitVersion"
    $NUnitFolder = Install-NUnitPackage $NUnitVersion

    "$NUnitFolder\tools\$nunitExec" | Resolve-Path
}
