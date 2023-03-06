# Global Parameter
$VNetSummaryFileName = "C:\Temp\VNetSummary.csv"
$VNetConnectedDeviceFileName = "C:\Temp\VNetConnectedDevice.csv"
$ServiceEndpointFileName = "C:\Temp\VNetServiceEndpoint.csv"
$DelegationFileName = "C:\Temp\VNetDelegation.csv"

# Script Variable
$VNetSummary = @()
$VNetConnectedDevice = @()
$VNetServiceEndpoint = @()
$VNetDelegation = @()
[int]$CurrentItem = 1

# Main
$VNets = Get-AzVirtualNetwork

foreach ($VNet in $VNets) {
    # Initialize
    Write-Host ("`nProcessing " + $CurrentItem + " out of " + $VNets.Count + " Virtual Network(s)") -ForegroundColor Yellow
    [int]$ServiceEndpointCount = 0
    [int]$DelegationCount = 0
    [string]$NetworkPeering = ""
    $CurrentItem++

    # Subscription Id
    $SubscriptionId = $VNet.Id.Substring($VNet.Id.IndexOf("/subscriptions/")+15, $VNet.Id.IndexOf("/resourceGroups/")-15)

    # Count
    [int]$ConnectedDeviceCount = $VNet.Subnets.IpConfigurations.Count

    # Network Peering
    $peers = Get-AzVirtualNetworkPeering -ResourceGroupName $VNet.ResourceGroupName -VirtualNetworkName $VNet.Name
    $NetworkPeeringCount = $peers.Count

    if ($NetworkPeeringCount -ne 0) {
        foreach ($peer in $peers) {
            [string]$RemoteVNetId = $peer.RemoteVirtualNetwork.Id
            $RemoteVNetName = $RemoteVNetId.Substring($RemoteVNetId.IndexOf("/Microsoft.Network/virtualNetworks/") + 35)

            if ($NetworkPeering -eq "") {$NetworkPeering += $RemoteVNetName} else {$NetworkPeering += (", " + $RemoteVNetName)}
        }
    }

    # Subnet Config
    foreach ($subnet in $VNet.Subnets.Name) {
        $SubnetConfigs = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $VNet -Name $subnet

        # Incremental Count
        $ServiceEndpointCount += $SubnetConfigs.ServiceEndpoints.Count
        $DelegationCount += $SubnetConfigs.Delegations.Count

        # Connected Device
        if ($ConnectedDeviceCount -ne 0) {
            foreach ($item in $SubnetConfigs.IpConfigurations) {
                # Save to Array
                $obj = New-Object -TypeName PSobject
                Add-Member -InputObject $obj -MemberType NoteProperty -Name "VNetName" -Value $VNet.Name
                Add-Member -InputObject $obj -MemberType NoteProperty -Name "SubnetName" -Value $subnet
                Add-Member -InputObject $obj -MemberType NoteProperty -Name "ConnectedDeviceId" -Value $item.Id
                $VNetConnectedDevice += $obj
            }
        }

        # Service Endpoint
        if ($SubnetConfigs.ServiceEndpoints.Count -ne 0) {
            [string]$ServiceEndpointList = $SubnetConfigs.ServiceEndpoints.Service -join ", "

            # Save to Array
            $obj = New-Object -TypeName PSobject
            Add-Member -InputObject $obj -MemberType NoteProperty -Name "VNetName" -Value $VNet.Name
            Add-Member -InputObject $obj -MemberType NoteProperty -Name "SubnetName" -Value $subnet
            Add-Member -InputObject $obj -MemberType NoteProperty -Name "ServiceEndpoint" -Value $ServiceEndpointList
            $VNetServiceEndpoint += $obj
        }

        # Delegation
        if ($SubnetConfigs.Delegations.Count -ne 0) {
            # Save to Array
            $obj = New-Object -TypeName PSobject
            Add-Member -InputObject $obj -MemberType NoteProperty -Name "VNetName" -Value $VNet.Name
            Add-Member -InputObject $obj -MemberType NoteProperty -Name "SubnetName" -Value $subnet
            Add-Member -InputObject $obj -MemberType NoteProperty -Name "Delegation" -Value $SubnetConfigs.Delegations.ServiceName
            $VNetDelegation += $obj
        }
    }

    # Save to Array
    $obj = New-Object -TypeName PSobject
    Add-Member -InputObject $obj -MemberType NoteProperty -Name "SubscriptionId" -Value $SubscriptionId
    Add-Member -InputObject $obj -MemberType NoteProperty -Name "ResourceGroup" -Value $VNet.ResourceGroupName
    Add-Member -InputObject $obj -MemberType NoteProperty -Name "VNetName" -Value $VNet.Name
    Add-Member -InputObject $obj -MemberType NoteProperty -Name "Location" -Value $VNet.Location
    Add-Member -InputObject $obj -MemberType NoteProperty -Name "ConnectedDeviceCount" -Value $ConnectedDeviceCount
    Add-Member -InputObject $obj -MemberType NoteProperty -Name "ServiceEndpointCount(Subnets Total)" -Value $ServiceEndpointCount
    Add-Member -InputObject $obj -MemberType NoteProperty -Name "DelegationCount(Subnets Total)" -Value $DelegationCount
    Add-Member -InputObject $obj -MemberType NoteProperty -Name "NetworkPeeringCount" -Value $NetworkPeeringCount
    Add-Member -InputObject $obj -MemberType NoteProperty -Name "NetworkPeering" -Value $NetworkPeering
    $VNetSummary += $obj
}

# Export
$VNetSummary | Export-Csv -Path $VNetSummaryFileName -NoTypeInformation -Confirm:$false -Force
$VNetConnectedDevice | Export-Csv -Path $VNetConnectedDeviceFileName -NoTypeInformation -Confirm:$false -Force
$VNetServiceEndpoint | Export-Csv -Path $ServiceEndpointFileName -NoTypeInformation -Confirm:$false -Force
$VNetDelegation | Export-Csv -Path $DelegationFileName -NoTypeInformation -Confirm:$false -Force

# End
Write-Host ("`nCompleted`n")