
# Log into Azure
Login-AzureRmAccount 

# Select a subscription if there are multiple subscription available with the given username
Set-AzureRmContext -SubscriptionName "<<Azure subscription name>>"

# Declaring location for Resource group 
$locationRG = "westeurope"

# Declaring Resource group name for provisioning Azure Keyvault
$rgName = "NaNoServerRG"

# Creating a new Resource group 
New-AzureRmResourceGroup -Name $rgName -Location $locationRG 

# Creating a new self signed certificate on local machine with wilcard common name at localmachine personal store
New-SelfSignedCertificate -DnsName *.westeurope.cloudapp.azure.com -CertStoreLocation Cert:\LocalMachine\My 

# Creating a new Azure key vault names NanoSecrets with two important switches that enables ARM to use this key vault
# during template deployment and other deployments
New-AzureRmKeyVault -VaultName NanoSecrets `
                    -ResourceGroupName $rgName `
                    -Location $locationRG `
                    -EnabledForTemplateDeployment `
                    -EnabledForDeployment `
                    -Sku standard  

# getting the content of certificate and encoding it to base64
$certFile = "C:\nanocert.pfx"
$certContent = get-content $certFile -Encoding Byte
$encodedCertContent = [System.Convert]::ToBase64String($certContent) 


#Preparing the json object containing certificate data, password and type of certificate
$jsonObject = @"
{
"data": "$encodedCertContent",
"dataType" :"pfx",
"password": "<<password for certificate>>"
}
“@ 

#Encoding the JSON object into base64
$jsonObjectBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonObject)
$jsonEncoded = [System.Convert]::ToBase64String($jsonObjectBytes) 

#Setting up a nee secret in Key vault with the base64 encoded JSON object
$secret = ConvertTo-SecureString -String $jsonEncoded -AsPlainText –Force
Set-AzureKeyVaultSecret -VaultName “NanoSecrets” -Name “NanoCert” -SecretValue $secret 

