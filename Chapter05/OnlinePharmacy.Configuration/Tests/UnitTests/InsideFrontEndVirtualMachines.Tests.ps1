
  <#
    Purpose:
        Verify that web application hosted on Azure virtual machine is configured with container and images and
        hosting web application within containers.

    Action:
        Login into both virtual machines hosted on Azure using New-PSSession.


    Expected Result: 
        
       Docker windows service is available on both virtual Machine
       Docker windows  service is up and running on both virtual Machine
       Docker windows  service is setup for automatic startup on both virtual Machine
       Web-Server windows feature is available on both virtual Machine
       Containers windows feature is available on both virtual Machine
       Docker windows  service is setup for automatic startup on both virtual Machine  
       Windows container image IIS exists on both virtual machines
       Windows container exists created using IIS image on both virtual machine
       winrm service is available on both virtual Machine
       winrm service is up and running on both virtual Machine
       winrm service is setup for automatic startup on both virtual Machine
       OnlineMedicine web application port is open on pull server.
       Pull server winrm port 5985 is open on pull server
       Pull server winrm port 5986 is open on pull server
       Pull server Remote desktop port 3389 is open on pull server
#>


param(
    [string] $deploymentName,
    [string] $resourceGroupName
    
)

Describe "Inside Virtual Machines hosting web application container" {
       BeforeAll {
        
       #  Login-AzureRmAccount -TenantId "72f988bf-86f1-41af-91ab-2d7cd011db47"  `
       #         -CertificateThumbprint "B741E61E7E9DAB41F2FE795634CBD9647E4E0302" `
       #         -ApplicationId "28a9c010-6084-4ead-b372-98f4abfba63d" `
       #         -ServicePrincipal  | out-null

       # Set-AzureRmContext -SubscriptionId "af75f52f-1ab4-4bec-bed8-4d3d9b8f7eab" | out-null
            $deployment =  (Get-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name $deploymentName)

            $webappPort = $deployment.Outputs.webappPort.Value
            $pullserverPort = $deployment.Outputs.pullserverPort.Value
            $numberofvms = $deployment.Outputs.numberofvms.Value
            $location = $deployment.Outputs.deployLocation.Value
            $vmsize = $deployment.Outputs.vmsize.Value
            $ossku = $deployment.Outputs.ossku.Value
            $databaseName = $deployment.Outputs.databaseName.Value
            $resourceGroupName = $deployment.Outputs.resourceGroupName.Value
            $skuName= $deployment.Outputs.skuName.Value
            $vmUserName = $deployment.Outputs.vmUserName.Value
            $vmPassword= $deployment.Outputs.vmPassword.Value
        }
      for ($i=1; $i -le $numberofvms; $i++) {
        $hostName= "webapponlmed" + $skuName + $i + ".westeurope.cloudapp.azure.com"
        $winrmPort = '5986'

        $username = $vmUserName
        $pass = ConvertTo-SecureString -string $vmPassword -AsPlainText -Force
        $cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $username, $pass
        $soptions = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck 
        $s = new-PSSession -ComputerName $hostName -Port $winrmPort -Credential $cred -SessionOption $soptions -UseSSL

      
    It "winrm service is available on webapp$($i)" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-Service -Name winrm).Name}
         $r | should be "winrm"
     } 

     It "winrm service is up and running on webapp$($i)" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-Service -Name winrm).Status}
         $r | should be "4"
     } 

     It "winrm service startup type is automatic on webapp$($i)" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-Service -Name winrm).StartType}
         $r | should be "2"
     }

     It "Docker service is available on webapp$($i)" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-Service -Name docker).Name}
         $r | should be "docker"
     } 

     It "docker service is up and running on webapp$($i)" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-Service -Name docker).Status}
         $r | should be "4"
     } 

     It "docker service startup type is automatic on webapp$($i)" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-Service -Name docker).StartType}
         $r | should be "2"
     }

     It "Web-server feature is installed on webapp$($i)" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-WindowsFeature -name web-server).Name}
         $r | should be "Web-Server"
     } 

     It "Containers feature is installed on webapp$($i)" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-WindowsFeature -name containers).Name}
         $r | should be "containers"
     } 

     It "Windows container image IIS exists on webapp$($i)" { 
         $r = Invoke-Command -Session $s -ScriptBlock {$images = docker images; $images.where{$_.Contains('iis')}}
         $r | should not be $null
     } 

     It "Windows container exists created using IIS image on webapp$($i)." { 
         $r = Invoke-Command -Session $s -ScriptBlock {$container = docker ps -a; $Container.where{$_.Contains('iis')}}
         $r | should not be $null
     } 
     
     It "web application port $webappPort is open on webapp$($i)." { 
         $r = Invoke-Command -Session $s -ScriptBlock {param($webappPort) Test-NetConnection -Port $webappPort -ComputerName $env:COMPUTERNAME} -ArgumentList $webappPort
         $r | should not be $null
     }    
     
     It "winrm port 5985 is open on webapp$($i)." { 
         $r = Invoke-Command -Session $s -ScriptBlock {Test-NetConnection -Port "5985" -ComputerName $env:COMPUTERNAME}
         $r | should not be $null
     }

     It "winrm port 5986 is open on webapp$($i)." { 
         $r = Invoke-Command -Session $s -ScriptBlock {Test-NetConnection -Port "5986" -ComputerName $env:COMPUTERNAME}
         $r | should not be $null
     }

     It "Remote desktop port 3389 is open on webapp$($i)." { 
         $r = Invoke-Command -Session $s -ScriptBlock {Test-NetConnection -Port "3389" -ComputerName $env:COMPUTERNAME}
         $r | should not be $null
     }  
        Remove-PSSession -Session $s
    }
     
}