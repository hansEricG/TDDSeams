BeforeAll {
    . $PSScriptRoot\..\PSTestSeams\Public\Invoke-PSTUShouldProcess.ps1
}

Describe 'Invoke-PSTUShouldProcess' {
    BeforeAll {
        function CommandUnderTest {
            Get-Command 'Invoke-PSTUShouldProcess'
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

    It 'Should have a string parameter: Action' {
        CommandUnderTest | Should -HaveParameter 'Action' -Type 'string' 
    }

}