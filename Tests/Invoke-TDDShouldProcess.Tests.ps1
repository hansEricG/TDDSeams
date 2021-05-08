BeforeAll {
    . $PSScriptRoot\..\TDDSeams\Public\Invoke-TDDShouldProcess.ps1
}

Describe 'Invoke-TDDShouldProcess' {
    BeforeAll {
        function CommandUnderTest {
            Get-Command 'Invoke-TDDShouldProcess'
        }
    }

    It "Should exist" {
        CommandUnderTest | Should -Not -BeNullOrEmpty
    }

    It 'Should have a Mandatory parameter: Context' {
        CommandUnderTest | Should -HaveParameter 'Context' -Type 'System.Management.Automation.PSCmdlet' -Mandatory
    }

    It 'Should have a string parameter: Target' {
        CommandUnderTest | Should -HaveParameter 'Target' -Type 'string' 
    }

    It 'Should have a string parameter: Operation' {
        CommandUnderTest | Should -HaveParameter 'Operation' -Type 'string' 
    }

    It 'Should have a string parameter: Message' {
        CommandUnderTest | Should -HaveParameter 'Message' -Type 'string' 
    }
}