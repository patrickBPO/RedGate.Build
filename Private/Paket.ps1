function Get-Paket {
    [CmdletBinding()]
    param()

    if($_PaketExe) {
        return $_PaketExe
    }

    & "$PSScriptRoot\.paket\paket.bootstrapper.exe" | Write-Verbose

    # Store the path to paket.exe in a variable available in the scope of this module.
    $script:_PaketExe = Resolve-Path "$PSScriptRoot\.paket\paket.exe"

    return $_PaketExe
}

function Install-PaketPackages {
    [CmdletBinding()]
    param()

    begin {
        Push-Location $_ModuleDir
    }
    process {
        & (Get-Paket) install | Write-Verbose
    }
    end {
        Pop-Location
    }
}
