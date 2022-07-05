function Invoke-TDDShouldContinue {
    <#
    .SYNOPSIS
    A wrapper for the $PSCmdlet.ShouldContinue to enable mocking.

    .DESCRIPTION
    This function allows you to mock the built in ShouldContinue to enable testing code that otherwise prompts the user.
    
    .PARAMETER Context
    The $PSCmdlet object of the calling function
    
    .PARAMETER Query
    A message to the user, describing the action to be performed.
    
    .PARAMETER Caption
    The title of the action to be performed performed
    
    .EXAMPLE
    Replace code like this
    
    function Remove-Something {
        [CmdletBinding(ShouldProcess)]
    
        if ($PSCmdlet.ShouldContinue("Do you want to permanently remove the file?", 'Delete file')) {
            # Perform action
        } 
    }
    
    With code like this
    
    function Remove-Target {
        [CmdletBinding(ShouldProcess)]
    
        if (Invoke-TDDShouldContinue -Context $PSCmdlet -Query "Do you want to permanently remove the file?" 
            -Caption "Delete file") {
                # Perform action
        }
    }
    
    And be able to write Pester tests similar to this
    
    It 'Should invoke ShouldContinue' {
        Mock Invoke-TDDShouldContinue -ModuleName TDDSeams { $True }
    
        Remove-Target $SomeTarget
    
        Should | -Invoke Invoke-TDDShouldContinue -ModuleName TDDSeams -Times 1 -Exactly
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
            [Parameter(Mandatory)]
            [string]
            $Query,
            [Parameter(Mandatory)]
            [string]
            $Caption
        )
    
        $Context.ShouldContinue($Query, $Caption)
    }