 <#
    Purpose:
        Verify that Azure virtual network resource is provisioned and configured appropriately.

    Action:
        Run Get-AzureRmVirtualNetwork available in given resource group with a given name.

    Expected Result: 
        The count of subnets in virtual network is two
        The name of the two subnets are subnetad and frontend.
        The address prefix of virtual network matches.
        The address prefix of both virtual network subnets matches.
        virtual network is provisioned successfully.
        Its two subnets are provisioned successfully.
        The location is set appropriately
        The frontend subnet has applied Network security group represented by Om-NSG
       
#>
 param(
    [string] $deploymentName,
    [string] $resourceGroupName
    
)

 Describe "Virtual network" {
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
    }

     $network = (Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Name $($skuName + "-network"))
     It "virtual network address space is {10.0.0.0/16}.." { 
         $network.AddressSpace.AddressPrefixes | should be "10.0.0.0/16"
     } 

     It "virtual network location is $location .." { 
         $network.Location | should be "$location"
     } 

     It "virtual network count of subnets is 2 .." { 
         $network.Subnets.Count | should be 2
     }
    
     It "virtual network subnet name is subnetad .." { 
         $network.Subnets[0].Name | should be "subnetad"
     }

     It "virtual network subnet name is frontend .." { 
         $network.Subnets[1].Name | should be "frontend"
     }

     It "virtual network subnetad subnet address prefix is 10.0.0.0/24.." { 
         $network.Subnets[0].AddressPrefix | should be "10.0.0.0/24"
     }

     It "virtual network subnetad subnet address prefix is 10.1.0.0/24.." { 
         $network.Subnets[1].AddressPrefix | should be "10.0.1.0/24"
     }

     It "virtual network subnetad subnet has om-NSG applied to it.." { 
         ($network.Subnets[1].NetworkSecurityGroup).Id.Contains( $($skuName + "-NSG")) | should be $true
     }

     It "virtual network was provisioned successfully" { 
        $network.ProvisioningState  | should be "Succeeded"
     }

     It "virtual network subnetad was provisioned successfully.." { 
        $network.Subnets[0].ProvisioningState  | should be "Succeeded"
     }

     It "virtual network frontend subnet was provisioned successfully.." { 
        $network.Subnets[1].ProvisioningState  | should be "Succeeded"
     }
 }