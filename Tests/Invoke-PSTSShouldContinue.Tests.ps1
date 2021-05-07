BeforeAll {
    . $PSScriptRoot\..\PSTestSeams\Public\Invoke-PSTSShouldContinue.ps1
}

Describe 'Invoke-PSTSShouldContinue' {
    BeforeAll {
        function CommandUnderTest {
            Get-Command 'Invoke-PSTSShouldContinue'
        }
    }

    It "Should exist" {
        CommandUnderTest | Should -Not -BeNullOrEmpty
    }

    It 'Should have a Mandatory parameter: Context' {
        CommandUnderTest | Should -HaveParameter 'Context' -Type 'System.Management.Automation.PSCmdlet' -Mandatory
    }

    It 'Should have a string parameter: Query' {
        CommandUnderTest | Should -HaveParameter 'Query' -Type 'string' 
    }

    It 'Should have a string parameter: Caption' {
        CommandUnderTest | Should -HaveParameter 'Caption' -Type 'string' 
    }

}