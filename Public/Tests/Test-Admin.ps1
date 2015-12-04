<#
.SYNOPSIS
    Determines if the console is elevated
.DESCRIPTION
    Returns true if running as an administrator, false otherwise.
#>
function Test-Admin {
    $identity  = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal( $identity )
    return $principal.IsInRole( [System.Security.Principal.WindowsBuiltInRole]::Administrator )
}
