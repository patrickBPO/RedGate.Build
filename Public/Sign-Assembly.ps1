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
    # The name of the server doing the signing
    [Parameter(Mandatory=$true)]
    [string] $Server,

    # The path to the assembly to be signed. This file will be updated.
    [Parameter(Mandatory=$true)]
    [string] $AssemblyFilename,

    [string] $FileType = 'Exe',
    [string] $ReCompressZip,
    [string] $Certificate = 'Master',
    [string] $Description = 'Red Gate Software Ltd.',
    [string] $MoreInfoUrl = 'http://www.red-gate.com'
  )

  $Url = "http://$Server/Sign"

  $Headers = @{ 'FileType' =  $FileType };
  Add-ToHashTableIfNotNull $Headers -Key 'Certificate' -Value $Certificate
  Add-ToHashTableIfNotNull $Headers -Key 'Description' -Value $Description
  Add-ToHashTableIfNotNull $Headers -Key 'MoreInfoUrl' -Value $MoreInfoUrl
  Add-ToHashTableIfNotNull $Headers -Key 'ReCompressZip' -Value $ReCompressZip

  Write-Verbose "Signing $AssemblyFilename using $Url"
  $Headers.Keys | ForEach { Write-Verbose "`t $_`: $($Headers[$_])" }

  Invoke-WebRequest `
    -Uri $Url `
    -InFile $AssemblyFilename `
    -OutFile $AssemblyFilename `
    -Method Post `
    -ContentType 'binary/octet-stream' `
    -Headers $Headers

}
