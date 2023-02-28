# Global Parameter
$VmssRG = ""
$VmssName = ""
$SelectedAZone = 1 # Assume to Start or Stop specific Availability Zone

# Retrieve the VM Instance in VM Scale Set with Zone and Power State
$vmss = Get-AzVmssVM -ResourceGroupName $VmssRG -VMScaleSetName $VmssName -InstanceView
$vmss | ft Name, InstanceID, Location, Zones, @{n="PowerState";e={$($_.InstanceView.Statuses.DisplayStatus | ? {$_ -notlike "Provisioning*"})}} -AutoSize

# Stop VM in Scale Set that provisioned in specific Availability Zone
$InstanceIds = @()
$list = $vmss | ? {$_.Zones -eq $SelectedAZone}
foreach ($item in $list) { $InstanceIds += "$($item.InstanceID)"} 
Stop-AzVmss -InstanceId $InstanceIds -ResourceGroupName $VmssRG -VMScaleSetName $VmssName -Force -Confirm:$false 

# Start VM in Scale Set that is not in running state
$vmss = Get-AzVmssVM -ResourceGroupName $VmssRG -VMScaleSetName $VmssName -InstanceView
$list = $vmss | ? {$_.InstanceView.Statuses.DisplayStatus -notcontains "VM Running"}
$InstanceIds = @()
foreach ($item in $list) { $InstanceIds += "$($item.InstanceID)"} 
Start-AzVmss -InstanceId $InstanceIds -ResourceGroupName $VmssRG -VMScaleSetName $VmssName -Confirm:$false