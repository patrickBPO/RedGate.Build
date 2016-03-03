<#
.SYNOPSIS
  Convert msbuild errors and warnings to powershell ones.
.DESCRIPTION
  Parse input and look for
      * : warning *:* to detect warnings
      * : error *:* to detect errors
  And convert them using Write-Warning and Write-Error
#>
function Format-WarningsAndErrors {
    [CmdletBinding()]
    param(
        # The string to parse
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeLine = $true)]
        [string] $InputObject
    )
    process {
        if(!$InputObject) { return }

        if($InputObject -like "* : warning *:*") {
            Write-Warning $InputObject
        } elseif($InputObject -like "* : error *:*") {
            Write-Error $InputObject
        } else {
            $InputObject
        }
    }
}
