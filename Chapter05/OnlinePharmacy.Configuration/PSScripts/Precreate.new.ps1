$location = "West Europe"
$resourceGroupName = "dimdum" #win2016devops

Login-AzureRmAccount

Set-AzureRmContext -SubscriptionId "af75f52f-1ab4-4bec-bed8-4d3d9b8f7eab"


New-AzureRmResourceGroup -Name $resourceGroupName -Location $location

New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName `
                          -Name "dimdumnns" -Location $location `
                          -Type Standard_LRS -Verbose # win2016devops1

$storage = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName `
                                     -Name "dimdumnns" # win2016devops1

$storageKey = Get-AzureRmStorageAccountKey `
                 -ResourceGroupName $resourceGroupName `
                 -Name "dimdumnns" # win2016devops1

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



$principalName = "paagalapan"
$psadCredential = New-Object Microsoft.Azure.Commands.Resources.Models.ActiveDirectory.PSADPasswordCredential
$startDate = Get-Date
$psadCredential.StartDate = $startDate
$psadCredential.EndDate = $startDate.AddYears(1)
$psadCredential.KeyId = [guid]::NewGuid()
$psadCredential.Password = "citynext!1234"

$homePage = "https://www." + $principalName + ".org"
$identifierUri = $homePage + "/example"


if((Get-AzureRmADServicePrincipal `
        -ServicePrincipalName $identifierUri) `
        -eq $null)
{
   

    $app = New-AzureRmADApplication -DisplayName $principalName -HomePage $homePage -IdentifierUris $identifierUri -PasswordCredentials $psadCredential

    $sp = New-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId.Guid
    
    Start-Sleep -Seconds 30

    New-AzureRmRoleAssignment -RoleDefinitionName Owner `
                           -ServicePrincipalName $app.ApplicationId.Guid
}
else
{
    $sp = Get-AzureRmADServicePrincipal `
            -ServicePrincipalName $identifierUri    

    $app = Get-AzureRmADApplication -ApplicationId $sp[0].ApplicationId.Guid
}


$username = ConvertTo-SecureString -String "citynextadmin" -Force –AsPlainText
$password = ConvertTo-SecureString -String "citynext!1234" -Force –AsPlainText

Test-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName `
                                    -TemplateFile `
                                    "C:\Users\rimodi\Source\Win2016DevOps\OnlinePharmacy.Configuration\Templates\GeneralServices.json" `
                                    -keyVaultName "dimdumvault" `
                                    -tenantId "72f988bf-86f1-41af-91ab-2d7cd011db47" `
                                    -sqlUserName $username `
                                    -sqlPasswordName $password `
                                    -VSTSUserName $username `
                                    -VSTSPasswordName $password `
                                    -VMUserName $username `
                                    -VMPasswordName $password `
                                    -deployLocation $location `
                                    -workspaceName "dimdumOMS" `
                                    -objectId $sp.Id  `
                                    -storageKey $storageKey[0].Value `
                                    -sasToken $sas `
                                    -storageName "dimdumnns" `
                                    -sqlServerName "dimdumsqlsd" `
                                    -Verbose

#C:\GitRepo\docker\CM\Test, OnlineMedicineVault, OnlineMedicineOMS,win2016devops1 , devopswin2016
New-AzureRmResourceGroupDeployment -Name Deploy1 `
                                   -ResourceGroupName $resourceGroupName `
                                    -TemplateFile `
                                    "C:\Users\rimodi\Source\Win2016DevOps\OnlinePharmacy.Configuration\Templates\GeneralServices.json" `
                                    -keyVaultName "dimdumvault" `
                                    -tenantId "72f988bf-86f1-41af-91ab-2d7cd011db47" `
                                    -sqlUserName $username `
                                    -sqlPasswordName $password `
                                    -VSTSUserName $username `
                                    -VSTSPasswordName $password `
                                    -VMUserName $username `
                                    -VMPasswordName $password `
                                    -deployLocation $location `
                                    -workspaceName "dimdumOMS" `
                                    -objectId $sp.Id  `
                                    -storageKey $storageKey[0].Value `
                                    -sasToken $sas `
                                    -storageName "dimdumnns" `
                                    -sqlServerName "dimdumsqlsd" `
                                    -mode Incremental -Verbose 


#Login-AzureRmAccount -TenantId "72f988bf-86f1-41af-91ab-2d7cd011db47"  -CertificateThumbprint $cert.Thumbprint -ApplicationId $app.ApplicationId -ServicePrincipal -Verbose 
#Login-AzureRmAccount -TenantId "<<xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx>>"  -CertificateThumbprint $cert.Thumbprint -ApplicationId $app.ApplicationId -ServicePrincipal -Verbose 
$user = $sp[0].ApplicationId.Guid
$pass = ConvertTo-SecureString -String "citynext!1234" -Force –AsPlainText
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $user, $pass
Login-AzureRmAccount -Credential $cred -ServicePrincipal -TenantId 72f988bf-86f1-41af-91ab-2d7cd011db47 -SubscriptionId "af75f52f-1ab4-4bec-bed8-4d3d9b8f7eab"
