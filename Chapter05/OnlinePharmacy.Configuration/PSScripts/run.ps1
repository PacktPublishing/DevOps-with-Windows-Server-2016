Login-AzureRmAccount -TenantId "72f988bf-86f1-41af-91ab-2d7cd011db47"  `
                -CertificateThumbprint "B741E61E7E9DAB41F2FE795634CBD9647E4E0302" `
                -ApplicationId "28a9c010-6084-4ead-b372-98f4abfba63d" `
                -ServicePrincipal -Verbose 

Set-AzureRmContext -SubscriptionId "af75f52f-1ab4-4bec-bed8-4d3d9b8f7eab" 


Publish-AzureRMVMDscConfiguration -ConfigurationPath "C:\GitRepo\docker\CM\Test\InstallContainer.ps1" `
                            -ContainerName "armt" -ResourceGroupName $resourceGroupName `
                            -StorageAccountName $storage.StorageAccountName -Force -Verbose
                            

Set-AzureStorageBlobContent -File "C:\GitRepo\docker\CM\Test\pullserver.ps1" `
                            -Container "armt" `
                            -Blob "pullserver.ps1" `
                            -BlobType Block `
                            -Force -Context $storage.Context

Set-AzureStorageBlobContent -File "C:\GitRepo\docker\CM\Test\IISInstall.ps1" `
                            -Container "armt" `
                            -Blob "IISInstall.ps1" `
                            -BlobType Block `
                            -Force -Context $storage.Context

Set-AzureStorageBlobContent -File "C:\GitRepo\docker\CM\Test\ContainerConfig.ps1" `
                            -Container "armt" `
                            -Blob "ContainerConfig.ps1" `
                            -BlobType Block `
                            -Force -Context $storage.Context

Set-AzureStorageBlobContent -File "C:\GitRepo\docker\CM\Test\OnlinePharmacy.sql" `
                            -Container "armt" `
                            -Blob "OnlinePharmacy.sql" `
                            -BlobType Block `
                            -Force -Context $storage.Context

Set-AzureStorageBlobContent -File "C:\GitRepo\docker\CM\Test\dockerfile" `
                            -Container "armt" `
                            -Blob "dockerfile" `
                            -BlobType Block `
                            -Force -Context $storage.Context

Set-AzureStorageBlobContent -File "C:\GitRepo\docker\CM\Test\ChangeConnectionString.ps1" `
                            -Container "armt" `
                            -Blob "ChangeConnectionString.ps1" `
                            -BlobType Block `
                            -Force -Context $storage.Context

Set-AzureStorageBlobContent -File "C:\GitRepo\docker\CM\Test\lcm.ps1" `
                            -Container "armt" `
                            -Blob "lcm.ps1" `
                            -BlobType Block `
                            -Force -Context $storage.Context

Set-AzureStorageBlobContent -File "C:\GitRepo\docker\CM\Test\Deployment.zip" `
                            -Container "armt" `
                            -Blob "Deployment.zip" `
                            -BlobType Block `
                            -Force -Context $storage.Context


New-AzureRmResourceGroup -Name OnlineMedicine `
                         -Location "West Europe"

Test-AzureRmResourceGroupDeployment -ResourceGroupName OnlineMedicine `
              -TemplateFile "C:\GitRepo\docker\CM\Test\OnlineMedicine.json" `
              -TemplateParameterFile `
              "C:\GitRepo\docker\CM\Test\OnlineMedicine.parameters.json" `
              -workspaceName OnlineMedicineOMS -Mode Incremental `
              -verbose

$output = New-AzureRmResourceGroupDeployment -Name test2 `
            -ResourceGroupName OnlineMedicine `
            -TemplateFile "C:\GitRepo\docker\CM\Test\OnlineMedicine.json" `
            -TemplateParameterFile `
            "C:\GitRepo\docker\CM\Test\OnlineMedicine.parameters.json" `
            -workspaceName OnlineMedicineOMS -Mode Incremental `
            -Verbose
