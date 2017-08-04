<#
    Purpose:
        Verify the web application is operational using Azure Load balancer.

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

Describe "Web application requests to virtual machine and container using load balancer" {
    BeforeAll {
        
     #   Login-AzureRmAccount -TenantId "72f988bf-86f1-41af-91ab-2d7cd011db47"  `
     #           -CertificateThumbprint "B741E61E7E9DAB41F2FE795634CBD9647E4E0302" `
     #           -ApplicationId "28a9c010-6084-4ead-b372-98f4abfba63d" `
     #           -ServicePrincipal  
     #
     #   Set-AzureRmContext -SubscriptionId "af75f52f-1ab4-4bec-bed8-4d3d9b8f7eab" 
        $deployment =  (Get-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name $deploymentName)
        $lbip = $deployment.Outputs.loadBalancerPublicIPAddress.value
        $webappPort= $deployment.Outputs.webappPort.value


    }

       

        it "invoking the request for index page of web application and comparing the returned status, text and description.." {
    
           $parturl = $($($lbip) + ":" + $($webappPort))

            $fullurl = "http://$parturl/newapp/index"
            $indexPage =  Invoke-WebRequest -UseBasicParsing -Uri (New-Object System.Uri -ArgumentList "$fullurl")
            $indexPage.Content.Contains("Welcome to Medical Point of sale application") | should be $true
            $indexPage.StatusCode  | should be 200
            $indexPage.StatusDescription | should be "OK"
        }
        
        
        it "invoking the request for index page of web application and comparing the returned status, text and description.." {
    
            $parturl = $($($lbip) + ":" + $($webappPort))

            $fullurl = "http://$parturl/newapp/index"
            $indexPage = Invoke-WebRequest -UseBasicParsing -Uri "$fullurl"
            $indexPage.Content.Contains("Welcome to Medical Point of sale application") | should be $true
            $indexPage.StatusCode  | should be 200
            $indexPage.StatusDescription | should be "OK"
        }
        
       


        it "invoking the request for Drug's create page of web application and comparing the returned status, text and description.." {

            $parturl = $($($lbip) + ":" + $($webappPort))
            $fullurl = "http://$parturl/newapp/Drugs/Create"
            $createDrug = Invoke-WebRequest -UseBasicParsing -Uri "$fullurl" -Method Get
            $createDrug.Content.Contains("Create new Drug Master - DevOps with Windows Server 2016 sample application") | should be $true
            $createDrug.StatusCode  | should be 200
            $createDrug.StatusDescription | should be "OK"
        }
        

        it "invoking the request for Drugs page of web application and comparing the returned status, text and description.." {
    
            $parturl = $($($lbip) + ":" + $($webappPort))
            $fullurl = "http://$parturl/newapp/Drugs"
            $drugs = Invoke-WebRequest -UseBasicParsing -Uri "$fullurl"
            $drugs.Content.Contains("List of Drugs - DevOps with Windows Server 2016 sample application") | should be $true
            $drugs.StatusCode  | should be 200
            $drugs.StatusDescription | should be "OK"
        }


        it "invoking the request for Drug Inventory page of web application and comparing the returned status, text and description.." {

        
            $parturl = $($($lbip) + ":" + $($webappPort))
            $fullurl = "http://$parturl/newapp/DrugInventories"
            $drugInventory = Invoke-WebRequest -UseBasicParsing -Uri "$fullurl"
            $drugInventory.Content.Contains("List of inventory - DevOps with Windows Server 2016 sample application") | should be $true
            $drugInventory.StatusCode  | should be 200
            $drugInventory.StatusDescription | should be "OK"
        }
        


        it "invoking the request for sales page of web application and comparing the returned status, text and description.." {

            $parturl = $($($lbip) + ":" + $($webappPort))
            $fullurl = "http://$parturl/newapp/Sales"
            $sales = Invoke-WebRequest -UseBasicParsing -Uri "$fullurl"
            $sales.Content.Contains("All sales.. - DevOps with Windows Server 2016 sample application") | should be $true
            $sales.StatusCode  | should be 200
            $sales.StatusDescription  | should be "OK"
        }

}


