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

    $nunit3ActualPackageName = "NUnit.ConsoleRunner"
    if ($NUnitVersion.StartsWith("3.0") -or $NUnitVersion.StartsWith("3.1")) {
      $nunit3ActualPackageName = "NUnit.Console"
    }

    # The nunit 3 console runner is actually in NUnit.ConsoleRunner.*
    "$NUnitFolder\..\$nunit3ActualPackageName.$NUnitVersion\tools\nunit3-console.exe" | Resolve-Path
}
