<#
.SYNOPSIS
  Call Smart Assembly
.DESCRIPTION
  1. Install required Smart Assembly nuget Package to get SmartAssembly.exe and SmartAssembly.com
  2. Call smartassembly.com
.EXAMPLE
  Invoke-SmartAssembly -ProjectPath D:\myproject.{sa}proj -SmartAssemblyVersion 6.9.0
    Restore the SmartAssembly nuget package version 6.9.0 and call
    .\packages\SmartAssembly.6.9.0\tools\SmartAssembly.com D:\myproject.{sa}proj
#>
function Invoke-SmartAssembly {
  [CmdletBinding()]
  param(
    # The path to the .{sa}proj file.
    [Parameter(Mandatory=$true)]
    [string] $ProjectPath,
    # The version of the nuget package containing the Smart Assembly executables
    [string] $SmartAssemblyVersion = $DefaultSmartAssemblyVersion,
    # Specify the input assembly filename
    [string] $InputFilename,
    # Specify the output assembly filename
    [string] $OutputFilename
  )

  $ProjectPath = Resolve-Path $ProjectPath

  Write-Output "Executing $ProjectPath"

  $saComPath = Get-SmartAssemblyComPath -SmartAssemblyVersion $SmartAssemblyVersion

  $saArguments = '/build', $ProjectPath

  if($InputFilename){
    $saArguments += "/input=$InputFilename"
  }
  if($OutputFilename){
    $saArguments += "/output=$OutputFilename"
  }

  Execute-Command {
    & $saComPath $saArguments
  }

}
