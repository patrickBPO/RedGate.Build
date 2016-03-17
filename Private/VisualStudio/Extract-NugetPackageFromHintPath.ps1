#
# Private function to parse the nuget package info from the value of a VS project 'HintPath'
#
# '..\..\packages\mypackage.1.2.3.4\lib\my.dll' | Extract-NugetPackageFromHintPath
# will return a pscustomobject with properties:
#   Id      = mypackage
#   Version = 1.2.3.4
#
function Extract-NugetPackageFromHintPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, Position = 0)]
        [string] $HintPath
    )
    process {

        Write-Verbose "Parsing $HintPath"

        # extract the nuget package name and version. ('packagename.packageversion') from the value of hintpath
        $packageNameAndVersion = ($HintPath | select-string -pattern '(?<=packages\\)([\w\d\.\-+]+)').matches.value
        if($packageNameAndVersion -eq $null) {
            Write-Warning "Could not extract package id and version from hintpath: $HintPath"
            return
        }

        # extract the 'packageversion' from 'packagename.packageversion' (should support semver 2)
        $packageVersion = ($packageNameAndVersion -split '\.' | where { $_ -match '^\d+$' -or $_ -match '^\d+[\w\d\-+]+$'}) -join '.'
        if($packageVersion -eq $null) {
            Write-Warning "Could not extract package version from $packageNameAndVersion"
            return
        }

        # extract the 'packagename' from 'packagename.packageversion'
        $packageName = $packageNameAndVersion -replace [regex]::Escape(".$packageVersion"), ''
        if($packageName -eq $packageNameAndVersion) {
            Write-Warning "Could not extract package name from $packageNameAndVersion. Extracted `$packageVersion is: $packageVersion"
            return
        }

        # Return the nuget package object.
        [pscustomobject] @{
            Id = $packageName
            Version = $packageVersion
        }
    }
}
