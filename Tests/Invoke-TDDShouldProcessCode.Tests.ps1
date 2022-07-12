BeforeAll {
    . $PSScriptRoot\..\TDDSeams\Public\Invoke-TDDShouldProcessCode.ps1
    . $PSScriptRoot\..\TDDSeams\Public\Invoke-TDDShouldProcess.ps1
}

Describe 'Invoke-TDDShouldProcessCode' {
    BeforeAll {
        function CommandUnderTest {
            Get-Command 'Invoke-TDDShouldProcessCode'
        }

        # To prevent prompting, make sure the should process isn't actually invoked
        Mock Invoke-TDDShouldProcess { $false }
    }

    It "Should exist" {
        CommandUnderTest | Should -Not -BeNullOrEmpty
    }

    It 'Should have a Mandatory parameter: Context' {
        CommandUnderTest | Should -HaveParameter 'Context' -Type 'System.Management.Automation.PSCmdlet' -Mandatory
    }

    It 'Should have a mandatory string parameter: Target' {
        CommandUnderTest | Should -HaveParameter 'Target' -Type 'string' -Mandatory
    }

    It 'Should have an optional string parameter: Operation' {
        CommandUnderTest | Should -HaveParameter 'Operation' -Type 'string' 
    }

    It 'Should have an optional string parameter: Message' {
        CommandUnderTest | Should -HaveParameter 'Message' -Type 'string' 
    }

    It 'Should have  a mandatory scriptblock parameter: Code' {
        CommandUnderTest | Should -HaveParameter 'Code' -Type 'ScriptBlock' 
    }

    It 'Should have a switch parameter: Force' {
        CommandUnderTest | Should -HaveParameter 'Force' -Type 'switch' 
    }

    It 'Should have ShouldProcess support' {
        Test-TDDCmdletBinding -Command (CommandUnderTest) | Should -BeTrue
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

        Invoke-TDDShouldProcessCode -Context $PSCmdlet -Target 'Target' -Operation 'Operation' -Code { } -Force:$Force -Confirm:$Confirm

        if ($ShouldSetConfirmPreferenceToNone) {
            Should -Invoke Set-Variable -ParameterFilter { $Name -eq 'ConfirmPreference' -and $Value -eq 'None' }
        } else {
            Should -Not -Invoke Set-Variable
        }
    }

    It 'Should run Invoke-TDDShouldProcess' {
        Invoke-TDDShouldProcessCode -Context $PSCmdlet -Code { } -Message 'Msg' -Target 'Trgt' -Operation 'Op'

        Should -Invoke Invoke-TDDShouldProcess -ParameterFilter { 
            $Message -eq 'Msg' -and $Target -eq 'Trgt' -and $Operation -eq 'Op'
        }
    }
   
    It 'Should Invoke the code and return $true if Invoke-TDDShouldProcess returns $true' {

        function DummyFunction {
        }

        Mock DummyFunction { }
        Mock Invoke-TDDShouldProcess { $true }
        
        Invoke-TDDShouldProcessCode -Context $PSCmdlet -Target 'Target' -Operation 'Operation' -Code { DummyFunction } | Should -BeTrue

        Should -Invoke DummyFunction
    }

    It 'Should not Invoke the code and should return $false if Invoke-TDDShouldProcess returns $false' {

        function DummyFunction {
        }

        Mock DummyFunction { }
        Mock Invoke-TDDShouldProcess { $false }
        
        Invoke-TDDShouldProcessCode -Context $PSCmdlet -Target 'Target' -Operation 'Operation' -Code { DummyFunction } | Should -BeFalse

        Should -Not -Invoke DummyFunction
    }
}