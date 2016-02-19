function LoadProjectFile {
    [CmdletBinding()]
    param(
        # The path to a .csproj or .vbproj file. (msbuild format)
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ProjectFile
    )

    # Crude parameter checking
    $ProjectFile = Resolve-Path $ProjectFile

    Write-Verbose "Loading project: $ProjectFile"
    try {
        [xml](Get-Content $ProjectFile)
    }
    catch {
        throw @"
Could not load $ProjectFile.
$_
"@
    }
}
