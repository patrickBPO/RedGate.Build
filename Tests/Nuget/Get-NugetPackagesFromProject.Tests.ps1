#requires -Version 4 -Modules Pester

Describe 'Get-NugetPackagesFromProject' {

    $testProjectFile = New-Item 'TestDrive:\project.csproj' -ItemType File

    It 'should throw exception when project file path is null or empty' {
      {Get-NugetPackagesFromProject -ProjectFilePath ''} | Should Throw
      {Get-NugetPackagesFromProject -ProjectFilePath $null} | Should Throw
    }

    It 'should throw exception when project file does not exist' {
      {Get-NugetPackagesFromProject -ProjectFilePath 'TestDrive:\ThisIsNotTheFileYouAreLookingFor'} | Should Throw
    }

    It 'should work' {
        @"
<Project>
    <ItemGroup>
        <Reference>
            <HintPath>..\..\packages\mypackage.1.2.3.4\lib\my.dll</HintPath>
        </Reference>
        <Reference>
            <HintPath>..\..\packages\myotherpackage.4.3.2.1\lib\myotherdll.4.0.dll</HintPath>
        </Reference>
    </ItemGroup>
</Project>
"@ | Set-Content -Path $testProjectFile

        $result = $testProjectFile | Get-NugetPackagesFromProject
        $result.length | Should Be 2

        $result[0].Id | Should Be 'mypackage'
        $result[0].Version | Should Be '1.2.3.4'

        $result[1].Id | Should Be 'myotherpackage'
        $result[1].Version | Should Be '4.3.2.1'
    }
}
