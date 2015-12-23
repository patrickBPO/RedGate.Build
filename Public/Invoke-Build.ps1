<#
.SYNOPSIS
    Execute a Invoke-Build build script

.DESCRIPTION
    Execute a Invoke-Build build script.
    This wrapper around Invoke-Build should help us with auto completion
    of tasks / build files and so on.

.OUTPUTS
    The value returned by this cmdlet

.EXAMPLE
    Example of how to use this cmdlet

.LINK
    https://github.com/nightroman/Invoke-Build
#>
Function Invoke-Build
{
    [CmdletBinding()]
    Param
    (
        # Path to an Invoke-Build build script
        [Parameter(Mandatory=$true, ValueFromPipeline, Position=0)]
        [string]$File,

        # One or more tasks to be invoked. If it is not specified, null, empty,
        # or equal to '.' then the task '.' is invoked if it exists, otherwise
        # the first added task is invoked.
        [Parameter(Mandatory=$false, Position=1)]
        [string[]] $Task

    )

    dynamicparam {

        $private:reservedparams = 'Task', 'File', 'Parameters', 'Checkpoint', 'Result', 'Safe', 'Summary', 'Resume', 'WhatIf',
        'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'ErrorVariable', 'WarningVariable', 'OutVariable', 'OutBuffer',
        'PipelineVariable', 'InformationAction', 'InformationVariable'


        $BuildTask = $PSBoundParameters['Task']
        $BuildFile = $PSBoundParameters['File']

        if (!(Test-Path $BuildFile)) {throw "Missing script '$BuildFile'."}


        $buildScriptCommand = Get-Command -Name $BuildFile -CommandType ExternalScript
        if($buildScriptCommand.Parameters.Count -eq 0) {return}

        $private:parameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        ($private:attributes = New-Object System.Collections.ObjectModel.Collection[Attribute]).Add((New-Object System.Management.Automation.ParameterAttribute))
        foreach($key in $buildScriptCommand.Parameters.Keys) {
            $p = $buildScriptCommand.Parameters[$key]
            if ($reservedparams -notcontains $p.Name) {
                $parameters.Add($p.Name, (New-Object System.Management.Automation.RuntimeDefinedParameter $p.Name, $p.ParameterType, $attributes))
            }
        }
        $parameters
    }

    begin {
        Install-PaketPackages
    }
    process {

        $PSBoundParameters

        #& $PackagesDir\Invoke-Build\tools\Invoke-Build.ps1 -File $BuildFile -Task $Task
    }
}
