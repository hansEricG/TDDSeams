function Invoke-PSTSShouldProcessCode {
    <#
    .SYNOPSIS
    Invokes the built-in ShouldProcess before the given code block is invoked.

    .DESCRIPTION
    This command implements the best practice behaviour of ShouldProcess, as described in the following blog post:
    https://powershellexplained.com/2020-03-15-Powershell-shouldprocess-whatif-confirm-shouldcontinue-everything/
    
    .PARAMETER Context
    The $PSCmdlet object of the calling function
    
    .PARAMETER Target
    A description of the  target of the operation.
    
    .PARAMETER Operation
    A description of the operation to be performed
    
    .PARAMETER Message
    An optional custom message to be used instead of the built-in message
    
    .PARAMETER Force
    If set, the command will invoke the code without prompting the user.
    
    .EXAMPLE
    function Remove-Something {
        [CmdletBinding()]
    
        Invoke-PSTSShouldProcessCode -Context $PSCmdlet -Target 'My settings' -Operation 'Permanently remove' -Code {
            Remove-Item $SettingsFilePath
        }
    }
    
    .LINK
    https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-shouldprocess
    #>

        [CmdletBinding(SupportsShouldProcess)]
        param (
            [Parameter(Mandatory)]
            [System.Management.Automation.PSCmdlet] $Context,
            [string] $Target,
            [Parameter(Mandatory)]
            [string] $Operation,
            [Parameter(Mandatory)]
            [scriptblock] $Code,
            [string] $Message,
            [switch] $Force
        )
    
        if ($Force -and -not $Confirm){
            Set-Variable ConfirmPreference 'None'
        }

        if (Invoke-PSTSShouldProcess -Context $Context -Message:$Message -Target:$Target -Operation:$Operation) {
            $Code.Invoke()
            $true
        } else {
            $false
        }
    }