[CmdletBinding()]
param()

function Execute-Command {
  [CmdletBinding(DefaultParameterSetName='ScriptBlock')]
  param(
      [Parameter(Mandatory=$true,ParameterSetName='Command')]
      [string] $Command,
      [Parameter(Mandatory=$true,ParameterSetName='Command')]
      [string[]] $Arguments,
      [Parameter(Mandatory=$true,ParameterSetName='ScriptBlock',Position=0)]
      [scriptblock] $ScriptBlock,
      [int[]] $ValidExitCodes=@(0)
  )

  if( $PsCmdlet.ParameterSetName -eq 'Command' ) {

    $Command = Resolve-Path $Command
    Execute-Command -ScriptBlock { & $Command $Arguments } -ValidExitCodes $ValidExitCodes

  } else {

    Write-Verbose @"
Executing: $ScriptBlock
"@

    . $ScriptBlock
  	if ($ValidExitCodes -notcontains $LastExitCode) {
  		throw "Command {$ScriptBlock} exited with code $LastExitCode."
  	}

  }
}
