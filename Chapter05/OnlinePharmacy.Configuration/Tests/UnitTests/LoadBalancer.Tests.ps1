  <#
    Purpose:
        Verify that Azure Load balancer resource is provisioned and configured appropriately.

    Action:
        Run Get-AzureRmLoadBalancer available in given resource group with a given name.
        Run Get-AzureRmLoadBalancerRuleConfig available in given resource group with a given name.
        Run Get-AzureRmLoadBalancerProbeConfig available in given resource group with a given name.
        Run Get-AzureRmLoadBalancerInboundNatRuleConfig available in given resource group with a given name.
        Run Get-AzureRmLoadBalancerBackendAddressPoolConfig available in given resource group with a given name.
        Run Get-AzureRmLoadBalancerFrontendIpConfig available in given resource group with a given name.
        
    Expected Result: 
        
        Load balancer rule for frontend web application port is configured
        Load balancer rule for backend web application port is configured
        Load balancer rules is associated with backend address pool
        Load balancer rule is associated with frontend IP configuration
        Load balancer rule is associated with Tcp protocol
        Load balancer rule uses the Default load distibution algorithm
        Load balancer rule is provisioned successfully
        Load balancer rule is associated with probe object
        Load balancer probe is configured to be executed 100 times
        Load balancer probe is configured to be executed in 100 seconds interval
        Load balancer probe is associated with load balancer rules
        Load balancer probe is configured for web application port
        Load balancer probe is configured on http protocol
        Load balancer probe is configured successfully
        Load balancer probe is configured to probe /newapp/index path
        Load balancer Nat config with frontend port 3389 for first virtual machine
        Load balancer Nat config with backend port 3389 for first virtual machine
        Load balancer Nat config with backend port 3389 for first virtual machine
        Load balancer Nat config with frontend port 13389 for second virtual machine
        Load balancer Nat config is on Tcp protocol for both virtual machines
        Load balancer Nat config is configured successfully for both virtual machine
        Load balancer backend address pool is connected to nic on first virtual machine
        Load balancer backend address pool is connected to nic on second virtual machine
        Load balancer frontend ip configuration is associated with load balancer public ip
        Load balancer frontend ip configuration is associated with NAT to first virtual machine
        Load balancer frontend ip configuration is associated with NAT to second virtual machine
        Load balancer frontend ip configuration is associated with load balancing rules
        Load balancer frontend ip configuration private internal ip is assigned dynamically
        Load balancer backend address pool is provisioned successfully
        Load balancer backend address pool is connected to Nic of first virtual machine
        Load balancer backend address pool is connected to Nic of second virtual machine
#>
 
 param(
    [string] $deploymentName,
    [string] $resourceGroupName
    
)

 Describe "Load balancer" {
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
        $lbfrontendIPConfiguration= $deployment.Outputs.lbfrontendIPConfiguration.Value
        $lbbackendAddressPool= $deployment.Outputs.lbbackendAddressPool.Value
        $lbloadBalancingRules= $deployment.Outputs.lbloadBalancingRules.Value
        $lbinboundNatRule1= $deployment.Outputs.lbinboundNatRule1.Value
        $lbinboundNatRule2= $deployment.Outputs.lbinboundNatRule2.Value
        $nicNameforVM1= $deployment.Outputs.nicNameforVM1.Value
        $nicNameforVM2= $deployment.Outputs.nicNameforVM2.Value
    }
     $lb = Get-AzureRmLoadBalancer -Name containerLB -ResourceGroupName $resourceGroupName

     It "Load balancer rule for frontend port $webappPort is configured.." { 
         (Get-AzureRmLoadBalancerRuleConfig -LoadBalancer $lb).FrontendPort | should be $webappPort
     } 


     It "Load balancer rule for backend port $webappPort is configured.." { 
         (Get-AzureRmLoadBalancerRuleConfig -LoadBalancer $lb).BackendPort | should be $webappPort
     } 

          
     It "Load balancer rules is associated with backend address pool.." { 
         (Get-AzureRmLoadBalancerRuleConfig -LoadBalancer $lb).BackendAddressPool.Id.Contains($lbbackendAddressPool) | should be $true
     }
    
     It "Load balancer rule is associated with frontend IP configuration.." { 
         (Get-AzureRmLoadBalancerRuleConfig -LoadBalancer $lb).FrontendIPConfiguration.id.Contains($lbfrontendIPConfiguration) | should be $true
     }

     It "Load balancer rule is associated with Tcp protocol" { 
         (Get-AzureRmLoadBalancerRuleConfig -LoadBalancer $lb).Protocol | should be "Tcp"
     }

     It "Load balancer rule uses the Default load distibution algorithm.." { 
         (Get-AzureRmLoadBalancerRuleConfig -LoadBalancer $lb).LoadDistribution | should be "Default"
     }

     It "Load balancer rule is provisioned successfully.." { 
         (Get-AzureRmLoadBalancerRuleConfig -LoadBalancer $lb).ProvisioningState | should be "Succeeded"
     }

     It "Load balancer rule is associated with probe object.." { 
         (Get-AzureRmLoadBalancerRuleConfig -LoadBalancer $lb).Probe.Id.Contains('WebLBPROBE') | should be $true
     }

     It "Load balancer probe is configured to be executed 100 times.." { 
        (Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $lb).NumberOfProbes | should be 100
     }

     It "Load balancer probe is configured to be executed in 100 seconds interval.." { 
        (Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $lb).IntervalInSeconds | should be 100
     }

     It "Load balancer probe is associated with load balancer rules.." { 
        (Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $lb).LoadBalancingRules[0].Id.Contains($lbloadBalancingRules) | should be $true
     }
     It "Load balancer probe is configured on port $webappPort .." { 
         (Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $lb).Port | should be $webappPort
     }

     It "Load balancer probe is configured on http protocol.." { 
         (Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $lb).Protocol | should be "http"
     }

     It "Load balancer probe is configured successfully.." { 
         (Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $lb).ProvisioningState  | should be "Succeeded"
     }

     It "Load balancer probe is configured to probe /newapp/index path .." { 
        (Get-AzureRmLoadBalancerProbeConfig -LoadBalancer $lb).RequestPath  | should be "/newapp/Index"
     }

     It "Load balancer Nat config with frontend port 3389 for first virtual machine.." { 
        (Get-AzureRmLoadBalancerInboundNatRuleConfig -LoadBalancer $lb)[0].FrontendPort | should be "3389"
     }

     It "Load balancer Nat config with backend port 3389 for first virtual machine.." { 
        (Get-AzureRmLoadBalancerInboundNatRuleConfig -LoadBalancer $lb)[0].BackendPort  | should be "3389"
     }

     It "Load balancer Nat config with backend port 3389 for first virtual machine.." { 
         (Get-AzureRmLoadBalancerInboundNatRuleConfig -LoadBalancer $lb)[1].BackendPort | should be "3389"
     }

     It "Load balancer Nat config with frontend port 13389 for second virtual machine.." { 
         (Get-AzureRmLoadBalancerInboundNatRuleConfig -LoadBalancer $lb)[1].FrontendPort | should be "13389"
     }

     It "Load balancer Nat config is on Tcp protocol for both virtual machines.." { 
         (Get-AzureRmLoadBalancerInboundNatRuleConfig -LoadBalancer $lb).Protocol | should be @('Tcp','Tcp')
     }

     It "Load balancer Nat config is configured successfully for both virtual machine.." { 
        (Get-AzureRmLoadBalancerInboundNatRuleConfig -LoadBalancer $lb).ProvisioningState  | should be @('Succeeded','Succeeded')
     }



     It "Load balancer frontend ip configuration is associated with load balancer public ip .." { 
         (Get-AzureRmLoadBalancerFrontendIpConfig -LoadBalancer $lb).PublicIpAddress.Id.Contains('lbPublicIP') | should be $true
     }

     It "Load balancer frontend ip configuration is associated with NAT to first virtual machine .." { 
         (Get-AzureRmLoadBalancerFrontendIpConfig -LoadBalancer $lb).InboundNatRules[0].Id.Contains($lbinboundNatRule1) | should be $true
     }

     It "Load balancer frontend ip configuration is associated with NAT to second virtual machine.." { 
         (Get-AzureRmLoadBalancerFrontendIpConfig -LoadBalancer $lb).InboundNatRules[1].Id.Contains($lbinboundNatRule2) | should be $true
     }

     It "Load balancer frontend ip configuration is associated with load balancing rules resource.." { 
        (Get-AzureRmLoadBalancerFrontendIpConfig -LoadBalancer $lb).LoadBalancingRules[0].Id.Contains($lbloadBalancingRules)  | should be $true
     }

     It "Load balancer frontend ip configuration private internal ip is assigned dynamically.." { 
        (Get-AzureRmLoadBalancerFrontendIpConfig -LoadBalancer $lb).PrivateIpAllocationMethod  | should be "Dynamic"
     }

     It "Load balancer backend address pool is provisioned successfully.." { 
        (Get-AzureRmLoadBalancerBackendAddressPoolConfig -LoadBalancer $lb).ProvisioningState  | should be "Succeeded"
     }


 }