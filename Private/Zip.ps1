function Get-7ZipExePath {
  [CmdletBinding()]
  param()

  $7ZipFolder = Install-Package -Name '7-Zip.CommandLine' -Version '9.20.0'

  "$7ZipFolder\tools\7za.exe" | Resolve-Path
}
