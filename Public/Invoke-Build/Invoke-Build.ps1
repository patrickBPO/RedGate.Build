<#
.SYNOPSIS
    Execute a Invoke-Build build script

.DESCRIPTION
    Execute a Invoke-Build build script.
    This wrapper around Invoke-Build should help us with auto completion of tasks / parameters

    The build script file to execute can be set either by:
        * using the -File parameter.
        * setting the $env:BuildFile variable.
        * letting Get-BuildFile find the first [.]build.ps1 file in parent folders of the RedGate.Build module

.EXAMPLE
    build
    Use Invoke-Build to execute the first build script found by Get-BuildFile.

.EXAMPLE
    $env:BuildFile = 'C:\mybuildscript.ps1'; build -Configuration Release
    Use Invoke-Build to execute 'C:\mybuildscript.ps1'
    'C:\mybuildscript.ps1' is expected to define a $Configuration parameter that can accept 'Release' as a valid value.

.EXAMPLE
    build -File 'C:\mybuildscript.ps1' -Task 'clean'
    Use Invoke-Build to invoke the 'clean' task from the 'C:\mybuildscript.ps1' build script.

.LINK
    https://github.com/nightroman/Invoke-Build

.LINK
    Get-BuildFile
#>
Function Invoke-Build
{
    [CmdletBinding()]
    Param
    (
        # Path to an Invoke-Build build script.
        # If not set, default to $env:BuildFile.
        # If not set and $env:BuildFile is not set, use Get-BuildFile to
        # find the first [.]build.ps1 file that can be found (help Get-BuildFile for more info)
        [Parameter(Mandatory=$false, ValueFromPipeline, Position=0)]
        [string] $File = $env:BuildFile
    )

    dynamicparam {
        $BuildFile = $PSBoundParameters['File']

        if(!$BuildFile) {
            # -File was not specified, let's find a default one.
            $BuildFile = Get-BuildFile
            $PSBoundParameters['File'] = $BuildFile
        }
        $BuildFile = Resolve-Path $BuildFile -ErrorAction Stop

        # Load the list of tasks from the build File. We will use it to validate the -Task parameter
        $taskList = @(& $_PackagesDir\Invoke-Build\tools\Invoke-Build.ps1 ? $BuildFile | select -ExpandProperty Name | Sort)

        $private:parameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        function Add-Parameter([Parameter(ValueFromPipeline)]$parameter, $ParameterDictionary) {
            process {
                $ParameterDictionary.Add($parameter.Name, $parameter)
            }
        }

        function New-TaskParameter($TaskList) {
            # Generate the -Task parameter and create a set of valid tasks that can be passed in
            $private:taskParamAttributes = New-Object -Type System.Collections.ObjectModel.Collection[Attribute]
            $private:taskParamAttribute = New-Object -Type System.Management.Automation.ParameterAttribute
            $taskParamAttribute.Mandatory = $False
            $taskParamAttribute.HelpMessage = @"
One or more tasks to be invoked. If it is not specified, null, empty,
or equal to '.' then the task '.' is invoked if it exists, otherwise
the first added task is invoked.
"@
            # Create ValidationSetAttribute to make tab-complete work
            # Pass $TaskList which is the list of Invoke-Build Tasks defined in the $BuildFile script.
            $private:taskParamValidationSetAttribute = New-Object -Type System.Management.Automation.ValidateSetAttribute($TaskList)

            # Add attributes to the container
            $taskParamAttributes.Add($taskParamAttribute)
            $taskParamAttributes.Add($taskParamValidationSetAttribute)

            #Create the actual parameter and return it
            New-Object -Type System.Management.Automation.RuntimeDefinedParameter('Task', [String[]], $taskParamAttributes)
        }

        function Get-BuildScriptParameters() {
            $private:reservedparams = 'Task', 'File', 'Parameters', 'Checkpoint', 'Result', 'Safe', 'Summary', 'Resume', 'WhatIf',
            'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'ErrorVariable', 'WarningVariable', 'OutVariable', 'OutBuffer',
            'PipelineVariable', 'InformationAction', 'InformationVariable'

            $buildScriptCommand = Get-Command -Name $BuildFile -CommandType ExternalScript
            if($buildScriptCommand.Parameters.Count -eq 0) {return}

            ($private:attributes = New-Object System.Collections.ObjectModel.Collection[Attribute]).Add((New-Object System.Management.Automation.ParameterAttribute))
            foreach($key in $buildScriptCommand.Parameters.Keys) {
                $p = $buildScriptCommand.Parameters[$key]
                if ($reservedparams -notcontains $p.Name) {
                    # Create and return a new Parameter
                    New-Object System.Management.Automation.RuntimeDefinedParameter $p.Name, $p.ParameterType, $attributes
                }
            }
        }

        New-TaskParameter -TaskList $taskList | Add-Parameter -ParameterDictionary $parameters
        Get-BuildScriptParameters | Add-Parameter -ParameterDictionary $parameters

        # return the collection of dynamic parameters
        $parameters
    }

    begin {

    }
    process {
        # Quick check that our build script syntax is all right.
        Test-ScriptForParsingErrors -Path $PSBoundParameters['File']

        # help about_Splatting to get more info on @PSBoundParameters
        & $_PackagesDir\Invoke-Build\tools\Invoke-Build.ps1 @PSBoundParameters
    }
}
