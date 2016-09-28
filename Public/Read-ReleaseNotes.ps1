<#
.SYNOPSIS
  Retrieves version information and release notes from a RELEASENOTES.md file
.DESCRIPTION
  1. Scans $ReleaseNotesPath for the first line matching ^#+\s*(?<version>[0-9]+\.[0-9]+(\.[0-9]+)?)$
  2. That line and all subsequent lines are appended
  3. Return object contains Content and Version properties for retrieved information
.EXAMPLE
  Read-ReleaseNotes -ReleaseNotesPath $RootDir\RELEASENOTES.md
    Returns two part version number and release notes.
.EXAMPLE
  Read-ReleaseNotes -ReleaseNotesPath $RootDir\RELEASENOTES.md -ThreePartVersion
    Returns thee part version number and release notes.
#>
function Read-ReleaseNotes {
    [CmdletBinding()]
    param(
        # The path of the release notes.md file to read from
        [Parameter(Mandatory=$true)]
        [string] $ReleaseNotesPath,
        # Whether to retrieve the version as a three part number (normally only two)
        [switch] $ThreePartVersion
    )
    $Lines = Get-Content $ReleaseNotesPath
    $Result = @()
    $Version = $Null
    $VersionRegex = '^#+\s*(?<version>[0-9]+\.[0-9]+(\.[0-9]+)?)$'
        
    $Lines | ForEach-Object {
        $Line = $_.Trim()
        if (-not $Version) {
            $Match = [regex]::Match($Line, $VersionRegex)
            if ($Match.Success) {
                $Version = [version] $Match.Groups['version'].Value
                if ($ThreePartVersion -and ($Version.Build -eq -1)) {
                    throw "Found two part version first '$Line'"
                }
                if (!$ThreePartVersion -and ($Version.Build -ne -1)) {
                    throw "Found three part version first '$Line'"
                }
            }
        }
        if ($Version) {
            $Result += $Line
        }
    }
    if (-not $Version) {
        throw "Failed to find version in release notes: $ReleaseNotesPath"
    }
    return @{
        Content = $Result -join [System.Environment]::NewLine
        Version = $Version
    }
}