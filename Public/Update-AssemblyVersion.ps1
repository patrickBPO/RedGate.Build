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
  The optional encoding of the source file. Valid values include the following:
   - 'Ascii'
   - 'BigEndianUnicode'
   - 'BigEndianUTF32'
   - 'Default'
   - 'Unicode'
   - 'UTF7'
   - 'UTF8' : Unlike System.Text.Encoding.UTF8, this provides an instance that does not emit a BOM.
   - 'UTF8WithBom' : Use this if you actually want an encoder that emits the UTF8 BOM.
   - 'UTF32'
   - Any value from the Name column in the table found at https://msdn.microsoft.com/en-us/library/system.text.encoding.aspx 
.OUTPUTS
  The input source file path.
.EXAMPLE
  'AssemblyInfo.cs' | Update-AssemblyVersion -Version '1.2.0.12443'

  This shows the minimal correct usage, whereby the SourceFilePath is piped to the cmdlet, along with the require Version parameter.
.EXAMPLE
  'AssemblyInfo.cs' | Update-AssemblyVersion -Version $BuildNumber -InformationalVersion $NuGetPackageVersion

  This shows more typical usage, whereby Version is provided by a the curent build number and InformationalVersion is provided by the NuGet package version (which can include a pre-release package suffix).
#>
#requires -Version 3
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
    if (!$InformationalVersion) { $InformationalVersion = [string] $FileVersion }

    Write-Verbose "Updating version numbers in file $SourceFilePath"
    Write-Verbose "  Version = $Version"
    Write-Verbose "  FileVersion = $FileVersion"
    Write-Verbose "  InformationalVersion = $InformationalVersion"

    # Resolve the encoding string to an actual System.Text.Encoding instance.
    $EncodingInstance = Get-Encoding $Encoding

    # Read the file contents, update the assembly version attributes, then save it again.
    $CurrentContents = [System.IO.File]::ReadAllText($SourceFilePath, $EncodingInstance)
    $NewContents = $CurrentContents `
        -replace '(?<=AssemblyVersion\s*\(\s*@?")[0-9\.\*]*(?="\s*\))', $Version.ToString() `
        -replace '(?<=AssemblyFileVersion\s*\(\s*@?")[0-9\.\*]*(?="\s*\))', $FileVersion.ToString() `
        -replace '(?<=AssemblyInformationalVersion\s*\(\s*@?")[a-zA-Z0-9\.\*\-]*(?="\s*\))', $InformationalVersion
    [System.IO.File]::WriteAllText($SourceFilePath, $NewContents, $EncodingInstance)
	
    # Return the input SoureFilePath to enable pilelining.
	return $SourceFilePath
}
