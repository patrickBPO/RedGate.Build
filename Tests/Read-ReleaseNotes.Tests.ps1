#requires -Version 4 -Modules Pester

Describe 'Read-ReleaseNotes' {
    InModuleScope RedGate.Build {
        Context 'Two Part Version' {
            Mock Get-Content { "# 1.2" }
            $info = Read-ReleaseNotes -ReleaseNotesPath "DoesNotExist\RELEASENOTES.md"
            $info.Content | Should Be "# 1.2"
            $info.Version | Should Be "1.2"
        }

        Context 'Three Part Version' {
            Mock Get-Content { "# 1.2.3" }
            $info = Read-ReleaseNotes -ReleaseNotesPath "DoesNotExist\RELEASENOTES.md" -ThreePartVersion
            $info.Content | Should Be "# 1.2.3"
            $info.Version | Should Be "1.2.3"
        }

        Context 'Two Part Of Three Part Version - Expected exception' {
            Mock Get-Content { "# 1.2.3" }
            { Read-ReleaseNotes -ReleaseNotesPath "DoesNotExist\RELEASENOTES.md" } | Should Throw
        }

        Context 'Release Notes' {
            Mock Get-Content {
                "# 1.2"
                "- Next line"
            }
            $info = Read-ReleaseNotes -ReleaseNotesPath "DoesNotExist\RELEASENOTES.md"
            $info.Content | Should Be "# 1.2`r`n- Next line"
            $info.Version | Should Be "1.2"
        }

        Context 'First Version' {
            Mock Get-Content {
                "# 1.2"
                "# 1.1"
            }
            $info = Read-ReleaseNotes -ReleaseNotesPath "DoesNotExist\RELEASENOTES.md"
            $info.Content | Should Be "# 1.2`r`n# 1.1"
            $info.Version | Should Be "1.2"
        }

        Context 'Ignore Preceding' {
            Mock Get-Content {
                "# Comment above everything"
                "# 19.99"
            }
            $info = Read-ReleaseNotes -ReleaseNotesPath "DoesNotExist\RELEASENOTES.md"
            $info.Content | Should Be "# 19.99"
            $info.Version | Should Be "19.99"
        }

        Context 'Ignore Wrong Version' {
            Mock Get-Content {
                "# 1.2.3"
                "# 19.99"
            }
            $info = Read-ReleaseNotes -ReleaseNotesPath "DoesNotExist\RELEASENOTES.md"
            $info.Content | Should Be "# 19.99"
            $info.Version | Should Be "19.99"
        }
    }
}
