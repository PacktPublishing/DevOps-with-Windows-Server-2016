

param
(
    [string] $username,
    [string] $password,
    [string] $port,
    [string] $regKey,
    [string] $pullip,
    [string] $sqlUsername,
    [string] $sqlPassword,
    [string] $webport,
    [string] $sqlServer,
    [string] $databaseName
)

$HostName = $env:computername

"Downloading all files"

# creates a new folder at root directory
New-Item -Path $PSScriptRoot\downloads -ItemType Directory -Force -Confirm:$false

# next four instructions copies the files to newly created folder
Copy-Item -LiteralPath $PSScriptRoot\ChangeConnectionString.ps1 -Destination $PSScriptRoot\downloads\ChangeConnectionString.ps1 -Force
Copy-Item -LiteralPath $PSScriptRoot\Deployment.zip -Destination $PSScriptRoot\downloads\Deployment.zip -Force
Copy-Item -LiteralPath $PSScriptRoot\lcm.ps1 -Destination $PSScriptRoot\downloads\lcm.ps1 -Force
Copy-Item -LiteralPath $PSScriptRoot\dockerfile -Destination $PSScriptRoot\downloads\dockerfile -Force

# next four statements deletes the original files
Remove-Item "$PSScriptRoot\Deployment.zip" -Force -Confirm:$false
Remove-Item "$PSScriptRoot\ChangeConnectionString.ps1" -Force -Confirm:$false
Remove-Item "$PSScriptRoot\lcm.ps1" -Force -Confirm:$false
Remove-Item "$PSScriptRoot\dockerfile" -Force -Confirm:$false


"$PSScriptRoot\downloads\Deployment.zip"

# this script section unzips the deployment.zip containing web application file
if( (get-item -Path $PSScriptRoot\downloads\Deployment -force -ErrorAction SilentlyContinue) -eq $null )
{
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    function Unzip
    {
        param([string]$zipfile, [string]$outpath)

        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
    }

    Unzip "$PSScriptRoot\downloads\Deployment.zip" "$PSScriptRoot\downloads"
}

# deletes the original deployment.zip file
Remove-Item "$PSScriptRoot\downloads\Deployment.zip" -Force -Confirm:$false

# open firewall rule for port 2375 used by Docker client and Daemon
if (!(Get-NetFirewallRule | where {$_.Name -eq "Docker"})) {
    New-NetFirewallRule -Name "Docker" -DisplayName "Docker" -Protocol tcp -LocalPort 2375 -Action Allow -Enabled True
}

# open firewall rule for dynamic port used by web application
if (!(Get-NetFirewallRule | where {$_.Name -eq "webapp"})) {
    New-NetFirewallRule -Name "webapp" -DisplayName "webapp" -Protocol tcp -LocalPort $webport -Action Allow -Enabled True
}

# install containers windows feature if not already installed
if( (Get-WindowsFeature -Name containers) -eq $null )
{
    Install-WindowsFeature containers
}


# download and install Docker binaries - Docker Client and Docker Daemon at windows directory
if( (get-item -Path $env:windir\dockerd.exe -force -ErrorAction SilentlyContinue) -eq $null )
{
    Invoke-WebRequest "https://get.docker.com/builds/Windows/x86_64/docker-1.12.0.zip" -OutFile "$env:TEMP\docker-1.12.0.zip" -UseBasicParsing
    Expand-Archive -Path "$env:TEMP\docker-1.12.0.zip" -DestinationPath $env:TEMP -Force
    Copy-Item "$env:TEMP\Docker\Dockerd.exe" -Destination $env:windir -Force
    Copy-Item "$env:TEMP\Docker\Docker.exe" -Destination $env:windir -Force
}

# fail safe arrangement
Start-Sleep -Seconds 120

# preparing to remote on local machine
# this is needed because the newly downloaded 
# docker binaries are not picked by existing 
# powershell session
$username1 = "$HostName\$username"
$username1
$pass = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential  $username1, $pass
$soptions = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck 

# creating a new PSSession
$s = New-PSSession -ComputerName $env:computername -Credential $cred  -SessionOption $soptions

# registers Docker on virtual machine
Invoke-Command -Session $s  -ScriptBlock {
   if ((Get-Service -Name 'docker' -ErrorAction SilentlyContinue) -eq $null)
    {
        
        dockerd --register-service
        # registration take a while without waiting
        # to ensure that docker is registered before executing next instruction
        Start-Sleep -Seconds 300
        Start-Service docker -Confirm:$false
        Get-Service docker
    }

} 

# restarting Docker service to help it recognize the newly pulled image
Invoke-Command -Session $s  -ScriptBlock {
   docker pull microsoft/windowsservercore
     Restart-Service Docker | out-null
} 

# Remoting on local machine to check and create
# custom windows container image for
# web application
Invoke-Command -Session $s  -ScriptBlock { param($pathfiles, $pullip, $port, $regKey,  $sqlUsername,$sqlPassword, $sqlServer, $databaseName)
   Set-Location $pathfiles
   $aa = Docker images
   $toCreateImage = $false
    for($i = 0; $i -lt $aa.Length; $i++){
        if($aa[$i].StartsWith("iis")){
            $toCreateImage = $false
            break;
        }
        else
        {
            $toCreateImage = $true
            
        }
    }

    if ($toCreateImage -eq $true )
    {
        docker build --build-arg ipaddress=$pullip --build-arg port=$port --build-arg regkey=$regKey --build-arg sqlUsername=$sqlUsername --build-arg sqlPassword=$sqlPassword --build-arg sqlServer=$sqlServer --build-arg databaseName=$databaseName -t iis .
        Restart-Service Docker | out-null
    }
   
   
} -ArgumentList $PSScriptRoot\downloads, $pullip, $port, $regKey, $sqlUsername,$sqlPassword, $sqlServer, $databaseName | Out-Null

# Remoting on local machine to create container
# based on custom container image
Invoke-Command -Session $s  -ScriptBlock { param($webport)
    $portStr = $webport + ":" + $webport

  docker run -d -p $portStr iis

} -ArgumentList $webport| Out-Null

# checking if certificate for virtual machine exists already
# if not create a new certificate for secure remote powershell access to virtual machine
$cert = Get-ChildItem -Path cert:\LocalMachine\My\* -DnsName $HostName -ErrorAction SilentlyContinue
if ($cert -eq $null)
{
    $cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName $HostName
 
}
   New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $cert.Thumbprint –Force
    New-NetFirewallRule -DisplayName 'Windows Remote Management (HTTPS-In)' -Name 'Windows Remote Management (HTTPS-In)' -Profile Any -LocalPort 5986 -Protocol TCP
    Restart-Service winrm


