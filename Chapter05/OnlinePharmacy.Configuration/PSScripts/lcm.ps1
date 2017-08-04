param
(
    [string] $port,
    [string] $regKey,
    [string] $ipaddress
)

# ipaddress and port number are concatenated
$str = "$ipaddress" + ":" + "$port"


[DSCLocalConfigurationManager()]
configuration PartialConfigurationDemo
{
    Node localhost
    {
        Settings
        {
            ConfigurationModeFrequencyMins = 30
            RefreshMode = 'Pull'
            RefreshFrequencyMins = 30 
            ConfigurationMode = "ApplyandAutoCorrect"
            RebootNodeIfNeeded = $true

        }

         ConfigurationRepositoryWeb IISConfig
        {
            ServerURL = "https://$($str)/psdscpullserver.svc"
            RegistrationKey = "$regkey"
            ConfigurationNames = @("IISInstall")
        }


        PartialConfiguration IISInstall
        {
            Description = 'Configuration for the IIS'
            ConfigurationSource = '[ConfigurationRepositoryWeb]IISConfig'
            RefreshMode = 'Pull'
        }
       

    }
}

# generate the configuration MOF file
PartialConfigurationDemo -OutputPath "$PSScriptRoot\Output" -Verbose

# send and apply the configuration to DSC LCM
Set-DscLocalConfigurationManager -Path "$PSScriptRoot\Output" -Verbose

# download the partial configuration from pull server
Update-DscConfiguration -Wait -Verbose

# apply the partial configuration on local container image
Start-DscConfiguration -UseExisting -Wait -Force -Verbose

