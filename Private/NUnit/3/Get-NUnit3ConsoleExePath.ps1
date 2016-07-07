function Get-NUnit3ConsoleExePath {
    [CmdletBinding()]
    param(
        # The version of the nuget package containing the NUnit executables (NUnit.Console)
        [string] $NUnitVersion
    )
    
    Write-Verbose "Using NUnit version $NUnitVersion"
    $NUnitFolder = Install-NUnitPackage $NUnitVersion

    "$NUnitFolder\tools\nunit3.console.exe" | Resolve-Path
}
