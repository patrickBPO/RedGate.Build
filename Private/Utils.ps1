[CmdletBinding()]
param()

function Execute-Command {
  [CmdletBinding()]
  param(
      [string] $Command,
      [string[]] $Arguments,
      [int[]] $ValidExitCodes=@(0)
  )

  $Command = Resolve-Path $Command

  Write-Output @"
Executing:
& $Command $Arguments
"@

  & $Command $Arguments

	if ($ValidExitCodes -notcontains $LastExitCode) {
		throw "Command {$command $arguments} exited with code $LastExitCode."
	}

}
