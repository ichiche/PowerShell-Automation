$VNetRG = ""
$VNetName = ""
$SubnetName = ""
$ServiceEndpoint = "Microsoft.EventHub"
   
# Virtual Network
$VNet = Get-AzVirtualNetwork -ResourceGroupName $VNetRG -Name $VNetName

# Subnet Config
$SubnetConfigs = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VNet

foreach ($SubnetConfig in $SubnetConfigs) {
    Write-Host ("`nSubnet: " + $SubnetConfig.Name + " of Virtual Network: $VNetName") -ForegroundColor Yellow
    
    if ($SubnetConfig.ServiceEndpoints.Service -notcontains $ServiceEndpoint) {
        $TotalServiceEndpoint = @()

        if ($SubnetConfig.ServiceEndpoints.Service.Count -gt 0) {
            $TotalServiceEndpoint += $SubnetConfig.ServiceEndpoints.Service
        }

        $TotalServiceEndpoint += $ServiceEndpoint
        Write-Host "`nAdding $ServiceEndpoint ..."
        Set-AzVirtualNetworkSubnetConfig -Name $SubnetConfig.Name -VirtualNetwork $VNet -AddressPrefix $SubnetConfig.AddressPrefix -ServiceEndpoint $TotalServiceEndpoint | Out-Null
        $VNet | Set-AzVirtualNetwork | Out-Null
    } else {
        Write-Host "`n$ServiceEndpoint is already added"
    }
}

# End
Write-Host ("`nCompleted`n")