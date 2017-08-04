
param(
    [string] $sqlFilePath,
    [string] $scriptsFilePath,
    [string] $containerName,
    [string] $resourceGroupName,
    [string] $storageAccountName
)

#$(username) = "28a9c010-6084-4ead-b372-98f4abfba63d"
#$(passsword) = "eu/QjdHZPAUty99teNSObo6CBSxTMyI10zGQ0fZ5fIQ="

#$pass = ConvertTo-SecureString -String $passsword -AsPlainText -Force

#$cred = New-Object System.Management.Automation.PSCredential $username, $pass


#Login-AzureRmAccount -Credential $cred -TenantId $(TenantID) -SubscriptionId $(SubscriptionID) -ServicePrincipal

#Set-AzureRmContext -SubscriptionId "af75f52f-1ab4-4bec-bed8-4d3d9b8f7eab" 

$storage = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName `
                                     -Name "$storageAccountName"

$storageKey = Get-AzureRmStorageAccountKey `
                 -ResourceGroupName $resourceGroupName  -Name "$storageAccountName"

Publish-AzureRMVMDscConfiguration -ConfigurationPath "$scriptsFilePath\DSCScripts\InstallContainer.ps1" `
                            -ContainerName "$containerName" -ResourceGroupName $resourceGroupName `
                            -StorageAccountName $storageAccountName -Force -Verbose
                            

Set-AzureStorageBlobContent -File "$scriptsFilePath\PSScripts\pullserver.ps1" `
                            -Container "$containerName" `
                            -Blob "pullserver.ps1" `
                            -BlobType Block `
                            -Force -Context $storage.Context

Set-AzureStorageBlobContent -File "$scriptsFilePath\DSCScripts\IISInstall.ps1" `
                            -Container "$containerName" `
                            -Blob "IISInstall.ps1" `
                            -BlobType Block `
                            -Force -Context $storage.Context

Set-AzureStorageBlobContent -File "$scriptsFilePath\PSScripts\ContainerConfig.ps1" `
                            -Container "$containerName" `
                            -Blob "ContainerConfig.ps1" `
                            -BlobType Block `
                            -Force -Context $storage.Context

Set-AzureStorageBlobContent -File "$sqlFilePath" `
                            -Container "$containerName" `
                            -Blob "OnlinePharmacy.sql" `
                            -BlobType Block `
                            -Force -Context $storage.Context

Set-AzureStorageBlobContent -File "$scriptsFilePath\Templates\dockerfile" `
                            -Container "$containerName" `
                            -Blob "dockerfile" `
                            -BlobType Block `
                            -Force -Context $storage.Context

Set-AzureStorageBlobContent -File "$scriptsFilePath\PSScripts\ChangeConnectionString.ps1" `
                            -Container "$containerName" `
                            -Blob "ChangeConnectionString.ps1" `
                            -BlobType Block `
                            -Force -Context $storage.Context

Set-AzureStorageBlobContent -File "$scriptsFilePath\PSScripts\lcm.ps1" `
                            -Container "$containerName" `
                            -Blob "lcm.ps1" `
                            -BlobType Block `
                            -Force -Context $storage.Context

