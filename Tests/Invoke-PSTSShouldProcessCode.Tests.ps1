BeforeAll {
    . $PSScriptRoot\..\PSTestSeams\Public\Invoke-PSTSShouldProcessCode.ps1
    . $PSScriptRoot\..\PSTestSeams\Public\Invoke-PSTSShouldProcess.ps1
}

Describe 'Invoke-PSTSShouldProcessCode' {
    BeforeAll {
        function CommandUnderTest {
            Get-Command 'Invoke-PSTSShouldProcessCode'
        }

        # To prevent prompting, make sure the should process isn't actually invoked
        Mock Invoke-PSTSShouldProcess { $false }
    }

    It "Should exist" {
        CommandUnderTest | Should -Not -BeNullOrEmpty
    }

    It 'Should have a Mandatory parameter: Context' {
        CommandUnderTest | Should -HaveParameter 'Context' -Type 'System.Management.Automation.PSCmdlet' -Mandatory
    }

    It 'Should have an optional string parameter: Target' {
        CommandUnderTest | Should -HaveParameter 'Target' -Type 'string' 
    }

    It 'Should have  an optional string parameter: Operation' {
        CommandUnderTest | Should -HaveParameter 'Operation' -Type 'string' 
    }

    It 'Should have  an optional string parameter: Message' {
        CommandUnderTest | Should -HaveParameter 'Message' -Type 'string' 
    }

    It 'Should have  a mandatory scriptblock parameter: Code' {
        CommandUnderTest | Should -HaveParameter 'Code' -Type 'ScriptBlock' 
    }

    It 'Should have a switch parameter: Force' {
        CommandUnderTest | Should -HaveParameter 'Force' -Type 'switch' 
    }

    It 'Should have ShouldProcess support' {
        Test-PSTUCmdletBindingAttribute -Command (CommandUnderTest) -AttributeName 'SupportsShouldProcess' | Should -BeTrue
    }

    It 'Should set $ConfirmPreference to None if -Force and not -Confirm' -TestCases @(
        @{ Force = $true; Confirm = $true; ShouldSetConfirmPreferenceToNone = $false},
        @{ Force = $true; Confirm = $false; ShouldSetConfirmPreferenceToNone = $true},
        @{ Force = $false; Confirm = $true; ShouldSetConfirmPreferenceToNone = $false},
        @{ Force = $false; Confirm = $false; ShouldSetConfirmPreferenceToNone = $false}
    ) {
        # See the following link for more details on how to implement ShouldProcess
        # https://powershellexplained.com/2020-03-15-Powershell-shouldprocess-whatif-confirm-shouldcontinue-everything/

        Mock Set-Variable { }

        Invoke-PSTSShouldProcessCode -Context $PSCmdlet -Code { } -Force:$Force -Confirm:$Confirm

        if ($ShouldSetConfirmPreferenceToNone) {
            Should -Invoke Set-Variable -ParameterFilter { $Name -eq 'ConfirmPreference' -and $Value -eq 'None' }
        } else {
            Should -Not -Invoke Set-Variable
        }
    }

    It 'Should run Invoke-PSTSShouldProcess' {
        Invoke-PSTSShouldProcessCode -Context $PSCmdlet -Code { } -Message 'Msg' -Target 'Trgt' -Operation 'Op'

        Should -Invoke Invoke-PSTSShouldProcess -ParameterFilter { 
            $Message -eq 'Msg' -and $Target -eq 'Trgt' -and $Operation -eq 'Op'
        }
    }
   
    It 'Should Invoke the code if Invoke-PSTSShouldProcess returns $true' {

        function DummyFunction {
        }

        Mock DummyFunction { }
        Mock Invoke-PSTSShouldProcess { $true }
        
        Invoke-PSTSShouldProcessCode -Context $PSCmdlet -Code { DummyFunction }

        Should -Invoke DummyFunction
    }

    It 'Should not Invoke the code if Invoke-PSTSShouldProcess returns $false' {

        function DummyFunction {
        }

        Mock DummyFunction { }
        Mock Invoke-PSTSShouldProcess { $false }
        
        Invoke-PSTSShouldProcessCode -Context $PSCmdlet -Code { DummyFunction }

        Should -Not -Invoke DummyFunction
    }
}