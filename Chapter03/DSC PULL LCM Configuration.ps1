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
            ServerURL = "https://10.4.0.4:9100/PSDSCPullServer.svc/"
            RegistrationKey = "7af6e556-6ef7-478c-a26e-ffdc4d877aa6"
            ConfigurationNames = @("EnableWebServer")
        }

        PartialConfiguration EnableWebServer
        {
            Description = 'Configuration for installing Web server'
            ConfigurationSource = '[ConfigurationRepositoryWeb]IISConfig'
            RefreshMode = 'Pull'
        }
    }
}

PartialConfigurationDemo -OutputPath "C:\LCMConfiguration" -Verbose

Set-DscLocalConfigurationManager -path “C:\LCMConfiguration” -force -verbose

Update-DscConfiguration -Wait -Verbose

Start-DscConfiguration -UseExisting -Wait -Force -Verbose


