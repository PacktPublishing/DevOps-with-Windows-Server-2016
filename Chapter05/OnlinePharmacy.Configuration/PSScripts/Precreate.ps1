$location = "West Europe"
$resourceGroupName = "win2016devops"

Login-AzureRmAccount

Set-AzureRmContext -SubscriptionId "af75f52f-1ab4-4bec-bed8-4d3d9b8f7eab"


New-AzureRmResourceGroup -Name $resourceGroupName -Location $location

New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName `
                          -Name "win2016devops1" -Location $location `
                          -Type Standard_LRS -Verbose

$storage = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName `
                                     -Name "win2016devops1"

$storageKey = Get-AzureRmStorageAccountKey `
                 -ResourceGroupName $resourceGroupName `
                 -Name "win2016devops1"

New-AzureStorageContainer -Name "armt" `
                          -Permission Container `
                          -Context $storage.Context `
                          -Verbose

Set-AzureStorageContainerAcl -Permission Container `
                             -Name "armt" `
                             -Context $storage.Context `
                             -Verbose

$sas = New-AzureStorageContainerSASToken -Name armt `
                                         -Permission rwdl `
                                         -ExpiryTime (Get-Date).AddYears(2) `
                                         -Context $storage.Context


Import-Module -Name C:\certificates\New-SelfSignedCertificateEx.ps1

if((Get-ChildItem -Path cert:\CurrentUser\My\* `
                  -DnsName Win2016DevOps) -eq $null)
{
    New-SelfSignedCertificateEx -Subject "CN=Win2016DevOps" `
                                -KeySpec "Exchange" `
                                -FriendlyName "Win2016DevOps" `
                                -StoreLocation CurrentUser 
                                
    
}

$cert = Get-ChildItem -Path cert:\CurrentUser\My\* -DnsName "Win2016DevOps"

$keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())

if((Get-AzureRmADServicePrincipal `
        -ServicePrincipalName "https://www.Win2016DevOps.org/example") `
        -eq $null)
{
    $app = New-AzureRmADApplication -DisplayName "Win2016DevOps" `
                                    -HomePage "https://www.Win2016DevOps.org" `
                                    -IdentifierUris `
                                    "https://www.Win2016DevOps.org/example" `
                                    -CertValue $keyValue `
                                    -EndDate $cert.NotAfter `
                                    -StartDate $cert.NotBefore

    $sp = New-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId
    
    Start-Sleep -Seconds 30

    New-AzureRmRoleAssignment -RoleDefinitionName Owner `
                           -ServicePrincipalName $app.ApplicationId.Guid
}
else
{
    $sp = Get-AzureRmADServicePrincipal `
            -ServicePrincipalName "https://www.Win2016DevOps.org/example"    

    $app = Get-AzureRmADApplication -ApplicationId $sp[0].ApplicationId
}


$username = ConvertTo-SecureString -String "citynextadmin" -Force –AsPlainText
$password = ConvertTo-SecureString -String "citynext!1234" -Force –AsPlainText

Test-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName `
                                    -TemplateFile `
                                    "C:\GitRepo\docker\CM\Test\GeneralServices.json" `
                                    -keyVaultName "OnlineMedicineVault" `
                                    -tenantId "72f988bf-86f1-41af-91ab-2d7cd011db47" `
                                    -sqlUserName $username `
                                    -sqlPasswordName $password `
                                    -VSTSUserName $username `
                                    -VSTSPasswordName $password `
                                    -VMUserName $username `
                                    -VMPasswordName $password `
                                    -deployLocation $location `
                                    -workspaceName "OnlineMedicineOMS" `
                                    -objectId $sp.Id  `
                                    -storageKey $storageKey[0].Value `
                                    -sasToken $sas `
                                    -storageName "win2016devops1" `
                                    -sqlServerName "devopswin2016" `
                                    -Verbose

New-AzureRmResourceGroupDeployment -Name Deploy1 `
                                   -ResourceGroupName $resourceGroupName `
                                   -TemplateFile `
                                   "C:\GitRepo\docker\CM\Test\GeneralServices.json" `
                                   -keyVaultName "OnlineMedicineVault" `
                                   -tenantId "72f988bf-86f1-41af-91ab-2d7cd011db47" `
                                   -sqlUserName $username `
                                   -sqlPasswordName $password `
                                   -VSTSUserName $username `
                                   -VSTSPasswordName $password `
                                   -VMUserName $username `
                                   -VMPasswordName $password `
                                   -deployLocation $location `
                                   -workspaceName "OnlineMedicineOMS"  `
                                   -objectId $sp.Id `
                                   -storageKey $storageKey[0].Value `
                                   -sasToken $sas `
                                   -storageName "win2016devops1" `
                                   -sqlServerName "devopswin2016" `
                                   -mode Incremental -Verbose 


Login-AzureRmAccount -TenantId "72f988bf-86f1-41af-91ab-2d7cd011db47"  -CertificateThumbprint $cert.Thumbprint -ApplicationId $app.ApplicationId -ServicePrincipal -Verbose 
Login-AzureRmAccount -TenantId "<<xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx>>"  -CertificateThumbprint $cert.Thumbprint -ApplicationId $app.ApplicationId -ServicePrincipal -Verbose 
