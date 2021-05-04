function Invoke-PSTUShouldProcess {
<#
.SYNOPSIS
A wrapper for the $PSCmdlet.ShouldProcess to enable mocking.
.DESCRIPTION
This function allows you to mock the built in ShouldProcess to enable testing code that otherwise prompts the user.

.PARAMETER Context
The $PSCmdlet object of the calling function

.PARAMETER Target
An optional description of the target on which the operation is performed

.PARAMETER Action
An optional description of the action performed

.EXAMPLE
Replace code like this

function Remove-Target {
    [CmdletBinding(ShouldProcess)]

    if ($PSCmdlet.ShouldProcess("Target", 'Remove permanently')) {
        # Perform action
    } 
}

With code like this

function Remove-Target {
    [CmdletBinding(ShouldProcess)]

    if (Invoke-PSTUShouldProcess -Context $PSCmdlet -Target "Target" -Action "Action")
}

To be able to write Pester tests similar to this

It 'Should invoke ShouldProcess' {
    Mock Invoke-PSTSUShouldProcess { $True }

    Remove-Target $SomeTarget

    Should | -Invoke Invoke-PSTSUShouldProcess -Times 1 -Exactly
}
.LINK
https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-shouldprocess

.LINK
https://pester.dev/
#>

    # Suppress the PSShouldProcess warning since we're wrapping ShouldProcess to be able to mock it from a Pester test.
    # Info on suppressing PSScriptAnalyzer rules can be found here:
    # https://github.com/PowerShell/PSScriptAnalyzer/blob/master/README.md#suppressing-rules
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCmdlet]
        $Context,
        [string]
        $Target,
        [string]
        $Action
    )

    $Context.ShouldProcess($Target, $Action)
}