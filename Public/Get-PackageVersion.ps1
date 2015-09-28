function Get-PackageVersion {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [string] $Name
  )

  $BuildPackages | where id -eq $Name | select -expandProperty version

}
