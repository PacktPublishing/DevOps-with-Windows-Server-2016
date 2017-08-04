 <#
    Purpose:
        Verify the count of virtual machines in resource group .

    Action:
        Run Get-AzureRmVM available in given resource group with a given name.

    Expected Result: 
        
        count of virtual machine in resource group
#>

param(
    [string] $deploymentName,
    [string] $resourceGroupName
    
)

 Describe "Check the existance of Web front end and pull server virtual machine" {
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
    $vms = Get-AzureRmVM -ResourceGroupName $resourceGroupName
     It "count of virtual machine in resource group" { 
        $vms.Count | should be ($numberofvms +1)
     } 

  }