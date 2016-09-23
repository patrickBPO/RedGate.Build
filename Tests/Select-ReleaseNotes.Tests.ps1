#requires -Version 4 -Modules Pester

Describe 'Read-ReleaseNotes' {
    InModuleScope RedGate.Build {
        Context 'Two Part Version' {
            Mock Get-Content { '# 1.2' }
            $v = Select-ReleaseNotes -ProductName "Test" -ReleaseNotesPath 'DoesNotExist\RELEASENOTES.md'
            $v.Version | Should Be '1.2'
            $v.Summary | Should Be 'Test 1.2'
            $v.Date | Should Be $nul
            $v.Blocks.General | Should Be $nul
        }
    }

    InModuleScope RedGate.Build {
        Context 'Three Part Version' {
            Mock Get-Content { '##1.2.3' }
            $v = Select-ReleaseNotes -ProductName "Test" -ReleaseNotesPath 'DoesNotExist\RELEASENOTES.md'
            $v.Version | Should Be '1.2.3'
            $v.Summary | Should Be 'Test 1.2.3'
            $v.Date | Should Be $nul
            $v.Blocks.General | Should Be $nul
        }
    }

    InModuleScope RedGate.Build {
        Context 'Four Part Version' {
            Mock Get-Content { '### 1.2.3.4   ' }
            $v = Select-ReleaseNotes -ProductName "Test" -ReleaseNotesPath 'DoesNotExist\RELEASENOTES.md'
            $v.Version | Should Be '1.2.3.4'
            $v.Summary | Should Be 'Test 1.2.3'
            $v.Date | Should Be $nul
            $v.Blocks.General | Should Be $nul
        }
    }
    
    InModuleScope RedGate.Build {
        Context 'SDT Top' {
            $v = Select-ReleaseNotes -ReleaseNotes @"
# SQL Dependency Tracker Release Notes
## 2.8.9
General content
### Strapline
100. Feature

### Features
Cool feature

### Fixes
* Nasty fix
"@
            $v.Version | Should Be '2.8.9'
            $v.Summary | Should Be 'Feature'
            $v.Date | Should Be $nul
            $v.Blocks.General | Should Be 'General content'
            $v.Blocks.Features | Should Be 'Cool Feature'
            $v.Blocks.Fixes | Should Be '* Nasty fix'
        }
    }
    
    InModuleScope RedGate.Build {
        Context 'SOC Date' {
            $v = Select-ReleaseNotes -ProductName "SQL Source Control" -ReleaseNotes @"
## 5.1.4
###### Released on 2016-07-08
"@
            $v.Version | Should Be '5.1.4'
            $v.Summary | Should Be 'SQL Source Control 5.1.4'
            $v.Date | Should Be ([DateTime] '2016-07-08')
            $v.Blocks.General | Should Be $nul
        }
    }
    
    InModuleScope RedGate.Build {
        Context 'SQL Compare Date' {
            $v = Select-ReleaseNotes -ProductName "SQL Compare" -ReleaseNotes @"
## 12.0.25.3064 - September 13th 2016
"@
            $v.Version | Should Be '12.0.25.3064'
            $v.Summary | Should Be 'SQL Compare 12.0.25'
            $v.Date | Should Be ([DateTime] '2016-09-13')
            $v.Blocks.General | Should Be $nul
        }
    }
        
    InModuleScope RedGate.Build {
        Context 'Multiple Versions' {
            $vs = Select-ReleaseNotes -ReleaseNotes @"
# SQL Dependency Tracker Release Notes
## 2.8.9
### Strapline
65. Updated SQL Compare Engine

### Features
* Updated to the latest SQL Compare engine, version 12, featuring a number of fixes and enhancements.  Removes support for SQL Server 2000 databases.

### Fixes
* Latest UI components, fixes initial window position, layout issues and a rare crash

## 2.8.8.523
###### Released on 2016-08-11
### Strapline
10. Bug fixes

### Fixes
* Updated feature usage reporting library
* Latest UI components, uses a more legible font on the menu
* Old activations of SQL Dependency Tracker now work as expected

## 2.8.7.512
###### Failed release on 2016-08-01
"@
            $vs.Length | Should Be 3
            $vs[0].Version | Should Be '2.8.9'
            $vs[0].Summary | Should Be 'Updated SQL Compare Engine'
            $vs[0].Date | Should Be $nul
            $vs[0].Blocks.General | Should Be $nul
            $vs[0].Blocks.Features | Should Be '* Updated to the latest SQL Compare engine, version 12, featuring a number of fixes and enhancements.  Removes support for SQL Server 2000 databases.'
            $vs[0].Blocks.Fixes | Should Be '* Latest UI components, fixes initial window position, layout issues and a rare crash'
            
            $vs[1].Version | Should Be '2.8.8.523'
            $vs[1].Summary | Should Be 'Updated SQL Compare Engine, Bug Fixes'
            $vs[1].Date | Should Be ([DateTime] '2016-08-11')
            $vs[1].Blocks.General | Should Be $nul
            $vs[1].Blocks.Features | Should Be $nul
            $vs[1].Blocks.Fixes | Should Be @"
* Updated feature usage reporting library
* Latest UI components, uses a more legible font on the menu
* Old activations of SQL Dependency Tracker now work as expected
"@
            
            $vs[2].Version | Should Be '2.8.7.512'
            $vs[2].Summary | Should Be 'Updated SQL Compare Engine, Bug Fixes'
            $vs[2].Date | Should Be ([DateTime] '2016-08-01')
            $vs[2].Blocks.General | Should Be $nul
            $vs[2].Blocks.Features | Should Be $nul
            $vs[2].Blocks.Fixes | Should Be $nul
        }
    }
    
    InModuleScope RedGate.Build {
        Context 'Latest Multiple Versions' {
            $v = Select-ReleaseNotes -ProductName "Test" -Latest -ReleaseNotes @"
# SQL Dependency Tracker Release Notes
## 2.8.9
### Features
* Updated to the latest SQL Compare engine, version 12, featuring a number of fixes and enhancements.  Removes support for SQL Server 2000 databases.

### Fixes
* Latest UI components, fixes initial window position, layout issues and a rare crash

## 2.8.8.523
###### Released on 2016-08-11
### Fixes
* Updated feature usage reporting library
* Latest UI components, uses a more legible font on the menu
* Old activations of SQL Dependency Tracker now work as expected

## 2.8.7.512
###### Failed release on 2016-08-01
"@
            $v.Version | Should Be '2.8.9'
            $v.Summary | Should Be 'Test 2.8.9'
            $v.Date | Should Be $nul
            $v.Blocks.General | Should Be $nul
            $v.Blocks.Features | Should Be '* Updated to the latest SQL Compare engine, version 12, featuring a number of fixes and enhancements.  Removes support for SQL Server 2000 databases.'
            $v.Blocks.Fixes | Should Be '* Latest UI components, fixes initial window position, layout issues and a rare crash'
        }
    }
}
