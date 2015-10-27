function Add-ToHashTableIfNotNull {
  param(
    [Parameter(Mandatory=$true)]
    [HashTable] $HashTable,
    [Parameter(Mandatory=$true)]
    [string] $Key,
    [string] $Value
  )

  if( $Value ) {
    $HashTable.Add($Key, $Value)
  }
}

<#
    .SYNOPSIS
    Signs a .NET assembly.

    .DESCRIPTION
    Signs a .NET assembly executable or dll.

    .PARAMETER AssemblyPath
    The path of the assembly to be signed. The assembly will me updated in place with a digital signature.

    .PARAMETER SigningServiceUrl
    The url of the signing service. If unspecified, defaults to the $env:SigningServiceUrl environment variable.

    .PARAMETER Certificate
    Indicates which signing certificate to use. Defaults to 'master'.

    .PARAMETER Description
    An optional description. Defaults to 'Red Gate Software Ltd.'.

    .PARAMETER MoreInfoUrl
    An optional URL that can be used to specify more information about the signed assembly by end-users. Defaults to 'http://www.red-gate.com'.

    .PARAMETER ReCompressZip
    This is a throwover from the C# implementation. It corresponds to the 'ReCompressZip' request header. Any idea what it does?

    .OUTPUT
    The AssemblyPath parameter, to enable call chaining.
#>
function Invoke-AssemblySigning {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
    [string] $AssemblyPath,

    [Parameter(Mandatory = $False)]
    [string] $SigningServiceUrl = $env:SigningServiceUrl,

    [Parameter(Mandatory = $False)]
    [string] $Certificate = 'Master',

    [Parameter(Mandatory = $False)]
    [string] $Description = 'Red Gate Software Ltd.',

    [Parameter(Mandatory = $False)]
    [string] $MoreInfoUrl = 'http://www.red-gate.com',

    [Parameter(Mandatory = $False)]
    [string] $ReCompressZip
  )

  # Simple error checking.
  if ([String]::IsNullOrEmpty($SigningServiceUrl)) {
    throw 'Cannot sign assembly. -SigningServiceUrl was not specified and the SigningServiceUrl environment variable is not set.'
  }
  if (!(Test-Path $AssemblyPath)) {
    throw "Assembly not found: $AssemblyPath"
  }

  # Determine the file type.
  $FileType = $Null
  switch ([System.IO.Path]::GetExtension($AssemblyPath)) {
    '.exe' { $FileType = 'Exe' }
    '.dll' { $FileType = 'Dll' }
    default { throw "Unsupported file type: $AssemblyPath" }
  } 

  $Headers = @{};
  Add-ToHashTableIfNotNull $Headers -Key 'FileType' -Value $FileType
  Add-ToHashTableIfNotNull $Headers -Key 'Certificate' -Value $Certificate
  Add-ToHashTableIfNotNull $Headers -Key 'Description' -Value $Description
  Add-ToHashTableIfNotNull $Headers -Key 'MoreInfoUrl' -Value $MoreInfoUrl
  Add-ToHashTableIfNotNull $Headers -Key 'ReCompressZip' -Value $ReCompressZip

  Write-Verbose "Signing $AssemblyPath using $SigningServiceUrl"
  $Headers.Keys | ForEach { Write-Verbose "`t $_`: $($Headers[$_])" }

  $Response = Invoke-WebRequest `
    -Uri $SigningServiceUrl `
    -InFile $AssemblyPath `
    -OutFile $AssemblyPath `
    -Method Post `
    -ContentType 'binary/octet-stream' `
    -Headers $Headers
  # TODO: How should we check the response?

  return $AssemblyPath
}
