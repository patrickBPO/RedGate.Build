#requires -Version 3
<#
.SYNOPSIS
  Updates the AssemblyVersion, AssemblyFileVersion and AssemblyInformationalVersion attributes in a source file.
.DESCRIPTION
  Updates the AssemblyVersion, AssemblyFileVersion and AssemblyInformationalVersion attributes in a source file, typically AssemblyInfo.cs. This cmdlet should be used on the AssemblyInfo.cs files of each project in a solution before the solution is compiled, so that the build version number is correctly injected into the compiled assemblies.
.PARAMETER SourceFilePath
  The path of the source file that contains the AssemblyVersion, AssemblyFileVersion and AssemblyInformationalVersion attributes.
.PARAMETER Version
  The Assembly Version to be injected into the source file.
.PARAMETER FileVersion
  The optional Assembly File Version to be injected into the source file. If unspecified, defaults to the value of the Version parameter.
 .PARAMETER InformationalVersion
  The optional Assembly Informational Version to be injected into the source file. If unspecified, defaults to the value of the Version parameter.
.PARAMETER Encoding
  The optional encoding of the source file. If unspecified, defaults to 'UTF8'. Valid values include 'Unicode', 'Byte', 'BigEndianUnicode', 'UTF8', 'UTF7', 'UTF32', 'Ascii', 'Default', 'Oem' and 'BigEndianUTF32'.
.OUTPUTS
  The input source file path.
.EXAMPLE
  'AssemblyInfo.cs' | Update-AssemblyVersion -Version '1.2.0.12443' -InformationalVersion '1.2.0-prerelease'
#>
function Update-AssemblyVersion
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeLine = $True)]
        [string] $SourceFilePath,

        [Parameter(Mandatory = $True)]
        [version] $Version,

        [Parameter(Mandatory = $False)]
        [version] $FileVersion,

        [Parameter(Mandatory = $False)]
        [string] $InformationalVersion,

        [Parameter(Mandatory = $False)]
        [string] $Encoding = 'UTF8'
    )

    if (!$FileVersion) { $FileVersion = $Version }
    if (!$InformationalVersion) { $InformationalVersion = [string] $Version }

    Write-Verbose "Updating version numbers in file $SourceFilePath"
    Write-Verbose "  Version = $Version"
    Write-Verbose "  FileVersion = $FileVersion"
    Write-Verbose "  InformationalVersion = $InformationalVersion"

    $CurrentContent = Get-Content $SourceFilePath -Encoding $Encoding -Raw
    $NewContent = $CurrentContent `
        -replace '(?<=AssemblyVersion\(")[0-9\.\*]*(?="\))', $Version.ToString() `
        -replace '(?<=AssemblyFileVersion\(")[0-9\.\*]*(?="\))', $FileVersion.ToString() `
        -replace '(?<=AssemblyInformationalVersion\(")[a-zA-Z0-9\.\-]*(?="\))', $InformationalVersion
    $NewContent | Out-File $SourceFilePath -Encoding $Encoding
	
	return $SourceFilePath
}
