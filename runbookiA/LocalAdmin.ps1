$Admin = "Azure"
#get users in local administrator
$obj_group = [ADSI]"WinNT://$($env:COMPUTERNAME)/Administrators,group"
$Administrators = @($obj_group.psbase.Invoke("Members")) | foreach{([ADSI]$_).InvokeGet("Name")}
If ($Admin -eq $Administrators)
{ 
    Write-Output "Administrateur local" $Administrators
    $Administrators | Out-File C:\filename.txt
} 
else
{ 
    Write-Output "Non Conforme"
}