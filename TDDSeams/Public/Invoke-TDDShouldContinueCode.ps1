function Invoke-TDDShouldContinueCode {
    <#
    .SYNOPSIS
    Prompts the user for confirmation before the given code block is invoked.

    .DESCRIPTION
    This command implements the best practice behaviour of ShouldContinue, as described in the following blog post:
    https://powershellexplained.com/2020-03-15-Powershell-shouldprocess-whatif-confirm-shouldcontinue-everything/
    
    .PARAMETER Context
    The $PSCmdlet object of the calling function
    
    .PARAMETER Query
    A message to the user, in the form of a question, describing the action to be performed and asking for confirmation.
    
    .PARAMETER Caption
    The title of the action to be performed
    
    .PARAMETER Force
    If set, the command will invoke the code without prompting the user.

    .OUTPUTS
    $true if the user gave consent and the provided code was run, otherwise $false
    
    .EXAMPLE
    function Remove-Something {
        [CmdletBinding()]
    
        Invoke-TDDShouldContinueCode 
            -Context $PSCmdlet 
            -Query 'Do you want to permanently remove the file?'  
            -Caption 'Delete file' 
            -Code {
                Remove-Item $SomeFilePath
            }
    }

    .LINK
    https://docs.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-shouldprocess
    #>
    
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            [System.Management.Automation.PSCmdlet] $Context,
            [Parameter(Mandatory)]
            [string] $Query,
            [Parameter(Mandatory)]
            [string] $Caption,
            [Parameter(Mandatory)]
            [scriptblock] $Code,
            [switch] $Force
        )
    
        if ($Force -or (Invoke-TDDShouldContinue -Context $Context -Query $Query -Caption $Caption)) {
            $Code.Invoke()
            $true
        } else {
            $false
        }

    }