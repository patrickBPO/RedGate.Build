<#
.SYNOPSIS
  Performs coverage analysis of a .NET application.

.DESCRIPTION
  Use 'dotcover.exe' to perform coverage analysis of the specified .NET executable.

.PARAMETER TargetExecutable
  The path of the target executable.

.PARAMETER TargetArguments
  The arguments to pass to the target executable.

.PARAMETER OutputFile
  The output XML file containing the detailed coverage information.

.PARAMETER DotCoverVersion
  The version of dotCover nuget package to use.

.PARAMETER DotCoverFilters
  Coverage filters for dotCover, to indicate what should and should not be covered.
#>
function Invoke-DotCoverForExecutable {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $True)]
    [string] $TargetExecutable,

    [Parameter(Mandatory = $False)]
    [string[]] $TargetArguments,

    [Parameter(Mandatory = $True)]
    [string] $OutputFile,

    [Parameter(Mandatory = $False)]
    [string] $DotCoverVersion = $DefaultDotCoverVersion,

    [Parameter(Mandatory = $False)]
    [string] $DotCoverFilters = ''
  )

  $DotCoverArguments = @(
    'cover',
    "/TargetExecutable=$TargetExecutable",
    "/Output=$OutputFile",
    '/ReturnTargetExitCode'
  )

  if (![string]::IsNullOrWhiteSpace($DotCoverFilters)) {
    $DotCoverArguments += "/Filters=$DotCoverFilters"
  }

  if ($TargetArguments) {
    $EscapedArguments = ConvertTo-ShellEscaped $TargetArguments
    $DotCoverArguments += "/TargetArguments=$TargetArguments"
  }

  $DotCoverPath = Get-DotCoverExePath -DotCoverVersion $DotCoverVersion

  & $DotCoverPath $DotCoverArguments

  if ($LastExitCode -ne 0) {
    throw "dotCover exited with code $LastExitCode."
  }
}
