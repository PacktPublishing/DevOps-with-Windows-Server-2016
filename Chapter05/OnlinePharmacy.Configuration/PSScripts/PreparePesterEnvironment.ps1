

Register-PackageSource -Name Nuget -Location https://www.nuget.org/api/v2/ -ProviderName Nuget -Trusted -Force -ForceBootstrap 
                    

# Registering Chocolatey as Package source
Register-PackageSource -Name chocolatey -Location http://chocolatey.org/api/v2/ -ProviderName chocolatey -Trusted -Force -ForceBootstrap 

# installing xWebAdministration DSC resources 
install-module -Name Pester -RequiredVersion "3.4.3" -Scope CurrentUser -Force -Confirm:$false

# installing xWebDeploy DSC resources 
install-module -Name OperationValidation -RequiredVersion 1.0.1 -Scope CurrentUser -Force -Confirm:$false 

Get-command -Module Pester | select name
Get-command -Module Microsoft.PowerShell.Operation.Validation | select name
                   