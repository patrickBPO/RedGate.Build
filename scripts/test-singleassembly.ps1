<#
.SYNOPSIS
  Invoke-Build script to execute tests from a NUnit assembly.
.DESCRIPTION
  This script is packaged along with RedGate.Build to make it easy
  to execute NUnit test assemblies in parallel.
  It could be used like this from another Invoke-Build script:

  task TestsInParallel {
    $parallelTasks = @()
    GEt-ChildItem . -Filter *.Tests.dll | ForEach {
        $parallelTasks += @{
          File="packages\RedGate.Buid\tools\scripts\test-singleassembly.ps1"
          Task='TestSingleAssembly'
          Parameters= @{
            AssemblyPath="$OutputDir\$_"
            ExcludedCategories='Slow','Bugged'
          }
        }
    }
    Invoke-Builds $parallelTasks
  }
#>
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
