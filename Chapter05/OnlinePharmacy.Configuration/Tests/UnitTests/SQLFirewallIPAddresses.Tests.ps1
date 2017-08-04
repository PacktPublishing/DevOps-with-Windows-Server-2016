 <#
    Purpose:
        Verify that Azure SQL firewalls have valid Ip address belonging to two virtual machine hosting web application.

    Action:
        Run Get-AzureRmSqlServer available in given resource group with a given name.
        Run Get-AzureRmSqlDatabase available in given resource group with a given name.
        Run Get-AzureRmSqlServerFirewallRule available in given resource group with a given name.
        Run Get-AzureRmPublicIpAddress available in given resource group with a given name.

    Expected Result: 
        
       Public Ip address of VM vmvm1 matches to the Azure SQL firewall
       Public Ip address of VM vmvm2 matches to the Azure SQL firewall 
        
#>


param(
    [string] $deploymentName,
    [string] $resourceGroupName
    
)

Describe "SQL Firewall IP Addresses"{
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
     It "Public Ip address of VM vm1 matches to the Azure SQL firewall " { 
        $ipaddress = (Get-AzureRmPublicIpAddress -Name $("pip1" + $skuName + "-publicIP") -ResourceGroupName $resourceGroupName).IpAddress
        $webapp1Ipaddress = $firewall.Where{$_.FirewallRuleName -eq 'webapp1'} | select startipaddress -ExpandProperty startipaddress
         $webapp1Ipaddress | should be $ipaddress
     } 
     
     It "Public Ip address of VM vm2 matches to the Azure SQL firewall " { 
        $ipaddress = (Get-AzureRmPublicIpAddress -Name $("pip2" + $skuName + "-publicIP") -ResourceGroupName $resourceGroupName).IpAddress
        $webapp2Ipaddress = $firewall.Where{$_.FirewallRuleName -eq 'webapp2'} | select startipaddress -ExpandProperty startipaddress
         $webapp2Ipaddress | should be $ipaddress
     } 
 }

