#requires -Version 2
function Get-NuGetPackageId 
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [version] $Version
    )

    # Establish the basic pre-release suffix.
    $PreReleaseSuffix = '-dev' # For dev builds, always use the '-dev' prerelease suffix.
    if ($env:BRANCH_NAME) 
    {
        # For build server builds, use the branch name, or no suffix on the default branch.
        if ($env:IS_DEFAULT_BRANCH -eq 'True') 
        {
            $PreReleaseSuffix = ''
        }
        else 
        {
            $PreReleaseSuffix = "-$env:BRANCH_NAME" -replace '[^0-9A-Za-z-]', ''
        }
    }

    # If there's no pre-release suffix (because we're on the master branch on the build server), just return the version.
    if ($PreReleaseSuffix -eq '') 
    {
        return [string]$Version
    }

    # Shorten the pre-release suffix if necessary, to satisfy NuGet's 20 character limit.
    $Revision = [string]$Version.Revision
    $MaxLength = 20 - $Revision.Length
    if ($PreReleaseSuffix.Length -gt $MaxLength) 
    {
        $PreReleaseSuffix = $PreReleaseSuffix -replace '[aeiou]', ''
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
