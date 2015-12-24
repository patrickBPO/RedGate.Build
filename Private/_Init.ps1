# _Init.ps1 is a script that can be used to initialise stuff when RedGate.Build is imported for the first time.
# (Like variables available within the module only.)

$_ModuleDir = Resolve-Path "$PSScriptRoot\.."
# Create the packages folder where nuget packages used by this module will be installed.
$_PackagesDir = New-Item -Path "$_ModuleDir\packages" -ItemType Directory -Force

$_DefaultNUnitVersion = '2.6.4'
$_DefaultDotCoverVersion = '3.2.0'
$_DefaultSmartAssemblyVersion = '6.8.0.248'
