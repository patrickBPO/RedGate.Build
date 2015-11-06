#requires -Version 2
function Get-NuGetPackageId 
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [version] $Version,

        [Parameter(Mandatory = $false)]
        [string] $BranchName,

        [Parameter(Mandatory = $false)]
        [switch] $IsDefaultBranch
    )

    # If this is the default branch, there's no pre-release suffix. Just return the version number.
    if ($IsDefaultBranch.IsPresent)
    {
        return [string]$Version
    }

    # Otherwise establish the pre-release suffix from the branch name.
    $PreReleaseSuffix = "-$BranchName"

    # Remove invalid characters from the suffix.
    $PreReleaseSuffix = $PreReleaseSuffix -replace '[^0-9A-Za-z-]', ''

    # Shorten the suffix if necessary, to satisfy NuGet's 20 character limit.
    $Revision = [string]$Version.Revision
    $MaxLength = 20 - $Revision.Length
    if ($PreReleaseSuffix.Length -gt $MaxLength) 
    {
        $PreReleaseSuffix = $PreReleaseSuffix -replace '[aeiou]', ''

        # If the suffix is still too long after we've stripped out the vovels, truncate it.
        if ($PreReleaseSuffix.Length -gt $MaxLength) 
        {
            $PreReleaseSuffix = $PreReleaseSuffix.Substring(0, $MaxLength)
        }
    }

    # And finally compose the full NuGet package version.
    $Major = $Version.Major
    $Minor = $Version.Minor
    $Patch = $Version.Build
    return "$Major.$Minor.$Patch$PreReleaseSuffix$Revision"
}
