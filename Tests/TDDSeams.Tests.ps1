BeforeAll {
    Import-Module TDDUtils
    
    # Suppress the PSUseDeclaredVarsMoreThanAssignments warning since it's not correct here.
    # Info on suppressing PSScriptAnalyzer rules can be found here:
    # https://github.com/PowerShell/PSScriptAnalyzer/blob/master/README.md#suppressing-rules
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    $ModuleName = 'TDDSeams'
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    $ModulePath = Join-Path $PSScriptRoot ..\$ModuleName\ -Resolve 
}

Describe 'TDDSeams Module' {
    
    Context 'Setup' {
        It 'Should have a root module file (psm1)' {
            "$ModulePath\$ModuleName.psm1" | Should -Exist
        }

        It 'Should have a manifest file (psd1)' {
            "$ModulePath\$ModuleName.psd1" | Should -Exist
        }

        It 'Should have valid powershell code' {
            Test-TDDPowerShellCode -Path "$ModulePath\$ModuleName.psm1" | Should -BeTrue
        }
    }

    Context 'Functions'{

        $ModuleName = 'TDDSeams'
        $ModulePath = Join-Path $PSScriptRoot ..\$ModuleName\ -Resolve
            $PublicFunctionFiles = Get-Item "$ModulePath/Public/*.ps1"
        foreach ($FunctionFile in $PublicFunctionFiles) {
            It "Public function file '$($FunctionFile.Name)' should have valid powershell code"  -TestCases @(
                @{
                    FunctionFile = $FunctionFile 
                }
            ) {
                Test-TDDPowerShellCode -Path $FunctionFile.PSPath | Should -BeTrue
            }

            It "Public function file '$($FunctionFile.Name)' should have a corresponding test file"  -TestCases @(
                @{
                    FunctionFile = $FunctionFile 
                }
            ) {
                "$ModulePath\..\Tests\$($FunctionFile.BaseName).Tests.ps1" | Should -Exist
            }

            It "Public function '$($FunctionFile.Name)' should be dot sourced and exported"  -TestCases @(
                @{
                    FunctionFile = $FunctionFile 
                }
            ) {
                $ModuleContent = Get-Content -Path "$ModulePath\$ModuleName.psm1"

                $ModuleContent | Should -Contain ". `$PSScriptRoot\Public\$($FunctionFile.Name)"
                $ModuleContent | Should -Contain "Export-ModuleMember $($FunctionFile.BaseName)"
            }

            It "Public function '$($FunctionFile.Name)' should have a help block!" -TestCases @(
                @{
                    FunctionFile = $FunctionFile 
                }
            ) {
                    $FunctionFile.PSPath | Should -FileContentMatch  '<#'
                    $FunctionFile.PSPath | Should -FileContentMatch  '#>'
                    $FunctionFile.PSPath | Should -FileContentMatch  '.SYNOPSIS'
                    $FunctionFile.PSPath | Should -FileContentMatch  '.DESCRIPTION'
                    $FunctionFile.PSPath | Should -FileContentMatch  '.EXAMPLE'
            }

            It "Public function '$($FunctionFile.Name)' should be an advanced function"  -TestCases @(
                @{
                    FunctionFile = $FunctionFile 
                }
            ) {
                    $FunctionFile.PSPath | Should -FileContentMatch 'function'
                    $FunctionFile.PSPath | Should -FileContentMatch 'cmdletbinding'
                    $FunctionFile.PSPath | Should -FileContentMatch 'param'
            }
            
        }

    }
}