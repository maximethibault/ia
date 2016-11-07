##################################################################################
#  Le script crée une VM: VMIIS99 dans le ressource group de la POC
#
##################################################################################

#Connect to azure
$connectionName = "AzureRunAsConnection"
$servicePrincipalConnection=Get-AutomationConnection -Name $connectionName
Add-AzureRmAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint

 # Import AzureRM modules for the given version manifest in the AzureRM module
Import-Module AzureRM.Storage
Import-Module AzureRM.Automation
Import-Module AzureRM.Compute
Import-Module AzureRM.Profile
Import-Module AzureRM.Resources
Import-Module AzureRM.SQL
Import-Module AzureRM.Network

# Import Azure Service Management module
Import-Module Azure

# Create the variable to hold the resource group name
$RGPName= ”iAPOCAAutomationRS”

# Create the variable to hold the Azure region
$location= ”eastus”

# Create the Resource Group
# New-AzureRmResourceGroup -Name $RGPName -Location $location

# Create the variable to hold the storage account name
$STAName= ”iapocaautomationrs99”

# Create the variable to hold the type of storage model to use
$STAType= “Standard_LRS”

# Create the storage account and store the reference to a variable
$STA = New-AzureRmStorageAccount -Name $STAName -ResourceGroupName $RGPName –Type $STAType -Location $location

# Create the variable to hold the name of the NIC
$NICName=”VMIIS99NIC”

# Create the variable to hold the static IP address that will be assigned to the NIC
$staticIP= “10.0.0.99”

# Create the variable to hold the virtual network name
$vNetName= “iAPOCAAutomationRS-vnet”

# Create the variable to hold the subnet name
$SubnetName= “default”

# Get the reference to the vNet that has the subnet being targeted
$vNet = Get-AzureRMVirtualNetwork -ResourceGroupName $RGPName -Name $vNetName

# Get a reference to the Subnet to attach the NIC
$Subnet = $vNet.Subnets | Where-Object {$_.Name -eq $SubnetName}

# Create a public IP address object that can be assigned to the NIC
$pubIP = New-AzureRmPublicIpAddress -Name $NICName -ResourceGroupName $RGPName -Location $location -AllocationMethod Dynamic

#Create the NIC attached to a subnet, with a public facing IP, and a static private IP
$NIC = New-AzureRmNetworkInterface -Name $NICName -ResourceGroupName $RGPName -Location $location -SubnetId $Subnet.Id -PublicIpAddressId $pubIP.Id -PrivateIpAddress $staticIP

# Create the variable that will hold the name of the virtual machine
$vmName=”VMIIS99”

# Create the variable that will store the size of the VM
$vmSize=”Standard_A2”

# Create the virtual machine configuration object and save a reference to it
$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize

# Create the variable to hold the publisher name
$pubName = ”MicrosoftWindowsServer”

# Create the variable to hold the offer name
$offerName = ”WindowsServer”

# Create the variable to hold the SKU name
$skuName = ”2012-R2-Datacenter”

# Create the variable to hold the OS disk name
$diskName = ”VM99SDisk”

# Prompt for credentials that will be used for the local admin password for the VM
$password = 'PASSWORD' | ConvertTo-SecureString -asPlainText -Force
$username = 'USERNAME'
$cred = New-Object System.Management.Automation.PSCredential($username,$password)


# Assign the operating system to the VM configuration
$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate

# Assign the gallery image to the VM configuration
$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName $pubName -Offer $offerName -Skus $skuName -Version 'latest'

# Assign the NIC to the VM configuration
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $NIC.Id

# Create the URI to store the OS disk VHD
$OSDiskUri = $STA.PrimaryEndpoints.Blob.ToString()
$OSDiskUri = $OSDiskUri  + 'vhds/' + $diskName  + '.vhd'

# Assign the OS Disk name and location to the VM configuration
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $diskName -VhdUri $OSDiskUri -CreateOption fromImage

New-AzureRmVM -ResourceGroupName $RGPName -Location $location -VM $vm
