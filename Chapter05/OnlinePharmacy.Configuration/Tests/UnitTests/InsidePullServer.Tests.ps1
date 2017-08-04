  <#
    Purpose:
        Verify that DSC pull server virtual machine is configured to accept pull requests from DSC nodes.

    Action:
        Login into Pull server hosted on Azure virtual machine using New-PSSession.


    Expected Result: 
        
       Web-server feature is installed
       SC-Service feature is installed 
       DSC pull server web site exists
       DSC pull server web site is up and running  
       DSC pull server web site is attached to appropriate application pool
       DSC pull server web site is running on https protocol
       DSC pull server web site is running on appropriate port
       DSC pull server web site is running on given physical path
       DSC pull server application pool exists
       DSC pull server application pool is up and running
       DSC pull server winrm service is available
       DSC pull server winrm service is up and running
       DSC pull server winrm service startup type is automatic
       Pull server web application port is open on pull server.
       Pull server winrm port 5985 is open on pull server
       Pull server winrm port 5986 is open on pull server
       Pull server Remote desktop port 3389 is open on pull server
#>


param(
    [string] $deploymentName,
    [string] $resourceGroupName
    
)

Describe "Inside Virtual Machines pullserver" {
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
            $vmPassword = $deployment.Outputs.vmPassword.Value
            $pullServerPublicIPAddress = $deployment.Outputs.pullServerPublicIPAddress.Value
        }
        beforeeach {
            $hostName= "$pullServerPublicIPAddress"
            $winrmPort = '5986'

            $username = $vmUserName
            $pass = ConvertTo-SecureString -string $vmPassword -AsPlainText -Force
            $cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $username, $pass
            $soptions = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck 
            $s = new-PSSession -ComputerName $hostName -Port $winrmPort -Credential $cred -SessionOption $soptions -UseSSL
        }

     It "Web-server feature is installed" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-WindowsFeature -name web-server).Name}
         $r | should be "Web-Server"
     } 

     It "DSC-Service feature is installed" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-WindowsFeature -name DSC-Service).Name}
         $r | should be "DSC-Service"
     } 

     It "DSC pull server web site exists" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-Website -Name PSDSCPullServer).Name}
         $r | should be "PSDSCPullServer"
     } 

     It "DSC pull server web site is up and running" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-Website -Name PSDSCPullServer).state}
         $r | should be "Started"
     } 

     It "DSC pull server web site is attached to appropriate application pool" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-Website -Name PSDSCPullServer).applicationPool}
         $r | should be "DSCPullServer"
     } 

     It "DSC pull server web site is running on https protocol" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-Website -Name PSDSCPullServer).bindings.Collection.protocol}
         $r | should be "https"
     } 

     It "DSC pull server web site is running on appropriate port" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-Website -Name PSDSCPullServer).bindings.Collection.bindinginformation}
         $r | should be "*:9100:"
     } 

     It "DSC pull server web site is running on given physical path" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-Website -Name PSDSCPullServer).PhysicalPath}
         $r | should be "C:\PSDSCPullServer"
     } 

     It "DSC pull server application pool exists" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-IISAppPool -Name DscPullServer).Name}
         $r | should be "DSCPullServer"
     } 

     It "DSC pull server application pool is up and running" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-WebAppPoolState -Name DscPullServer).Value}
         $r | should be "Started"
     } 

     It "DSC pull server winrm service is available" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-Service -Name winrm).Name}
         $r | should be "winrm"
     } 

     It "DSC pull server winrm service is up and running" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-Service -Name winrm).Status}
         $r | should be "4"
     } 

     It "DSC pull server winrm service startup type is automatic" { 
         $r = Invoke-Command -Session $s -ScriptBlock {(Get-Service -Name winrm).StartType}
         $r | should be "2"
     } 

     It "Pull server web application port $pullserverPort is open on pull server." { 
         $r = Invoke-Command -Session $s -ScriptBlock { param($pullserverPort) Test-NetConnection -Port $pullserverPort -ComputerName $env:COMPUTERNAME} -ArgumentList $pullserverPort
         $r | should not be $null
     } 
     
     It "Pull server winrm port 5985 is open on pull server" { 
         $r = Invoke-Command -Session $s -ScriptBlock {Test-NetConnection -Port "5985" -ComputerName $env:COMPUTERNAME}
         $r | should not be $null
     }

     It "Pull server winrm port 5986 is open on pull server" { 
         $r = Invoke-Command -Session $s -ScriptBlock {Test-NetConnection -Port "5986" -ComputerName $env:COMPUTERNAME}
         $r | should not be $null
     }

     It "Pull server Remote desktop port 3389 is open on pull server" { 
         $r = Invoke-Command -Session $s -ScriptBlock {Test-NetConnection -Port "3389" -ComputerName $env:COMPUTERNAME}
         $r | should not be $null
     }

     aftereach{
        Remove-PSSession -Session $s
     }
  }