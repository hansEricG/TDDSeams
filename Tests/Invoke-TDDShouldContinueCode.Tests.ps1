BeforeAll {
    . $PSScriptRoot\..\TDDSeams\Public\Invoke-TDDShouldContinueCode.ps1
    . $PSScriptRoot\..\TDDSeams\Public\Invoke-TDDShouldContinue.ps1
}

Describe 'Invoke-TDDShouldContinueCode' {
    BeforeAll {
        function CommandUnderTest {
            Get-Command 'Invoke-TDDShouldContinueCode'
        }

        # To prevent prompting, make sure the should process isn't actually invoked
        Mock Invoke-TDDShouldContinue { $false }
    }

    It "Should exist" {
        CommandUnderTest | Should -Not -BeNullOrEmpty
    }

    It 'Should have a Mandatory parameter: Context' {
        CommandUnderTest | Should -HaveParameter 'Context' -Type 'System.Management.Automation.PSCmdlet' -Mandatory
    }

    It 'Should have a mandatory string parameter: Query' {
        CommandUnderTest | Should -HaveParameter 'Query' -Type 'string' -Mandatory
    }

    It 'Should have  a mandatory string parameter: Caption' {
        CommandUnderTest | Should -HaveParameter 'Caption' -Type 'string' -Mandatory
    }

    It 'Should have  a mandatory scriptblock parameter: Code' {
        CommandUnderTest | Should -HaveParameter 'Code' -Type 'ScriptBlock' 
    }

    It 'Should have a switch parameter: Force' {
        CommandUnderTest | Should -HaveParameter 'Force' -Type 'switch' 
    }

    It 'Should be an advanced function' {
        Test-TDDCmdletBinding -Command (CommandUnderTest) | Should -BeTrue
    }

    It 'Should run Invoke-TDDShouldContinue if the Force flag is not set' {
        Invoke-TDDShouldContinueCode -Context $PSCmdlet -Query 'Qry' -Caption 'Cptn' -Code { } 

        Should -Invoke Invoke-TDDShouldContinue -ParameterFilter { 
            $Query -eq 'Qry' -and $Caption -eq 'Cptn'
        }
    }
   
    It 'Should not run Invoke-TDDShouldContinue if Force flag is set' {
        Invoke-TDDShouldContinueCode -Context $PSCmdlet  -Query 'Are you sure?' -Caption 'Really?' -Code { } -Force

        Should -Not -Invoke Invoke-TDDShouldContinue
    }

    It 'Should Invoke the code and return true if Force is set, or if ShouldContinue returns true. Otherwise false should be returned.' -TestCases @(
        @{ Force = $true; ShouldContinue = $true; ShouldInvokeCode = $true},
        @{ Force = $true; ShouldContinue = $false; ShouldInvokeCode = $true},
        @{ Force = $false; ShouldContinue = $true; ShouldInvokeCode = $true},
        @{ Force = $false; ShouldContinue = $false; ShouldInvokeCode = $false}
    ) {
        function DummyFunction {
        }
        Mock DummyFunction { }
        Mock Invoke-TDDShouldContinue { $ShouldContinue }
        
        $ExpectedReturnValue = $ShouldInvokeCode
        Invoke-TDDShouldContinueCode -Context $PSCmdlet -Query 'Are you sure?' -Caption 'Really?' -Code { DummyFunction } -Force:$Force | Should -Be $ExpectedReturnValue

        if ($ShouldInvokeCode) {
            Should -Invoke DummyFunction
        } else {
            Should -Not -Invoke DummyFunction
        }
    }
}