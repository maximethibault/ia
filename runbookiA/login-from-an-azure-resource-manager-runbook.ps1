##################################################################################
#  Le script valide le groupe local admin
#
##################################################################################

#Connect to azure
$connectionName = "AzureRunAsConnection"
$servicePrincipalConnection=Get-AutomationConnection -Name $connectionName
Add-AzureRmAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint

$Admin = "Azure"
#get users in local administrator
$obj_group = [ADSI]"WinNT://$($env:COMPUTERNAME)/Administrators,group"
$Administrators = @($obj_group.psbase.Invoke("Members")) | foreach{([ADSI]$_).InvokeGet("Name")}
If ($Admin -eq $Administrators)
{ 
    Write-Output "Administrateur local" $Administrators
} 
else
{ 
    Write-Output "Non Conforme"
}