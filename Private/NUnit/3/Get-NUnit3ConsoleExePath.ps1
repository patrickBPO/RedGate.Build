function Get-NUnit3ConsoleExePath {
    [CmdletBinding()]
    param(
        # The version of the nuget package containing the NUnit executables (NUnit.Console)
        [string] $NUnitVersion
    )

    if(!$NunitVersion.StartsWith('3.')) {
        throw "Unexpected NUnit version '$NUnitVersion'. This function only supports Nunit v3"
    }

    Write-Verbose "Using NUnit version $NUnitVersion"
    $NUnitFolder = Install-NUnitPackage $NUnitVersion

    "$NUnitFolder\tools\nunit3-console.exe" | Resolve-Path
}
