$RootModule = Join-Path (Split-Path $PSScriptRoot -Parent) .\ProxyAlias\ProxyAlias.psd1

Remove-Module ProxyAlias -Force -ErrorAction SilentlyContinue
Import-Module $RootModule

Describe "Set-ProxyAlias" {
    Context "Input" {
        It "Takes CommandInfo objects" {
            {
                Get-Command Get-Command | Set-ProxyAlias -NewName Get-Syntax -PropertyName Syntax
            } |Should Not Throw
        }
        It "Takes Command Names as strings" {
            {
                Set-ProxyAlias -Name Get-Command -NewName Get-Syntax -PropertyName Syntax
            } |Should Not Throw
        }
    }
    Context "Output" {
        It "Creates a proxy function" {
            Get-Command Get-Command | Set-ProxyAlias -NewName Get-Syntax -PropertyName Syntax
            Get-Command Get-Syntax |Should BeOfType System.Management.Automation.FunctionInfo
        }
        It "Sets default parameter values" {
            Get-Command Get-Command | Set-ProxyAlias -NewName Get-Syntax -PropertyName Syntax
            $PSDefaultParameterValues['Get-Syntax:Syntax'] |Should Be $true
        }
    }
}
