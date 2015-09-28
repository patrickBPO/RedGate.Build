<#
.SYNOPSIS
  Performs coverage analysis of the specified application
.DESCRIPTION
  Use 'dotcover.exe cover' to perform coverage analysis of the specified executable
#>
function Invoke-DotCoverForExecutable {
  [CmdletBinding()]
  param(
    # File name of the program to analyse
    [Parameter(Mandatory=$true)]
    [string] $TargetExecutable,
    # Arguments of the program to analyse (Optional)
    [string[]] $TargetArguments,
    # Output Coverage file
    [Parameter(Mandatory=$true)]
    [string] $OutputFile,
    # The version of the nuget package containing DotCover.exe (JetBrains.dotCover.CommandLineTools)
    [string] $DotCoverVersion = $DefaultDotCoverVersion,
    # The dotcover filters passed to dotcover.exe
    [string] $DotCoverFilters = ''
  )

  # TODO: better escaping of TargetArguments

  if( $DotCoverFilters) {
    $DotCoverFilters = "/Filters=$DotCoverFilters"
  }

  $DotCoverArguments = "cover",
    "/TargetExecutable=`"$TargetExecutable`"",
    "/Output=`"$OutputFile`"",
    $DotCoverFilters,
    '/ReturnTargetExitCode'

  if($TargetArguments) {
    $DotCoverArguments += "/TargetArguments=`"$($TargetArguments -replace '"', '\"')`""
  }

  Execute-Command (Get-DotCoverExePath -DotCoverVersion $DotCoverVersion) $DotCoverArguments

}
