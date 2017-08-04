  <#
    Purpose:
        Verify that virtual machine VM02 is provisioned and configured appropriately.

    Action:
        Run Get-AzureRmVM available in given resource group with a given name.


    Expected Result: 
        
       virtual machine location is as intended
       Virtual machine is part of availability set 
       Virtual machine size is Standard_D1
       Virtual machine is attached to NIC  
       Virtual machine image is from appropriate Offer
       Virtual machine image is from appropriate publisher
       Virtual machine image is from appropriate sku
#>

param(
    [string] $deploymentName,
    [string] $resourceGroupName
    
)

Describe "web front end Virtual Machines VM02" {
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
        $nicNameforVM2= $deployment.Outputs.nicNameforVM2.Value
    }
     $vm = Get-AzureRmVM -ResourceGroupName $resourceGroupName -Name vm2
     It "virtual machine location" { 
         $vm.Location | should be $location
     } 

     It "Virtual machine is part of availability set" { 
         $vm.AvailabilitySetReference.Id.Contains('WEBAPPAVSET') | should be $true
     }

     It "Virtual machine size is $vmsize.." { 
         $vm.HardwareProfile.VmSize| should be "Standard_D1"
     }

     It "Virtual machine is attached to NIC " { 
         $vm.NetworkInterfaceIDs[0].Contains("$nicNameforVM2")| should be $true
     }

     It "Virtual machine image is from appropriate Offer" { 
         $vm.StorageProfile.ImageReference.Offer| should be 'WindowsServer'
     }

     It "Virtual machine image is from appropriate publisher" { 
         $vm.StorageProfile.ImageReference.Publisher| should be 'MicrosoftWindowsServer'
     }

     It "Virtual machine image is from appropriate sku" { 
         $vm.StorageProfile.ImageReference.Sku| should be $ossku
     }


  }