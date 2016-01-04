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

    Additional dynamic parameters (they depend on the build script file being used):
        -Task <String[]>
        The Task(s) to execute as defined in the build script file. Use tab-autocomplete to discover available tasks
            build -Task [Tab][Tab]

        Any parameter defined in the build script file can be used. Use tab-autocomplete to discover them.
            build -[Tab][Tab]

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

        # Add the -Task parameter. -ValidateSet means we'll get tab-completion based on the list of Task defined in the build script.
        New-DynamicParameter -Name 'Task' -Type ([string[]]) -ValidateSet $TaskList -HelpMessage 'One or more tasks to be invoked' -Dictionary $parameters

        # Add each parameter from the build script.
        Get-ScriptParameters -File $BuildFile | ForEach { New-DynamicParameter -Dictionary $parameters -Name $_.Name -Type $_.ParameterType }

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
