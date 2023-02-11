# Config Variable
$SiteURL = "https://[hostname].sharepoint.com/sites/[sitename]"
$FolderName = "Shared Documents/Inventory"

# Script Variable
$connectionName = "AzureRunAsConnection"

# Get connection "AzureRunAsConnection"  
$servicePrincipalConnection = Get-AutomationConnection -Name $ConnectionName
$ClientId = $servicePrincipalConnection.ApplicationId
$Thumbprint = $servicePrincipalConnection.CertificateThumbprint
$TenantId = $servicePrincipalConnection.TenantId       

#Connect to SharePoint Online using PnPOnline
Connect-PnPOnline -Url $SiteURL -ClientId $ClientId -Thumbprint $Thumbprint -Tenant $TenantId 

# Upload file
"Temp" > ".\TestUpload.txt"
Add-PnPFile -Path ".\UploadText.txt" -Folder $FolderName