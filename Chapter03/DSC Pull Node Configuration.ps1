Configuration EnableWebServer
{
    Import-DscResource –ModuleName ’PSDesiredStateConfiguration’
    Node EnableWebServer
    {
        WindowsFeature IIS
        {
            Name = "Web-Server"
            Ensure = "Present"
        }
    }
}

EnableWebServer -OutputPath “$env:ProgramFiles\WindowsPowershell\DSCService\Configuration” -Verbose

New-DSCCheckSum -ConfigurationPath “$env:ProgramFiles\WindowsPowershell\DSCService\Configuration\EnableWebServer.mof”  -OutPath “$env:ProgramFiles\WindowsPowershell\DSCService\Configuration\” -Force