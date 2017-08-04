 <#
    Purpose:
        Verify that Azure network security group resource is provisioned and configured appropriately.

    Action:
        Run Get-AzureRmNetworkSecurityGroup available in given resource group with a given name.

    Expected Result: 
        
        NSG resource is provisioned successfully.
        NSG for port 443 is allowed for incoming requests
        NSG for port 80 is allowed for incoming requests
        NSG is applied to frontend subnet of virtual network
        NSG for port 1433 is allowed for incoming requests
        NSG for port 5985 is allowed for incoming requests
        NSG for port 5986 is allowed for incoming requests
        NSG for port 3389 is allowed for incoming requests
        NSG for port 2375 is allowed for incoming requests
        NSG for port 2376 is allowed for incoming requests
        NSG for port web application port is allowed for incoming requests
        NSG for port pull server port is allowed for incoming requests
#>

param(
    [string] $deploymentName,
    [string] $resourceGroupName
    
)

Describe "Network Security group" {
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
        $NSGName= $deployment.Outputs.networkSecurityGroupName.Value

        
    }

    It "NSG resource was provisioned successfully.." {
        $rule = ((Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $resourceGroupName))
        $rule.ProvisioningState | should be "Succeeded"
    }

    It "NSG is applied to frontend subnet of virtual network" {
        $rule = ((Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $resourceGroupName).Subnets[0].Id)
        $rule.Contains('frontend') | should be $true
    }

    It "NSG for port 80 is allowed for incoming requests" {
        $rule = ((Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $resourceGroupName).SecurityRules.Where{$_.name -eq "rule80"}).DestinationPortRange
        $rule | should be 80
    }

    It "NSG for port 443 is allowed for incoming requests" {
        $rule = ((Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $resourceGroupName).SecurityRules.Where{$_.name -eq "rule443"}).DestinationPortRange
        $rule | should  be 443
    }

    It "NSG for port 1433 is allowed for incoming requests" {
        $rule = ((Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $resourceGroupName).SecurityRules.Where{$_.name -eq "rule1433"}).DestinationPortRange
        $rule | should  be 1433
    }

    It "NSG for port 5985 is allowed for incoming requests" {
        $rule = ((Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $resourceGroupName).SecurityRules.Where{$_.name -eq "rulePSUnsecured"}).DestinationPortRange
        $rule | should  be 5985
    }

    It "NSG for port 5986 is allowed for incoming requests" {
        $rule = ((Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $resourceGroupName).SecurityRules.Where{$_.name -eq "rulePSsecured"}).DestinationPortRange
        $rule | should  be 5986
    }

    It "NSG for port 3389 is allowed for incoming requests" {
        $rule = ((Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $resourceGroupName).SecurityRules.Where{$_.name -eq "RDP"}).DestinationPortRange
        $rule | should  be 3389
    }

    It "NSG for port 2375 is allowed for incoming requests" {
        $rule = ((Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $resourceGroupName).SecurityRules.Where{$_.name -eq "docker"}).DestinationPortRange
        $rule | should  be 2375
    }

    It "NSG for port 2376 is allowed for incoming requests" {
        $rule = ((Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $resourceGroupName).SecurityRules.Where{$_.name -eq "dockers"}).DestinationPortRange
        $rule | should be 2376
    }

    It "NSG for port $webappPort is allowed for incoming requests" {
        $rule = ((Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $resourceGroupName).SecurityRules.Where{$_.name -eq "webserver"}).DestinationPortRange
        $rule | should be $webappPort
    }

    It "NSG for port $pullserverPort is allowed for incoming requests" {
        $rule = ((Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $resourceGroupName).SecurityRules.Where{$_.name -eq "pullserver"}).DestinationPortRange
        $rule | should be $pullserverPort
    }
  }