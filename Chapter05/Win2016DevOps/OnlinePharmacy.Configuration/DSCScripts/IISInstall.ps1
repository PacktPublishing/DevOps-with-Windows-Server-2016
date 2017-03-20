
param(
    [string] $webport
)

Configuration IISInstall
{
    # module containing basic DSC resources
    Import-DscResource –ModuleName ’PSDesiredStateConfiguration’

    # module containing IIS related DSC resources
    Import-DscResource –ModuleName ’xWebAdministration’
    
    Node localhost
    {
       # installs IIS windows feature
       WindowsFeature IIS
        {
            Name = "Web-Server"
            Ensure = "Present"
            
        }
      
        # installs .NET 4.5 windows feature 
        WindowsFeature DotNet
        {
            Name = "net-framework-45-Core"
            Ensure = "Present"
            DependsOn = "[WindowsFeature]IIS"
        }

        # installs ASP.NET 4.5 windows feature 
        WindowsFeature AspNet45
        {
            Ensure          = "Present"
            Name            = "Web-Asp-Net45"
            DependsOn = "[WindowsFeature]DotNet"
        }

        # creates a new IIS application pool
        xWebAppPool WebsiteApplicationPool
        {
            Name = "MedicinePool"
            Ensure = "Present"
            State = "Started"
            DependsOn = "[WindowsFeature]AspNet45"

        }
         
        # creates a new directory for IIS website
        file CreateDirectory
        {
            DestinationPath = "C:\Inetpub\MVCWebsite"
            Ensure = "Present"
            Type = "Directory"
            DependsOn = "[xWebAppPool]WebsiteApplicationPool"

        }

        # creates a new Website in IIS 
        xWebsite CreateWebsite
        {
            Name = "MVCWebSite"
            PhysicalPath = "C:\Inetpub\MVCWebsite"
            Ensure = "Present"
            State = "Started"
            ApplicationPool = "MedicinePool"
            BindingInfo = MSFT_xWebBindingInformation{
                            port ="$webport"; protocol ="http"
            }
            DependsOn = "[file]CreateDirectory"
        }
 
    }
}

# generate the MOF file at same location of this script
IISInstall -OutputPath "$PSScriptRoot\IISInstall"

# generate checksum for DSC configuration
New-DSCCheckSum -ConfigurationPath "$PSScriptRoot\IISInstall" `
                -OutPath "$PSScriptRoot\IISInstall" -Force

# copy the MOF configuration to pull server well known configuration folder
Copy-Item -LiteralPath "$PSScriptRoot\IISInstall\localhost.mof" `
-Destination "$env:ProgramFiles\WindowsPowerShell\DscService\Configuration\IISInstall.mof" `
-Force

# copy the DSC Checksum to pull server well known configuration folder
Copy-Item -LiteralPath "$PSScriptRoot\IISInstall\localhost.mof.checksum" `
-Destination "$env:ProgramFiles\WindowsPowerShell\DscService\Configuration\IISInstall.mof.checksum" `
-Force



