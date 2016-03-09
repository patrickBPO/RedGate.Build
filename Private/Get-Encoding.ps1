<#
.SYNOPSIS
  Updates the AssemblyVersion, AssemblyFileVersion and AssemblyInformationalVersion attributes in a source file.
.DESCRIPTION
  Updates the AssemblyVersion, AssemblyFileVersion and AssemblyInformationalVersion attributes in a source file, typically AssemblyInfo.cs. This cmdlet should be used on the AssemblyInfo.cs files of each project in a solution before the solution is compiled, so that the build version number is correctly injected into the compiled assemblies.
.PARAMETER Name
  The name of the encoding to obtain. Valid values include the following:
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
  A System.Text.Encoding instance corresponding to the specified Name parameter value.
.EXAMPLE
  Get-Encoding 'UTF8'
	
  Returns a System.Text.Encoding instance that can be used to encode and decode UTF8.
#>
function Get-Encoding
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeLine = $True)]
        [string] $Name
    )

    switch ($Name) {
        'Ascii'{ return [System.Text.Encoding]::ASCII }
        'BigEndianUnicode'{ return [System.Text.Encoding]::BigEndianUnicode }
        'BigEndianUTF32'{ return [System.Text.Encoding]::BigEndianUnicode }
        'Default'{ return [System.Text.Encoding]::Default }
        'Unicode' { return [System.Text.Encoding]::Unicode }
        'UTF7'{ return [System.Text.Encoding]::UTF7 }
        'UTF8' { return New-Object 'System.Text.UTF8Encoding' $False }
        'UTF8WithBom' { return [System.Text.Encoding]::UTF8 }
        'UTF32' { return [System.Text.Encoding]::UTF32 }
        default { return [System.Text.Encoding]::GetEncoding($Name) }
    }
}