<#
.SYNOPSIS
  Pack, test and publish RedGate.Build
.DESCRIPTION
  1. nuget pack RedGate.Build.nuspec
  2. If Nuget Feed Url and Api key are passed in, publish the RedGate.Build package
#>
[CmdletBinding()]
param(
  # The version of the nuget package
  [string] $Version = '0.0.1-dev',
  # true when building from master. If false, '-prerelease' is appended to the package version
  [bool] $IsDefaultBranch = $False,
  # Optional: A url to a nuget feed the package will be published to
  [string] $NugetFeedToPublishTo,
  # Optional: The Api Key that allows pushing to the feed passed in as -NugetFeedToPublishTo
  [string] $NugetFeedApiKey
)

$ErrorActionPreference = 'Stop'

function Write-Info($Message) {
    Write-Host $Message -Foreground Magenta
}

Push-Location $PSScriptRoot
try {
  if(!$IsDefaultBranch) {
    # If we are not building from master, append -prerelease to the package version
    $Version = "$Version-prerelease"
    # let TC know
    "##teamcity[buildNumber '$Version']"
  }
  
  # Clean any previous build output.
  Write-Info 'Cleaning any prior build output'
  $NuGetPackagePath = ".\RedGate.Build.$Version.nupkg"
  if (Test-Path $NuGetPackagePath) {
    Write-Host "Deleting $NuGetPackagePath"
    Remove-Item $NuGetPackagePath
  }

  # Download NuGet if necessary.
  Write-Info 'Checking NuGet is up to date'
  $NuGetVersion = '3.2.0'
  $NuGetPath = '.\Private\nuget.exe'
  if(-not (Test-Path $NuGetPath) -or (Get-Item $NuGetPath).VersionInfo.ProductVersion -ne $NuGetVersion) {
    $NuGetUrl = "https://dist.nuget.org/win-x86-commandline/v$NuGetVersion/nuget.exe"
    Write-Host "Downloading $nugetUrl to $NuGetPath"
    Invoke-WebRequest $NuGetUrl -OutFile $NuGetPath
  } else {
    Write-Host "$NuGetPath is present and up to date"
  }

  # Package the RedGate.Build module.
  Write-Info 'Creating RedGate.Build NuGet package'
  & $NuGetPath pack .\RedGate.Build.nuspec -NoPackageAnalysis -Version $Version
  if($LASTEXITCODE -ne 0) {
    throw "Could not nuget pack RedGate.Build. nuget returned exit code $LASTEXITCODE"
  }
  $Null = $NuGetPackagePath | Resolve-Path # Further verify that the package was built.
  
  # TODO: Extract the package to a clean folder and run some tests on it.

  # Publish the NuGet package.
  Write-Info 'Publishing RedGate.Build NuGet package'
  if($IsDefaultBranch -and $NugetFeedToPublishTo -and $NugetFeedApiKey) {
    Write-Host "Running NuGet publish"
    # Let's only push the packages from master when nuget feed info is passed in...
    & $NuGet push $NuGetPackagePath -Source $NugetFeedToPublishTo -ApiKey $NugetFeedApiKey
  } else {
    Write-Host "Publish skipped"
  }
  
  Write-Info 'Build completed'
} finally {
  Pop-Location
}
