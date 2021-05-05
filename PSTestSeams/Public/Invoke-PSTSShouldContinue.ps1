function Invoke-PSTSShouldContinue {
    <#
    .SYNOPSIS
    A wrapper for the $PSCmdlet.ShouldContinue to enable mocking.
    .DESCRIPTION
    This function allows you to mock the built in ShouldContinue to enable testing code that otherwise prompts the user.
    
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
    
        if ($PSCmdlet.ShouldContinue("Target", 'Remove permanently')) {
            # Perform action
        } 
    }
    
    With code like this
    
    function Remove-Target {
        [CmdletBinding(ShouldProcess)]
    
        if (Invoke-PSTSShouldContinue -Context $PSCmdlet -Target "Target" -Action "Action")
    }
    
    To be able to write Pester tests similar to this
    
    It 'Should invoke ShouldContinue' {
        Mock Invoke-PSTSSShouldContinue { $True }
    
        Remove-Target $SomeTarget
    
        Should | -Invoke Invoke-PSTSUShouldContinue -Times 1 -Exactly
    }
    .LINK
    https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-shouldprocess
    
    .LINK
    https://pester.dev/
    #>
    
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            [System.Management.Automation.PSCmdlet]
            $Context,
            [string]
            $Target,
            [string]
            $Operation
        )
    
        $Context.ShouldContinue($Target, $Operation)
    }