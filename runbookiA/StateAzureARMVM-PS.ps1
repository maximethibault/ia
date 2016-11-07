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

    $VMs = Get-AzureRmVM -ResourceGroupName "iAPOCAAutomationRS"
    foreach($VM in $VMs)
    {
        $VMDetail = Get-AzureRmVM -ResourceGroupName "iAPOCAAutomationRS" -Name $VM.Name -Status
        foreach ($VMStatus in $VMDetail.Statuses)
        { 
            if($VMStatus.Code.CompareTo("PowerState/deallocated") -eq 0)
            {
                 $VMStatusDetail = $VMStatus.DisplayStatus
            }
        }
        write-output $VM.Name $VMStatusDetail
    }