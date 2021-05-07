function Invoke-PSTSShouldContinueCode {
    # This implementation is based on the best practice recommendation in the following page:
    # https://powershellexplained.com/2020-03-15-Powershell-shouldprocess-whatif-confirm-shouldcontinue-everything/
    
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            [System.Management.Automation.PSCmdlet] $Context,
            [string] $Query,
            [string] $Caption,
            [Parameter(Mandatory)]
            [scriptblock] $Code,
            [switch] $Force
        )
    
        if ($Force -or (Invoke-PSTSShouldContinue -Context $Context -Query $Query -Caption $Caption)){
            $Code.Invoke()
        }

    }