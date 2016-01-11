# _Init.ps1 is a script that can be used to initialise stuff when RedGate.Build is imported for the first time.
# (Like variables available within the module only.)

# Create the packages folder where nuget packages used by this module will be installed.
$PackagesDir = New-Item -Path "$PSScriptRoot\..\packages" -ItemType Directory -Force


# Store the path to nuget.exe.
$NugetExe = Resolve-Path "$PSScriptRoot\nuget.exe"

$DefaultNUnitVersion = '2.6.4'
$DefaultDotCoverVersion = '3.2.0'
$DefaultSmartAssemblyVersion = '6.8.0.248'


if ($Host.Name -eq "Default Host") {
    # Redefine Write-Host to avoid this error on Teamcity:
    # 'A command that prompts the user failed because the host program or the command type does not support user interaction'
    # This is only likely to happen when calling RedGate.Build functions from some Invoke-Build parallel tasks...
    # More info at: https://github.com/nightroman/Invoke-Build/wiki/Parallel-Builds#avoid-host-cmdlets-and-ui-members
    function global:Redirect-HostToOutput {
        # Write to the output stream instead because we still want to be able to see teamcity publish messages...
        Write-Output "$Args"
    }
    # Create a Write-Host alias to override the default Write-Host command.
    New-Alias -Name Write-Host -Value Redirect-HostToOutput -Force -Scope Global
}
