 <#
    Purpose:
        Verify that Azure SQL resource is provisioned and configured appropriately.

    Action:
        Run Get-AzureRmSqlServer available in given resource group with a given name.
        Run Get-AzureRmSqlDatabase available in given resource group with a given name.
        Run Get-AzureRmSqlServerFirewallRule available in given resource group with a given name.


    Expected Result: 
        
        Get SQL server with given name
        Get SQL server location 
        Get SQL Server database with given name
        Get SQL Server database with firewall rules related to first virtual machine
        Get SQL Server database with firewall rules related to second virtual machine
        Get SQL Server database with firewall rules related to pullserver virtual machine
        Get SQL Server database with firewall rules related to all azure services

#>

param(
    [string] $deploymentName,
    [string] $resourceGroupName
    
)

Describe "SQL SERVER" { 

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
	  $sqlServer= $deployment.Outputs.sqlServer.Value
    }
        $server = Get-AzureRmSqlServer -ResourceGroupName $resourceGroupName
        $database = Get-AzureRmSqlDatabase -ServerName $sqlServer -ResourceGroupName $resourceGroupName -DatabaseName $databaseName
        $firewall = Get-AzureRmSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $sqlServer
        
     It "Get SQL server with given name" { 
         $server.ServerName | should be $("devopswin2016-" + $skuName)
     } 



     It "Get SQL Server database with given name" { 
         $database.Databasename | should be $databaseName
     }
     
     It "Get SQL Server database with Webapp1 firewall rules" { 
         $webapp1Ipaddress = $firewall.Where{$_.FirewallRuleName -eq 'webapp1'} | select startipaddress -ExpandProperty startipaddress
         $firewall.Where{$_.FirewallRuleName -eq 'webapp1'} | select FirewallRuleName -ExpandProperty FirewallRuleName | should be "webapp1"
         
     }

     It "Get SQL Server database with Webapp2 firewall rules" { 
         $firewall.Where{$_.FirewallRuleName -eq 'webapp2'} | select FirewallRuleName -ExpandProperty FirewallRuleName | should be "webapp2"
         $webapp2Ipaddress = $firewall.Where{$_.FirewallRuleName -eq 'webapp2'} | select startipaddress -ExpandProperty startipaddress
     }

     It "Get SQL Server database with pull server firewall rules" { 
         $firewall.Where{$_.FirewallRuleName -eq 'pullserver'} | select FirewallRuleName -ExpandProperty FirewallRuleName | should be "pullserver"
         $pullserverIpaddress = $firewall.Where{$_.FirewallRuleName -eq 'pullserver'} | select startipaddress -ExpandProperty startipaddress
     }

     It "Get SQL Server database with AllowAllWindowsAzureIps firewall rules" { 
         $firewall.Where{$_.FirewallRuleName -eq 'AllowAllWindowsAzureIps'} | select FirewallRuleName -ExpandProperty FirewallRuleName | should be "AllowAllWindowsAzureIps"
         $AllowAllWindowsAzureIps = $firewall.Where{$_.FirewallRuleName -eq 'AllowAllWindowsAzureIps'} | select startipaddress -ExpandProperty startipaddress
     }


 }