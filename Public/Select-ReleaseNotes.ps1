<#
.SYNOPSIS
  Retrieves version information and release notes from a RELEASENOTES.md file
.DESCRIPTION
  Creates objects for each version block located in the file as defined by...
  Version+Date = '^#+\s*(?<version>[0-9]+\.[0-9]+(\.[0-9]+)?(\.[0-9]+)?)(\s*-\s*(?<date>.*))?$'
  Date = '^#+\s*.*(?<date>\d\d\d\d.\d\d.\d\d)'
  Header = '^#+\s*(?<header>.+):?$'
  
  eg
  # Stuff here before the first version
  Is ignored.
  
  ## 1.2.3.4
  ##### Released on 2016-08-01
  This text goes into .Blocks.General
  ### Fixes
  FIX-01: This text goes into .Blocks.Fixes
  ### Internal:
  Don't show this to customers, it's in .Blocks.Internal
  
  (Alternative date reading from SQL Compare markdown)
  # 1.2.3 - August 1st 2016
  # 1.2 - March 3rd, 2016
.EXAMPLE
  Select-ReleaseNotes -ReleaseNotesPath SQLCompareUIs\COMPARE_RELEASENOTES.md
  
  Version      Date                Blocks
  -------      ----                ------
  12.0.25.3064 13/09/2016 00:00:00 {General}
  12.0.24.3012 25/08/2016 00:00:00 {Fixes, General}
  12.0.23.2976 25/08/2016 00:00:00 {Fixes, General}
  12.0.22.2910 22/08/2016 00:00:00 {Fixes, General}
  12.0.21.2819 16/08/2016 00:00:00 {Fixes}
  12.0.20.2791 11/08/2016 00:00:00 {Fixes}
  12.0.19.2758 09/08/2016 00:00:00 {Fixes}
  12.0.18.2723 05/08/2016 00:00:00 {Fixes}
  12.0.17.2708 04/08/2016 00:00:00 {Fixes}
  12.0.16.2688 03/08/2016 00:00:00 {Fixes}
  12.0.15.2659 02/08/2016 00:00:00 {Fixes}
  12.0.14.2614 28/07/2016 00:00:00 {Features, Fixes}
.EXAMPLE
  Select-ReleaseNotes SQLSourceControl\RELEASENOTES.md

  Version    Date                Blocks
  -------    ----                ------
  5.1.5                          {General}
  5.1.4      08/07/2016 00:00:00 {Fixes, General}
  5.1.3      06/07/2016 00:00:00 {Fixes, General}
  5.1.2      29/06/2016 00:00:00 {Fixes, Features, General}
  5.1.1      08/06/2016 00:00:00 {Fixes, General}
  5.1.0      27/05/2016 00:00:00 {Fixes, General}
  5.0.1      25/05/2016 00:00:00 {Fixes, General}
  5.0.0      23/05/2016 00:00:00 {Major features, Fixes}
  4.5.0      10/05/2016 00:00:00 {SQL Source Control 5 Beta, General}
  4.4.2      03/05/2016 00:00:00 {Fixes, SQL Source Control 5 Beta, General}
#>
function Select-ReleaseNotes {
    [CmdletBinding()]
    param(
        # The path of the RELEASENOTES.md file to read from
        [string] $ReleaseNotesPath,
        # The RELEASENOTES markdown to select from
        [string] $ReleaseNotes,
        # Only return the top version block in the file
        [switch] $Latest
    )
    if ($ReleaseNotesPath) {
        $Lines = Get-Content $ReleaseNotesPath
    } elseif ($ReleaseNotes) {
        # Makes testing easier
        $Lines = ($ReleaseNotes -Replace "'r").Split("`n")
    } else {
        throw 'No $ReleaseNotesPath or $ReleaseNotes specified'
    }
    
    $VersionRegex = '^#+\s*(?<version>[0-9]+\.[0-9]+(\.[0-9]+)?(\.[0-9]+)?)(\s*-\s*(?<date>.*))?$'
    $HeaderRegex = '^#+\s*(?<header>.+):?$'
    $DateRegex = '^#+\s*.*(?<date>\d\d\d\d.\d\d.\d\d)'
    
    $Release = $nul
    
    # https://learn-powershell.net/2013/08/03/quick-hits-set-the-default-property-display-in-powershell-on-custom-objects/
    # Set up the default display set and create the member set object for use later on
    # Configure a default display set
    $defaultDisplaySet = 'Version','Date','Blocks'

    # Create the default property display set
    $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
    $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)

    $IgnoreRest = $false
    $Lines | ForEach-Object {
        if ($IgnoreRest)
        {
            return
        }
        $Line = $_.Trim()
        $VersionMatch = [regex]::Match($Line, $VersionRegex)
        if ($VersionMatch.Success) {
            if ($Release) {
                if ($Release.Blocks.$CurrentHeader) {
                    $Release.Blocks.$CurrentHeader = $Release.Blocks.$CurrentHeader.Trim()
                }
                $Release
                if ($Latest) {
                    $IgnoreRest = $true
                    $Release = $nul
                    return
                }
            }
            
            $CurrentHeader = 'General'
            $Release = [pscustomobject]@{
                Version = [version] $VersionMatch.Groups['version'].Value
                Date = $nul
                Blocks = @{}
            }
            $Release.PSObject.TypeNames.Insert(0,'RedGate.Build.VersionInformation')
            $Release | Add-Member MemberSet PSStandardMembers $PSStandardMembers

            if ($VersionMatch.Groups['date'].Success) {
                $simpleDate = $VersionMatch.Groups['date'].Value
                $simpleDate = $simpleDate -replace '(\d+)(st|nd|rd|th)', '$1' -replace ','
                $Release.Date = [DateTime] $simpleDate
            }
        } elseif ($Release) {
            $DateMatch = [regex]::Match($Line, $DateRegex)
            $HeaderMatch = [regex]::Match($Line, $HeaderRegex)
            if ($DateMatch.Success) {
                $Release.Date = [DateTime] $DateMatch.Groups['date'].Value
            } elseif ($HeaderMatch.Success) {
                if ($Release.Blocks.$CurrentHeader) {
                    $Release.Blocks.$CurrentHeader = $Release.Blocks.$CurrentHeader.Trim()
                }
                $CurrentHeader = $HeaderMatch.Groups['header'].Value
            } else {
                if ($Release.Blocks.$CurrentHeader) {
                    $Release.Blocks.$CurrentHeader += [System.Environment]::NewLine + $Line
                } else {
                    $Release.Blocks.$CurrentHeader = $Line
                }
            }
        }
    }
    if ($Release) {
        if ($Release.Blocks.$CurrentHeader) {
            $Release.Blocks.$CurrentHeader = $Release.Blocks.$CurrentHeader.Trim()
        }
        $Release
    }
}