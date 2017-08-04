<#
    Purpose:
        Verify that Azure availabilitySet resource is provisioned and configured appropriately.

    Action:
        Run Get-AzureRmAvailabilitySet available in given resource group.

    Expected Result: 
        The name of availabiltyset matches.
        AvailabilitySet is provisioned successfully.
        The location is appropriatly set
        It contains two virtual machines
        It has reference to vmvm1 virtual machine
        It has reference to vmvm2 virtual machine         
#>

param(
    [string] $deploymentName,
    [string] $resourceGroupName
    
)

Describe "Availability Sets" { 
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

        
        $avset = Get-AzureRmAvailabilitySet -ResourceGroupName  $resourceGroupName
     
     It "Availability set exists with given name" { 
         $avset.Name | should be "webappAVSet"
         
     } 

     It "Availability set state is good.." { 
         $avset.StatusCode | should be "OK"
         
     } 

     It "Availability set exists within given Azure location" { 
         $avset.Location | should be $location
         
     } 

     It "Availability set has references to two VMs" { 
         $ref = $avset.VirtualMachinesReferences
         $ref.Count | should be $numberofvms
         
     } 

     It "Availability set has references to first VMs" { 
         $ref = $avset.VirtualMachinesReferences
         $ref[0].Id.Contains("VM1") | should be $true
         
         
     } 

     It "Availability set has references to second VMs" { 
         $ref = $avset.VirtualMachinesReferences
         $ref[1].Id.Contains("VM2") | should be $true
         
         
     }
 }