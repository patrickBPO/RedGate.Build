#requires -Version 1
<#
        .SYNOPSIS
        Creates a new empty temp directory.

        .DESCRIPTION
        Creates a new empty temp directory.

        .OUTPUTS
        The path of the newly created temporary directory.
#>
function New-TempDir 
{
    $Path = "$env:TEMP\RedGate.Build\$([System.IO.Path]::GetRandomFileName())"
    Write-Verbose "Creating temp dir: $Path"
    return [string] (mkdir $Path)
}
