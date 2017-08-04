
param(
[string] $port = 9100,
[string] $sqlUsername,
[string] $sqlPassword,
[string] $sqlDatabaseName,
[string] $servername,
[string] $webport,
[string] $regKey
)

# certificate for DSC pull server
if ((Get-ChildItem `
        -Path Cert:\LocalMachine\My `
        -DnsName $env:COMPUTERNAME) -eq $null)
{
$cert = New-SelfSignedCertificate `
        -CertstoreLocation Cert:\LocalMachine\My `
        -DnsName $env:COMPUTERNAME
}

# variables declared and used in script
$ComputerName = "Localhost"

$IISWindowsFeature = "Web-Server"
$NET45WindowsFeature = "NET-Framework-45-Features"
$ODataWindowsFeature = "ManagementOData"
$DSCWindowsFeatureName = "DSC-Service"


$PULLServerWebDirectory = "C:\PSDSCPullServer"
$PULLServerSubDirectory = "bin"
$iisAppPoolName = "DSCPullServer"
$iisAppPoolDotNetVersion = "v4.0"
$iisAppName = "PSDSCPullServer"

$certificateThumbPrint = $cert.Thumbprint

# installing IIS windows feature
Install-WindowsFeature -Name $IISWindowsFeature `
                    -IncludeManagementTools `
                    -ComputerName $ComputerName `
                    | out-null

# installing .NET 4.5 windows feature
Install-WindowsFeature -Name $NET45WindowsFeature `
                    -IncludeManagementTools  `
                    -ComputerName $ComputerName `
                    | out-null

# installing OData windows feature
Install-WindowsFeature -Name $ODataWindowsFeature `
                    -IncludeManagementTools  `
                    -ComputerName $ComputerName `
                    | out-null

# installing DSC windows feature
Install-WindowsFeature -Name $DSCWindowsFeatureName `
                    -IncludeManagementTools  `
                    -ComputerName $ComputerName `
                    | out-null


# creating folder for hosting DSC pull server web files
New-item -Path $PULLServerWebDirectory `
        -ItemType Directory `
        -Force -Confirm:$false  `
        | out-null

# creating bin folder within DSC pull server root directory
New-item -Path $($PULLServerWebDirectory + "\" + $PULLServerSubDirectory) `
            -ItemType Directory -Force -Confirm:$false `
            | out-null

# copying relevant items to DSC pull server root directory
# global.asax
Copy-Item -Path `
"$pshome\modules\psdesiredstateconfiguration\pullserver\Global.asax" `
-Destination "$PULLServerWebDirectory\Global.asax" `
-Force -Confirm:$false `
| out-null

# copying relevant items to DSC pull server root directory
# PSDSCPullServer.mof
Copy-Item `
-Path "$pshome\modules\psdesiredstateconfiguration\pullserver\PSDSCPullServer.mof" `
-Destination "$PULLServerWebDirectory\PSDSCPullServer.mof" `
-Force -Confirm:$false `
| out-null

# copying relevant items to DSC pull server root directory
# PSDSCPullServer.svc
Copy-Item `
-Path "$pshome\modules\psdesiredstateconfiguration\pullserver\PSDSCPullServer.svc" `
-Destination "$PULLServerWebDirectory\PSDSCPullServer.svc" `
-Force -Confirm:$false `
| out-null


# copying relevant items to DSC pull server root directory
# PSDSCPullServer.xml
Copy-Item `
-Path "$pshome\modules\psdesiredstateconfiguration\pullserver\PSDSCPullServer.xml" `
-Destination "$PULLServerWebDirectory\PSDSCPullServer.xml" `
-Force -Confirm:$false `
| out-null

# copying relevant items to DSC pull server root directory
# PSDSCPullServer.config
Copy-Item `
-Path "$pshome\modules\psdesiredstateconfiguration\pullserver\PSDSCPullServer.config" `
-Destination "$PULLServerWebDirectory\web.config" `
-Force -Confirm:$false `
| out-null

# copying relevant items to DSC pull server root directory
# IISSelfSignedCertModule.dll
Copy-Item `
-Path "$pshome\modules\psdesiredstateconfiguration\pullserver\IISSelfSignedCertModule.dll" -Destination "$($PULLServerWebDirectory + "\" + $PULLServerSubDirectory + "\IISSelfSignedCertModule.dll")" -Force -Confirm:$false  | out-null

# copying relevant items to DSC pull server root directory
# Microsoft.Powershell.DesiredStateConfiguration.Service.dll
Copy-Item `
-Path "$pshome\modules\psdesiredstateconfiguration\pullserver\Microsoft.Powershell.DesiredStateConfiguration.Service.dll" -Destination "$($PULLServerWebDirectory + "\" + $PULLServerSubDirectory + "\Microsoft.Powershell.DesiredStateConfiguration.Service.dll")" -Force -Confirm:$false | out-null

# copying relevant items to DSC pull server root directory
# Devices.mdb
Copy-Item -Path "$pshome\modules\psdesiredstateconfiguration\pullserver\Devices.mdb" -Destination "$env:programfiles\WindowsPowerShell\DscService\Devices.mdb" | out-null

# get next website id
$siteID = ((Get-Website | % { $_.Id } | Measure-Object -Maximum).Maximum + 1)

# check if app pool with given name already exists
# create if it does not exist
if ( (Get-Item IIS:\AppPools\$iisAppPoolName -ErrorAction SilentlyContinue) -eq $null)
{
    $null = New-WebAppPool -Name $iisAppPoolName

    $appPoolItem = Get-Item IIS:\AppPools\$iisAppPoolName
    $appPoolItem.managedRuntimeVersion = "v4.0"
    $appPoolItem.enable32BitAppOnWin64 = $true
    $appPoolItem.processModel.identityType = 0
    $appPoolItem | Set-Item
 }

# check if website with given name already exists
# create if it does not exist
 if ( (Get-Website -Name $iisAppName) -eq $null)
 {
    $webSite = New-WebSite -Name $iisAppName `
                           -Id $siteID `
                           -Port $port `
                           -IPAddress "*" `
                           -PhysicalPath $PULLServerWebDirectory `
                           -ApplicationPool $iisAppPoolName `
                           -Ssl

    # Remove existing binding for $port
    Remove-Item IIS:\SSLBindings\0.0.0.0!$port -ErrorAction Ignore | out-null

    # Create a new binding using the supplied certificate
    $null = Get-Item CERT:\LocalMachine\MY\$certificateThumbPrint | New-Item IIS:\SSLBindings\0.0.0.0!$port
}

# start web site  
Start-Website -Name $iisAppName  | out-null

# modify web.config for website
$appcmd = "$env:windir\system32\inetsrv\appcmd.exe" 

& $appCmd set AppPool $appPoolItem.name /processModel.identityType:LocalSystem `
| out-null
& $appCmd unlock config -section:access | out-null
& $appCmd unlock config -section:anonymousAuthentication | out-null
& $appCmd unlock config -section:basicAuthentication | out-null
& $appCmd unlock config -section:windowsAuthentication | out-null


# generate new guid for registration key
$guid = $regKey

# store registration key in RegistrationKeys.txt
# at C:\Program Files\WindowsPowerShell\DscService
New-Item -ItemType File -Value $guid `
         -Path "C:\Program Files\WindowsPowerShell\DscService" `
         -Name "RegistrationKeys.txt" `
         -Force -confirm:$false `
         | out-null

# load web.config content
$xml = [XML](Get-Content "$PULLServerWebDirectory\web.config")     
                                                                                
$RootDoc = $xml.get_DocumentElement()   

# add dbprovider appsetting element if it does not exists to web.config.                                                                                                                         
if (($xml.configuration.appSettings.add.Where({$PSItem.key -eq 'dbprovider'})).key `
    -eq $null)
{
  $subnode = $xml.CreateElement("add")  
  $subnode.SetAttribute("key", "dbprovider")                                                                                                                    
  $subnode.SetAttribute("value", "System.Data.OleDb")                                                                                                                    
  $RootDoc.appSettings.AppendChild($subnode) | out-null
}

# add dbconnectionstr appsetting element if it does not exists to web.config.                                                                                                                         
if (($xml.configuration.appSettings.add.Where({$PSItem.key -eq 'dbconnectionstr'})).key `
    -eq $null)
{
  $subnode = $xml.CreateElement("add")  
  $subnode.SetAttribute("key", "dbconnectionstr")                                                                                                                    
  $subnode.SetAttribute("value", `
  "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=C:\Program Files\WindowsPowerShell\DscService\Devices.mdb;")                                                                                                                    
  $RootDoc.appSettings.AppendChild($subnode) | out-null
}

# add ConfigurationPath appsetting element if it does not exists to web.config.   
if (($xml.configuration.appSettings.add.Where({$PSItem.key -eq 'ConfigurationPath'})).key -eq $null)
{
    $subnode = $xml.CreateElement("add")  
    $subnode.SetAttribute("key", "ConfigurationPath")  | out-null                                                                                                                  
    $subnode.SetAttribute("value", "C:\Program Files\WindowsPowerShell\DscService\Configuration")                                                                                                                    
    $RootDoc.appSettings.AppendChild($subnode) | out-null
}

# add ModulePath appsetting element if it does not exists to web.config. 
if (($xml.configuration.appSettings.add.Where({$PSItem.key -eq 'ModulePath'})).key -eq $null)
{
    $subnode = $xml.CreateElement("add")  
    $subnode.SetAttribute("key", "ModulePath")                                                                                                                    
    $subnode.SetAttribute("value", "C:\Program Files\WindowsPowerShell\DscService\Modules")                                                                                                                    
    $RootDoc.appSettings.AppendChild($subnode) | out-null
}

# add RegistrationKeyPath appsetting element if it does not exists to web.config. 
if (($xml.configuration.appSettings.add.Where({$PSItem.key -eq 'RegistrationKeyPath'})).key -eq $null)
{
    $subnode = $xml.CreateElement("add")  
    $subnode.SetAttribute("key", "RegistrationKeyPath")                                                                                                                    
    $subnode.SetAttribute("value", "C:\Program Files\WindowsPowerShell\DscService")                                                                                                                    
    $RootDoc.appSettings.AppendChild($subnode)  | out-null
}    

# save web.config with changes                                                                                                                     
$xml.Save("$PULLServerWebDirectory\web.config")  
 
# open firewall rule for pull server web application port defined by incoming parameter
if (!(Get-NetFirewallRule | where {$_.Name -eq "PullServerRule"})) {
   New-NetFirewallRule -Name "PullServerRule" `
                        -DisplayName "Ninety" `
                        -Protocol tcp `
                        -LocalPort $port `
                        -Action Allow -Enabled True `
                        | out-null
 }

# Create a new folder for executing DSC configuration
New-Item -Path $PSScriptRoot\IISInstall `
        -ItemType Directory -Force `
        -Confirm:$false | out-null

# Registering Nuget as Package source
Register-PackageSource -Name Nuget `
                    -Location https://www.nuget.org/api/v2/ `
                    -ProviderName Nuget `
                    -Trusted -Force -ForceBootstrap `
                    | out-null

# Registering Chocolatey as Package source
Register-PackageSource -Name chocolatey `
                       -Location http://chocolatey.org/api/v2/ `
                       -ProviderName chocolatey `
                       -Trusted -Force -ForceBootstrap `
                       | out-null

# installing xWebAdministration DSC resources 
install-module -Name xWebAdministration `
               -RequiredVersion 1.14.0.0 `
               -Force -Confirm:$false | out-null

# installing xWebDeploy DSC resources 
install-module -Name xwebdeploy `
               -RequiredVersion 1.2.0.0 `
               -Force -Confirm:$false | out-null

# Executing IIsInstall.ps1 to generate and deploy DSC configuration
# files on pull server used by containers to configure their
# IIS settings
if((Get-Item 'C:\Program Files\WindowsPowerShell\DscService\Configuration\IISInstall.mof' `
        -ErrorAction SilentlyContinue) -eq $null)
{
  . $PSScriptRoot\IISInstall.ps1 -webport $webport| Out-Null
}
 
 # connect to Azure SQL database and create table structure for
 # sample onlone medicine web application
 try
 {
    $ConnectionString = "Password=$sqlPassword;Persist Security Info=False;User ID=$sqlUsername;`
                   Initial Catalog=$sqlDatabaseName;Data Source=$servername.database.windows.net"
    $cmdtext = Get-Content -Path "$PSScriptRoot\OnlinePharmacy.sql"
    $con = New-Object "System.Data.SqlClient.SQLConnection"

            $sqlcmd = New-Object "System.Data.SqlClient.SqlCommand"	    
	        $con.ConnectionString = $ConnectionString
	        $con.Open() 
            $sqlcmd.connection = $con
            $sqlcmd.CommandText = "Select count(*) from dbo.Drug"
            $output = $sqlcmd.ExecuteScalar()
            if($output -lt 0 -or $output -eq $null )
            {
                $sqlcmd.CommandText = $cmdtext
                $sqlcmd.CommandType = [System.Data.CommandType]::Text
                $result = $sqlcmd.ExecuteNonQuery()

            }
  }
  catch
  {
    $sqlcmd.CommandText = $cmdtext
    $sqlcmd.CommandType = [System.Data.CommandType]::Text
    $result = $sqlcmd.ExecuteNonQuery()
  }


$HostName = $env:computername
$cert = Get-ChildItem -Path cert:\LocalMachine\My\* -DnsName $HostName -ErrorAction SilentlyContinue
if ($cert -eq $null)
{
    $cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName $HostName

}

    New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $cert.Thumbprint –Force | out-null
    New-NetFirewallRule -DisplayName 'Windows Remote Management (HTTPS-In)' -Name 'Windows Remote Management (HTTPS-In)' -Profile Any -LocalPort 5986 -Protocol TCP | out-null
    Restart-Service winrm | out-null

# registrationkey is set for output
# used for setting the LCM configuration of containers
# to connect to this pull server        
 Write-Output $guid.Guid
