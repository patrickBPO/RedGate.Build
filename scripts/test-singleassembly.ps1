[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string] $AssemblyPath,
    # The version of the nuget package containing the NUnit executables (NUnit.Runners)
    [string] $NUnitVersion = '2.6.2',
    [switch] $Nunitx86,
    [string[]] $ExcludedCategories = @(),
    [string[]] $IncludedCategories = @(),
    [bool] $EnableCodeCoverage = $false,
    # The version of the nuget package containing DotCover.exe (JetBrains.dotCover.CommandLineTools)
    [string] $DotCoverVersion = '3.2.20150819.165728',
    [string] $DotCoverFilters = ''
)

task TestSingleAssembly {
  assert($AssemblyPath)

  Import-Module "$PsScriptRoot\..\RedGate.Build.psm1"

  Invoke-NUnitForAssembly `
    -AssemblyPath $AssemblyPath `
    -NUnitVersion $NUnitVersion `
    -x86:$Nunitx86.IsPresent `
    -ExcludedCategories $ExcludedCategories `
    -IncludedCategories $IncludedCategories `
    -EnableCodeCoverage $EnableCodeCoverage `
    -DotCoverVersion $DotCoverVersion `
    -DotCoverFilters $DotCoverFilters

  Remove-Module RedGate.Build
}

task . TestSingleAssembly
