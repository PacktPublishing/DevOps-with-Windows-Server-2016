<#
    Purpose:
        Verify the web application is operational on second virtual machine.

    Action:
        Run Invoke-WebRequest on multiple pages of web application.

    Expected Result: 
        
        invoking the request for index page of web application and comparing the returned status, text and description
        invoking the request for Drug's create page of web application and comparing the returned status, text and description
        invoking the request for Drugs page of web application and comparing the returned status, text and description
        invoking the request for Drug Inventory page of web application and comparing the returned status, text and description
        invoking the request for sales page of web application and comparing the returned status, text and description
#>

param(
    [string] $deploymentName,
    [string] $resourceGroupName
    
)

Describe "Web application requests to first virtual machine and container" {
    BeforeAll {
        
     #   Login-AzureRmAccount -TenantId "72f988bf-86f1-41af-91ab-2d7cd011db47"  `
     #           -CertificateThumbprint "B741E61E7E9DAB41F2FE795634CBD9647E4E0302" `
     #           -ApplicationId "28a9c010-6084-4ead-b372-98f4abfba63d" `
     #           -ServicePrincipal 
     #
     #   Set-AzureRmContext -SubscriptionId "af75f52f-1ab4-4bec-bed8-4d3d9b8f7eab" 
        
        $deployment =  (Get-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name $deploymentName)
        $vm02IP = $deployment.Outputs.vM02PublicIPAddress.value
        $webappPort= $deployment.Outputs.webappPort.value
        
    }
    
    
        It "invoking the request for index page of web application and comparing the returned status, text and description.." {

        $parturl = $($($vm02IP) + ":" + $($webappPort))
            $indexPage = Invoke-WebRequest -UseBasicParsing -Uri "http://$parturl/newapp/index"
            $indexPage.Content.Contains("Welcome to Medical Point of sale application") | should be $true
            $indexPage.StatusCode  | should be 200
            $indexPage.StatusDescription | should be "OK"
        }
        

        It "invoking the request for Drug's create page of web application and comparing the returned status, text and description.." {

        $parturl = $($($vm02IP) + ":" + $($webappPort))
            $createDrug = Invoke-WebRequest -UseBasicParsing -Uri "http://$parturl/newapp/Drugs/Create" -Method Get
            $createDrug.Content.Contains("Create new Drug Master - DevOps with Windows Server 2016 sample application") | should be $true
            $createDrug.StatusCode  | should be 200
            $createDrug.StatusDescription | should be "OK"
        }
        

        It "invoking the request for Drugs page of web application and comparing the returned status, text and description.." {

        $parturl = $($($vm02IP) + ":" + $($webappPort))
            $drugs = Invoke-WebRequest -UseBasicParsing -Uri "http://$parturl/newapp/Drugs"
            $drugs.Content.Contains("List of Drugs - DevOps with Windows Server 2016 sample application") | should be $true
            $drugs.StatusCode | should be 200
            $drugs.StatusDescription | should be "OK"
        }

                
        It "invoking the request for Drug Inventory page of web application and comparing the returned status, text and description.." {

        $parturl = $($($vm02IP) + ":" + $($webappPort))
            $drugInventory = Invoke-WebRequest -UseBasicParsing -Uri "http://$parturl/newapp/DrugInventories"
            $drugInventory.Content.Contains("List of inventory - DevOps with Windows Server 2016 sample application") | should be $true
            $drugInventory.StatusCode  | should be 200
            $drugInventory.StatusDescription | should be "OK"
        }
  
        

        It "invoking the request for sales page of web application and comparing the returned status, text and description..." {

        $parturl = $($($vm02IP) + ":" + $($webappPort))
            $sales = Invoke-WebRequest -UseBasicParsing -Uri "http://$parturl/newapp/Sales"
            $sales.Content.Contains("All sales.. - DevOps with Windows Server 2016 sample application") | should be $true
            $sales.StatusCode  | should be 200
            $sales.StatusDescription | should be "OK"
        }

}


