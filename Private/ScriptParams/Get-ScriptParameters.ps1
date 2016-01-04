<#
.SYNOPSIS
    Return a list of parameters defined in a powershell script
#>
function Get-ScriptParameters{
    [CmdletBinding()]
    param(
        # Path to the powershell script
        [Parameter(Mandatory)]
        [string] $File
    )

    # A list of parameters to ignore
    $private:reservedparams = 'WhatIf',
    'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'ErrorVariable', 'WarningVariable', 'OutVariable', 'OutBuffer',
    'PipelineVariable', 'InformationAction', 'InformationVariable'

    $command = Get-Command -Name $File -CommandType ExternalScript
    if($command.Parameters.Count -eq 0) {return}

    # Return the parameters that are not reserved by Powershell (not in $reservedparams)
    $command.Parameters.Keys |
        where { $reservedparams -notcontains $_ } |
        foreach { $command.Parameters[$_] }
}
