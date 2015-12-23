function Get-Paket {
    [CmdletBinding()]
    param()

    if($PaketExe) {
        return $PaketExe
    }

    & "$PSScriptRoot\.paket\paket.bootstrapper.exe" | Write-Verbose

    # Store the path to paket.exe.
    $script:PaketExe = Resolve-Path "$PSScriptRoot\.paket\paket.exe"

    return $PaketExe
}

function Install-PaketPackages {
    [CmdletBinding()]
    param()

    begin {
        Push-Location $ModuleDir
    }

    process {
        $PaketExe = Get-Paket

        Execute-Command {
            & $PaketExe install
        } | Write-Verbose
    }

    end {
        Pop-Location
    }

}
