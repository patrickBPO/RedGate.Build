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
  Send an assembly to a webserver to be signed
.DESCRIPTION
  Send an assembly to a webserver to be digitally signed
#>
function Sign-Assembly {
  [CmdletBinding()]
  param(
    # The Url of the web service doing the signing
    # e.g. https://myserver.com/ or http://myoverserver.org:1234/
    [string] $SigningServiceUrl = $env:SigningServiceUrl,

    # The path to the assembly to be signed. This file will be updated.
    [Parameter(Mandatory=$true)]
    [string] $AssemblyFilename,

    [string] $FileType = 'Exe',
    [string] $ReCompressZip,
    [string] $Certificate = 'Master',
    [string] $Description = 'Red Gate Software Ltd.',
    [string] $MoreInfoUrl = 'http://www.red-gate.com'
  )

  if([String]::IsNullOrEmpty($SigningServiceUrl)) {
    throw 'Cannot sign assembly. -SigningServiceUrl was not specified and the SigningServiceUrl environment variable is not set.'
  }

  $Headers = @{ 'FileType' =  $FileType };
  Add-ToHashTableIfNotNull $Headers -Key 'Certificate' -Value $Certificate
  Add-ToHashTableIfNotNull $Headers -Key 'Description' -Value $Description
  Add-ToHashTableIfNotNull $Headers -Key 'MoreInfoUrl' -Value $MoreInfoUrl
  Add-ToHashTableIfNotNull $Headers -Key 'ReCompressZip' -Value $ReCompressZip

  Write-Verbose "Signing $AssemblyFilename using $SigningServiceUrl"
  $Headers.Keys | ForEach { Write-Verbose "`t $_`: $($Headers[$_])" }

  Invoke-WebRequest `
    -Uri $SigningServiceUrl `
    -InFile $AssemblyFilename `
    -OutFile $AssemblyFilename `
    -Method Post `
    -ContentType 'binary/octet-stream' `
    -Headers $Headers

}
