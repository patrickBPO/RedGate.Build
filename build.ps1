[CmdletBinding()]
param(
  [string] $Version = '0.0.1-dev',
  [bool] $IsDefaultBranch = $False,
  [string] $NugetFeedToPublishTo,
  [string] $NugetFeedApiKey
)

$ErrorActionPreference = 'Stop'

Push-Location $PSScriptRoot
try {
  if(!$IsDefaultBranch) {
    # If we are not building from master, append -prerelease to the package version
    $Version = "$Version-prerelease"
    # let TC know
    "##teamcity[buildNumber '$Version']"
  }

  if(-not (Test-Path .\nuget.exe)) {
    Invoke-WebRequest -Uri 'https://dist.nuget.org/win-x86-commandline/v3.2.0/nuget.exe' -OutFile .\nuget.exe
  }

  .\nuget.exe pack .\RedGate.Build.nuspec -NoPackageAnalysis -Version $Version
  if($LASTEXITCODE -ne 0) {
    throw "Could not nuget pack RedGate.Build. nuget returned exit code $LASTEXITCODE"
  }

  if($IsDefaultBranch -and $NugetFeedToPublishTo -and $NugetFeedApiKey) {
    # Let's only push the packages from master when nuget feed info is passed in...
    .\nuget.exe push .\RedGate.Build.$Version.nupkg -Source $NugetFeedToPublishTo -ApiKey $NugetFeedApiKey
  }

} finally {
  Pop-Location
}
