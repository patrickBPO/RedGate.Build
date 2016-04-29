<#
        .SYNOPSIS
        Installs a working copy of nodejs and npm.
        .DESCRIPTION
        Installs the RedGate.ThirdParty.NodeJs package to RedGate.Build\packages,
        unpacks nodejs to C:\Tools\NodeJs\x.x.x, and then returns an object with
        properties that represent paths to the nodejs dir, node.exe and npm.cmd.
        .PARAMETER Version
        The full 4-digit version number of the version of the
        RedGate.ThirdParty.NodeJs package that provides nodejs. You may also
        specify a 3-digit version of nodejs, as long as there is indeed an available
        associated version of the RedGate.ThirdParty.NodeJs package.
        The minimum supported version number is 6.0.0.
        .OUTPUTS
        An object that contains the following properties:
        - NodeJsVersion [string]: The actual installed version number of nodejs
        - NodeJsDir [string]: The location of the nodejs installation folder.
        - NodeExePath [string]: The path of the node.exe binary.
        - NpmCmdPath [string]: The path of the npm.cmd command.
#>
#requires -Version 2
function Install-NodeJsPackage 
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $False, Position = 0)]
        [string] $Version = $DefaultNodeJsPackageVersion
    )

    # First install the package
    Write-Verbose 'Installing RedGate.ThirdParty.NodeJs'
    $PackagePath = (Install-Package RedGate.ThirdParty.NodeJs $Version).FullName
  
    # Now unpack nodejs from the package.
    Write-Verbose 'Extracting nodejs'
    $InstallScriptPath = "$PackagePath\tools\install.ps1"
    $NodeJsDir = & "$InstallScriptPath"
    if ($NodeJsDir.EndsWith('\')) {
        $NodeJsDir = $NodeJsDir.Substring(0, $NodeJsDir.Length - 1)
    }
    Write-Verbose "nodejs directory = $NodeJsDir"

    # Craft the result.
    return @{
        NodeJsVersion = $NodeJsDir.Substring(1 + $NodeJsDir.LastIndexOf('\'));
        NodeJsDir = $NodeJsDir;
        NodeExePath = "$NodeJsDir\node.exe";
        NpmCmdPath = "$NodeJsDir\npm.cmd"
    }
}
