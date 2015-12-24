#requires -Version 4 -Modules Pester

Describe 'Get-BuildFile' {

    function TestShouldBeFound($currentFolderPath, $expectedBuildFilePath) {
        $currentFolder = New-Item $currentFolderPath -ItemType Directory
        $expectedBuildFile = New-Item $expectedBuildFilePath -ItemType File

        $buildFile = Get-BuildFile -CurrentFolder $currentFolder

        It 'should be found' {
            $buildFile.FullName | Should Be $expectedBuildFile.FullName
        }
    }

    Context 'When a build.ps1 exists in the current folder' {
        TestShouldBeFound -currentFolderPath "TestDrive:\folder1\folder2\currentfolder" -expectedBuildFilePath "TestDrive:\folder1\folder2\currentfolder\build.ps1"
    }

    Context 'When a .build.ps1 exists in the current folder' {
        TestShouldBeFound -currentFolderPath "TestDrive:\folder1\folder2\currentfolder" -expectedBuildFilePath "TestDrive:\folder1\folder2\currentfolder\.build.ps1"
    }


    Context 'When a build.ps1 exists in the parent folder' {
        TestShouldBeFound -currentFolderPath "TestDrive:\folder1\folder2\currentfolder" -expectedBuildFilePath "TestDrive:\folder1\folder2\build.ps1"
    }

    Context 'When a .build.ps1 exists in the parent folder' {
        TestShouldBeFound -currentFolderPath "TestDrive:\folder1\folder2\currentfolder" -expectedBuildFilePath "TestDrive:\folder1\folder2\.build.ps1"
    }

    Context 'When a build.ps1 exists in the root folder' {
        TestShouldBeFound -currentFolderPath "TestDrive:\folder1\folder2\currentfolder" -expectedBuildFilePath "TestDrive:\build.ps1"
    }

    Context 'When a .build.ps1 exists in the parent folder' {
        TestShouldBeFound -currentFolderPath "TestDrive:\folder1\folder2\currentfolder" -expectedBuildFilePath "TestDrive:\.build.ps1"
    }

    Context 'When no .build.ps1/build.ps1 exist' {
        $currentFolder = New-Item 'TestDrive:\folder1\folder2\currentfolder' -ItemType Directory
        It 'should throw en exception'{
            {Get-BuildFile -CurrentFolder $currentFolder} | Should Throw "Could not find a default .build.ps1 or build.ps1 file in $currentFolder or its parents. Giving up..."
        }
    }
}
