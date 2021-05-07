function Invoke-PSTSShouldProcessCode {
        [CmdletBinding(SupportsShouldProcess)]
        param (
            [Parameter(Mandatory)]
            [System.Management.Automation.PSCmdlet] $Context,
            [string] $Target,
            [string] $Operation,
            [string] $Message,
            [Parameter(Mandatory)]
            [scriptblock] $Code,
            [switch] $Force        
        )
    
        if ($Force -and -not $Confirm){
            Set-Variable ConfirmPreference 'None'
        }

        if (Invoke-PSTSShouldProcess -Context $Context -Message:$Message -Target:$Target -Operation:$Operation) {
            $Code.Invoke()
        }
    }