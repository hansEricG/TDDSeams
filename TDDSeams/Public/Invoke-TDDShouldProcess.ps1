function Invoke-TDDShouldProcess {
<#
.SYNOPSIS
A wrapper for the $PSCmdlet.ShouldProcess to enable mocking.

.DESCRIPTION
This function allows you to mock the built in ShouldProcess to enable testing code that otherwise prompts the user.

.PARAMETER Context
The $PSCmdlet object of the calling function

.PARAMETER Target
An optional description of the target on which the operation is performed

.PARAMETER Operation
An optional description of the action performed

.PARAMETER Message
An optional message to the user.

.EXAMPLE
Replace code like this

function Do-SomeOperation {
    [CmdletBinding(ShouldProcess)]

    if ($PSCmdlet.ShouldProcess("Some Target", 'Some Operation')) {
        # Perform operation
    } 
}

With code like this

function Do-SomeOperation {
    [CmdletBinding(ShouldProcess)]

    if (Invoke-TDDShouldProcess -Context $PSCmdlet -Target "Target" -Action "Action") {
        # Performa operation
    }
}

To be able to write Pester tests similar to this

It 'Should invoke ShouldProcess' {
    Mock Invoke-TDDSShouldProcess { $True }

    Do-SomeOperation $SomeTarget

    Should | -Invoke Invoke-TDDShouldProcess -Times 1 -Exactly
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
        $Operation,
        [string]
        $Message
    )

    if ($Message) {
        $Context.ShouldProcess($Message, $Target, $Operation)
    } else {
        $Context.ShouldProcess($Target, $Operation)
    }
}