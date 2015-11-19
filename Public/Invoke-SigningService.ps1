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
    Signs a .NET assembly, jar file, VSIX installer or ClickOnce application.

    .DESCRIPTION
    Signs a .NET assembly, jar file, VSIX installer or ClickOnce application using the Redgate signing service.

    .PARAMETER FilePath
    The path of the file to be signed. The file will me updated in place with a corresponding signed version.
    The path may reference a .NET assembly (.exe or .dll), a java Jar file, a Visual Studio Installer (.vsix) or a .NET ClickOnce application (.application).
    This parameter has several aliases (JarPath, VsixPath, ClickOnceApplicationPath and AssemblyPath) to help improve readability of your scripts.

    .PARAMETER SigningServiceUrl
    The url of the signing service. If unspecified, defaults to the $env:SigningServiceUrl environment variable.

    .PARAMETER Certificate
    Indicates which signing certificate to use. Defaults to 'master'.

    .PARAMETER Description
    An optional description. Defaults to 'Red Gate Software Ltd.'.

    .PARAMETER MoreInfoUrl
    An optional URL that can be used to specify more information about the signed assembly by end-users. Defaults to 'http://www.red-gate.com'.

    .OUTPUTS
    The FilePath parameter, to enable call chaining.

    .EXAMPLE
    $AssemblyPath = "$SourceDir\Build\$Configuration\RedGate.MyAwesomeProduct.dll"
    Invoke-SigningService -SigningServiceUrl 'https://signingservice.internal/sign' -AssemblyPath $AssemblyPath

    This shows how to sign a .NET dll, with the signing service URL being explicitly stated.

    .EXAMPLE
    $VsixPath = "$SourceDir\Build\$Configuration\RedGate.MyAwesomeProduct.Installer.vsix"
    Invoke-SigningService -VsixPath $AssemblyPath

    This shows how to sign a Visual Studio Installer file. The signing service URL is taken from the $env:SigningServiceUrl environment variable that is present on all of the build agents.
#>
function Invoke-SigningService {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [Alias('JarPath', 'VsixPath', 'ClickOnceApplicationPath', 'AssemblyPath')]
        [string] $FilePath,

        [Parameter(Mandatory = $False)]
        [string] $SigningServiceUrl = $env:SigningServiceUrl,

        [Parameter(Mandatory = $False)]
        [string] $Certificate = 'Master',

        [Parameter(Mandatory = $False)]
        [string] $Description = 'Red Gate Software Ltd.',

        [Parameter(Mandatory = $False)]
        [string] $MoreInfoUrl = 'http://www.red-gate.com'
    )

    process {
        # Simple error checking.
        if ([String]::IsNullOrEmpty($SigningServiceUrl)) {
            throw 'Cannot sign assembly. -SigningServiceUrl was not specified and the SigningServiceUrl environment variable is not set.'
        }
        if (!(Test-Path $FilePath)) {
            throw "File not found: $FilePath"
        }

        # Determine the file type.
        $FileType = $Null
        switch ([System.IO.Path]::GetExtension($FilePath)) {
            '.exe' { $FileType = 'Exe' }
            '.dll' { $FileType = 'Exe' }
            '.vsix' { $FileType = 'Vsix' }
            '.jar' { $FileType = 'Jar' }
            '.application' { $FileType = 'ClickOnce' }
            default { throw "Unsupported file type: $AssemblyPath" }
        }

        # Make the web request to the signing service.
        $Headers = @{};
        Add-ToHashTableIfNotNull $Headers -Key 'FileType' -Value $FileType
        Add-ToHashTableIfNotNull $Headers -Key 'Certificate' -Value $Certificate
        Add-ToHashTableIfNotNull $Headers -Key 'Description' -Value $Description
        Add-ToHashTableIfNotNull $Headers -Key 'MoreInfoUrl' -Value $MoreInfoUrl

        Write-Verbose "Signing $FilePath using $SigningServiceUrl"
        $Headers.Keys | ForEach { Write-Verbose "`t $_`: $($Headers[$_])" }

        $Response = Invoke-WebRequest `
            -Uri $SigningServiceUrl `
            -InFile $FilePath `
            -OutFile $FilePath `
            -Method Post `
            -ContentType 'binary/octet-stream' `
            -Headers $Headers

        # TODO: How should we check the response? Need to fail if the signing failed.

        return $FilePath
    }
}
