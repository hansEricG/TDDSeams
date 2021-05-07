BeforeAll {
    . $PSScriptRoot\..\PSTestSeams\Public\Invoke-PSTSShouldContinueCode.ps1
    . $PSScriptRoot\..\PSTestSeams\Public\Invoke-PSTSShouldContinue.ps1
}

Describe 'Invoke-PSTSShouldContinueCode' {
    BeforeAll {
        function CommandUnderTest {
            Get-Command 'Invoke-PSTSShouldContinueCode'
        }

        # To prevent prompting, make sure the should process isn't actually invoked
        Mock Invoke-PSTSShouldContinue { $false }
    }

    It "Should exist" {
        CommandUnderTest | Should -Not -BeNullOrEmpty
    }

    It 'Should have a Mandatory parameter: Context' {
        CommandUnderTest | Should -HaveParameter 'Context' -Type 'System.Management.Automation.PSCmdlet' -Mandatory
    }

    It 'Should have an optional string parameter: Query' {
        CommandUnderTest | Should -HaveParameter 'Query' -Type 'string' 
    }

    It 'Should have  an optional string parameter: Caption' {
        CommandUnderTest | Should -HaveParameter 'Caption' -Type 'string' 
    }

    It 'Should have  a mandatory scriptblock parameter: Code' {
        CommandUnderTest | Should -HaveParameter 'Code' -Type 'ScriptBlock' 
    }

    It 'Should have a switch parameter: Force' {
        CommandUnderTest | Should -HaveParameter 'Force' -Type 'switch' 
    }

    It 'Should be an advanced function' {
        Test-PSTUCmdletBinding -Command (CommandUnderTest) | Should -BeTrue
    }

    It 'Should run Invoke-PSTSShouldContinue if the Force flag is not set' {
        Invoke-PSTSShouldContinueCode -Context $PSCmdlet -Code { } -Query 'Qry' -Caption 'Cptn'

        Should -Invoke Invoke-PSTSShouldContinue -ParameterFilter { 
            $Query -eq 'Qry' -and $Caption -eq 'Cptn'
        }
    }
   
    It 'Should not run Invoke-PSTSShouldContinue if Force flag is set' {
        Invoke-PSTSShouldContinueCode -Context $PSCmdlet -Code { } -Force

        Should -Not -Invoke Invoke-PSTSShouldContinue
    }

    It 'Should Invoke the code if Force is set, or if ShouldContinue returns true' -TestCases @(
        @{ Force = $true; ShouldContinue = $true; ShouldInvokeCode = $true},
        @{ Force = $true; ShouldContinue = $false; ShouldInvokeCode = $true},
        @{ Force = $false; ShouldContinue = $true; ShouldInvokeCode = $true},
        @{ Force = $false; ShouldContinue = $false; ShouldInvokeCode = $false}
    ) {
        function DummyFunction {
        }
        Mock DummyFunction { }
        Mock Invoke-PSTSShouldContinue { $ShouldContinue }
        
        Invoke-PSTSShouldContinueCode -Context $PSCmdlet -Code { DummyFunction } -Force:$Force

        if ($ShouldInvokeCode) {
            Should -Invoke DummyFunction
        } else {
            Should -Not -Invoke DummyFunction
        }
    }
}