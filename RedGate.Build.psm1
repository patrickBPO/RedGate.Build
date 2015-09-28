[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

Import-Module $PSScriptRoot\Private\teamcity.psm1 -DisableNameChecking

"$PSScriptRoot\Private\" |
    Resolve-Path |
    Get-ChildItem -Filter *.ps1 -Recurse |
    ForEach {
      . $_.FullName
    }

"$PSScriptRoot\Public\" |
    Resolve-Path |
    Get-ChildItem -Filter *.ps1 -Recurse |
    ForEach {
      . $_.FullName
      Export-ModuleMember -Function $_.BaseName
    }


if ($Host.Name -ne "Default Host") {
  Write-Host "RedGate.Build is using its own nuget.exe. Version $((Get-Item $nugetExe).VersionInfo.FileVersion)"
}

Export-ModuleMember -Function TeamCity-*

# For debug purposes, uncomment this to export all functions of this module.
# Export-ModuleMember -Function *
