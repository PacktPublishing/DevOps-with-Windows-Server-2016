Configuration EnableWebServer
{
    Import-DscResource –ModuleName ’PSDesiredStateConfiguration’
    Node Webserver01
    {
        WindowsFeature IIS
        {
            Name = "Web-Server"
            Ensure = "Present"
        }
    }
}

EnableWebServer -OutputPath "C:\DSC-WebServer" -Verbose

Start-DscConfiguration -Path "C:\DSC-WebServer" -Wait -Force -Verbose 
