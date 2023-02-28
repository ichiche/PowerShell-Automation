# Global Parameter
$vmRG = ""
$vmName = ""
$DiskRG = ""
$DiskName = ""
$Lun = 0

# Main
$disk = Get-AzDisk -ResourceGroupName $DiskRG -DiskName $DiskName
$vm = Get-AzVM -ResourceGroupName $vmRG -Name $vmName 
Add-AzVMDataDisk -CreateOption Attach -Lun $Lun -VM $vm -ManagedDiskId $disk.Id
Update-AzVM -ResourceGroupName $vmRG -VM $vm 