

# Log into Azure using credentials
Login-AzureRmAccount 

# Select a subscription if there are multiple subscription available with the given username
Set-AzureRmContext -SubscriptionName "<<Azure subscription name>>"

# Name of storage account for hosting virtual machine
# must be unique on internet
# Change ths storage account name here
$storageAccountName = "mycontainerstore"

# Location for Resource group 
$locationRG = "westus"

#  Resource group name for provisioning Windows Server 2016 server
$rgName = "ContainerRG"

#  Name of virtual machine containing windows server 2016 server
# must be unique in resource group
$vmName = "mycontainervm"

# Creating a new Resource group 
New-AzureRmResourceGroup -Name $rgName -Location $locationRG

# Create a new storage account
# provide your own stroage account and it should be unique on internet
$storageAccount = New-AzureRmStorageAccount -ResourceGroupName $rgName -Name $storageAccountName -Type "Standard_GRS" -Location $locationRG

# Create a new virtual network subnet configuration
$singleSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name singleSubnet -AddressPrefix 10.0.0.0/24

# Create a new virtual network
$vnet = New-AzureRmVirtualNetwork -Name TestNet -ResourceGroupName $rgName -Location $locationRG -AddressPrefix 10.0.0.0/16 -Subnet $singleSubnet

# Create a new public IP address
$pip = New-AzureRmPublicIpAddress -Name TestPIP -ResourceGroupName $rgName -Location $locationRG -AllocationMethod Dynamic -DomainNameLabel $vmName

# Create a new Network interface
$nic = New-AzureRmNetworkInterface -Name TestNIC -ResourceGroupName $rgName -Location $locationRG -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

# Get username and password from user for virtual machine
$cred = Get-Credential -Message "Type the name and password of the local administrator account."

# Create virtual machine configutation providing name and its size
$vm = New-AzureRmVMConfig -VMName $vmName -VMSize "Standard_A4"

# Create virtual machine configuration with type of operating system, name, administrator credentials and other switches
$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $vmName  -Credential $cred -ProvisionVMAgent -EnableAutoUpdate

# Create a virtual machine configuration with image details related to windows server 2016 server
$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2016-Datacenter-with-Containers"  -Version "latest"

# attach the network interface to the virtual machine
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

# provide location and name of OS disk to be provisioned for virtual machine
$osDiskUri = $storageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/WindowsVMosDisk.vhd"
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $vmName -VhdUri $osDiskUri -CreateOption fromImage

# Create a new virtual machine
New-AzureRmVM -ResourceGroupName $rgName -Location $locationRG -VM $vm