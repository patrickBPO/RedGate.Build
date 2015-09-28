function Merge-CoverageReports {
  [CmdletBinding()]
  param(
    # The folder containing the coverage reports to be merged.
    [Parameter(Mandatory=$true)]
    [string] $OutputDir
  )

  $DotCoverPath = Get-DotCoverExePath

  $MergedSnapshotPath = "$OutputDir\coverage.report.merged"
  $snapshots = (Get-ChildItem $OutputDir -Filter *.coverage.snap).FullName -join ';'

  Execute-Command $DotCoverPath @('merge', "/Source=`"$snapshots`"", "/Output=`"$MergedSnapshotPath`"")
  Execute-Command $DotCoverPath @('zip', "/Source=`"$MergedSnapshotPath`"", "/Output=`"$MergedSnapshotPath.zip`"")

  if( $env:TEAMCITY_VERSION -eq $null ) {
    # Create an HTML report if running outside of Teamcity to help with debugging
    Execute-Command $DotCoverPath @('report', "/Source=`"$MergedSnapshotPath.zip`"", "/Output=`"$OutputDir\report.html`"", '/reporttype=HTML')
  } else {
    # Let Teamcity know where the report is.
    TeamCity-ImportDotNetCoverageResult 'dotcover' "$MergedSnapshotPath.zip"
  }
}
