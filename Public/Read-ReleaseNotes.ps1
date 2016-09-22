<#
.SYNOPSIS
  Retrieves version information and release notes from a RELEASENOTES.md file
.DESCRIPTION
  1. Scans $ReleaseNotesPath for the first line matching [^\.][0-9]+\.[0-9]+$ or [^\.][0-9]+\.[0-9]+\.[0-9]+$
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
    if ($ThreePartVersion) {
        $Regex = '[^\.][0-9]+\.[0-9]+.[0-9]+$'
    }
    else {
        $Regex = '[^\.][0-9]+\.[0-9]+$'
    }
        
    $Lines | ForEach-Object {
        $Line = $_.Trim()
        if (-not $Version) {
            $Match = [regex]::Match($Line, $Regex)
            if ($Match.Success) {
                $Version = $Match.Value
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
        Version = [version] $Version
    }
}