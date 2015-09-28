function Install-DotCoverPackage {
  [CmdletBinding()]
  param(
    # The version of the nuget package containing DotCover.exe (JetBrains.dotCover.CommandLineTools)
    [string] $Version = '3.2.20150819.165728'
  )

  Install-Package JetBrains.dotCover.CommandLineTools $Version
}
