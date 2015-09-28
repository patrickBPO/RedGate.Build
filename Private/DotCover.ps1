function Get-DotCoverExePath {
  [CmdletBinding()]
  param(
    # The version of the nuget package containing DotCover.exe (JetBrains.dotCover.CommandLineTools)
    [string] $DotCoverVersion = $DefaultDotCoverVersion
  )

  Write-Verbose "Using DotCover version $DotCoverVersion"
  $DotCoverFolder = Install-DotCoverPackage $DotCoverVersion

  "$DotCoverFolder\tools\dotcover.exe" | Resolve-Path
}
