function script:AddFeature($accumulator, [int] $priority, [string] $feature){
    if ($accumulator.([string]$priority) -ne $nul -and $accumulator.([string]$priority) -ne $feature)
    {
        throw "Duplicate feature at priority $priority, was $($accumulator.([string]$priority)), attempting to set to $feature"
    }
    # TODO if the same feature exists at a lower priority - raise the priority for the given priority
    $accumulator.([string]$priority) = $feature
}

function script:GetSummary($release, $accumulator)
{
    $summary = $accumulator.GetEnumerator() | sort {[int]$_.Key} -Descending
    if ($summary) {
        return [string]::Join(", ", $summary.Value)
    } else {
        return $release.Version
    }
}

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

    # https://learn-powershell.net/2013/08/03/quick-hits-set-the-default-property-display-in-powershell-on-custom-objects/
    # Set up the default display set and create the member set object for use later on
    # Configure a default display set
    $defaultDisplaySet = 'Version', 'Date', 'Blocks', 'Summary'

    # Create the default property display set
    $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$defaultDisplaySet)
    $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)

    $VersionRegex = '^#+\s*(?<version>[0-9]+\.[0-9]+(\.[0-9]+)?(\.[0-9]+)?)(\s*-\s*(?<date>.*))?\s*$'
    $HeaderRegex = '^#+\s*(?<header>.+):?\s*$'
    $DateRegex = '^#+\s*.*(?<date>\d\d\d\d.\d\d.\d\d)'
    $StraplineStartRegex = '^#+\s*Strapline\s*$'
    $StraplineRegex = '^\s*(?<priority>[0-9]+)\.?\s*(?<feature>.*)\s*$'

    $Accumulator = @{}
    $StraplineAccumulator = $false
    $Release = $nul
    $IgnoreRest = $false

    $Lines | ForEach-Object {
        if ($IgnoreRest)
        {
            # I seem to have to keep processing
            return
        }
        $Line = $_.Trim()
        $VersionMatch = [regex]::Match($Line, $VersionRegex)
        if ($VersionMatch.Success) {
            # If a $Release already was being filled in - clean it up and return it
            if ($Release) {
                if ($Release.Blocks.$CurrentHeader) {
                    $Release.Blocks.$CurrentHeader = $Release.Blocks.$CurrentHeader.Trim()
                }
                $Release.Summary = GetSummary -Release $Release -Accumulator $Accumulator
                $Release

                # If only getting one then ensure I skip everything else - can't use continue/break in a ForEach-Object
                if ($Latest) {
                    $IgnoreRest = $true
                    $Release = $nul
                    return
                }
            }
            
            

            # Default Release object is created here with nice properties when in a list
            $CurrentHeader = 'General'
            $StraplineAccumulator = $false
            $Release = [pscustomobject]@{
                Version = [version] $VersionMatch.Groups['version'].Value
                Date = $nul
                Summary = $nul
                Blocks = @{}
            }
            $Release.PSObject.TypeNames.Insert(0,'RedGate.Build.VersionInformation')
            $Release | Add-Member MemberSet PSStandardMembers $PSStandardMembers

            # Add the SQL Compare style date to the object if found
            if ($VersionMatch.Groups['date'].Success) {
                $simpleDate = $VersionMatch.Groups['date'].Value
                $simpleDate = $simpleDate -replace '(\d+)(st|nd|rd|th)', '$1' -replace ','
                $Release.Date = [DateTime] $simpleDate
            }
        } elseif ($Release) {
            # Only start populating things once we've seen a version and initialised a $Release
            $DateMatch = [regex]::Match($Line, $DateRegex)
            $StraplineStartMatch = [regex]::Match($Line, $StraplineStartRegex)
            $HeaderMatch = [regex]::Match($Line, $HeaderRegex)
            if ($DateMatch.Success) {
                # Date take precedence over header
                $StraplineAccumulator = $false
                $Release.Date = [DateTime] $DateMatch.Groups['date'].Value
            } elseif ($StraplineStartMatch.Success) {
                # Start the strapline accumulator
                $StraplineAccumulator = $true
            } elseif ($HeaderMatch.Success) {
                # New header, remove any trailing blank lines and prepare to add to new block
                if ($Release.Blocks.$CurrentHeader) {
                    $Release.Blocks.$CurrentHeader = $Release.Blocks.$CurrentHeader.Trim()
                }
                $StraplineAccumulator = $false
                $CurrentHeader = $HeaderMatch.Groups['header'].Value
            } else {
                if ($StraplineAccumulator) {
                    # Ignore newlines in Strapline section
                    if ($Line) {
                        $StraplineMatch = [regex]::Match($Line, $StraplineRegex)
                        if (!$StraplineMatch.Success) {
                            throw "Strapline expected, encountered '$Line'"
                        }
                        AddFeature -accumulator $Accumulator `
                            -priority $StraplineMatch.Groups['priority'].Value `
                            -feature $StraplineMatch.Groups['feature'].Value
                    }
                } else {
                    # Any non date/header line is added to the current block as defined by $CurrentHeader
                    if ($Release.Blocks.$CurrentHeader) {
                        $Release.Blocks.$CurrentHeader += [System.Environment]::NewLine + $Line
                    } else {
                        $Release.Blocks.$CurrentHeader = $Line
                    }
                }
            }
        }
    }
    # Clean up and return the last $Release object being populated (if there is one)
    if ($Release) {
        if ($Release.Blocks.$CurrentHeader) {
            $Release.Blocks.$CurrentHeader = $Release.Blocks.$CurrentHeader.Trim()
        }
        $Release.Summary = GetSummary -Release $Release -Accumulator $Accumulator
        $Release
    }
}