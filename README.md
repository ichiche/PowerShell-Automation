# Highlight

Scheduled Job executed by Azure Automation for a particular purpose

# List of Scripts

### SharePoint Online

| Id | File Name | Folder | Description |
| - | - | - | - |
| 1 | Upload_File_To_SharePointOnline.ps1 | SharePoint Online | Upload to Document Library

# Instruction

### Prerequisites

| Item | Name | Version | Installation | 
| - | - | - | - | 
| 1 | PowerShell | 7.1.5 or above | [docs.microsoft.com](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows)  | 
| 2 | PnP.PowerShell | 1.11.0 | [PowerShell Gallery](https://www.powershellgallery.com/packages/PnP.PowerShell) |

### Installation

```PowerShell
# Run the command to verify the installed module
Get-InstalledModule

# Run as Administrator to install for Powershell 7
Install-Module -Name PnP.PowerShell -RequiredVersion 1.11.0 -Confirm:$false -Force
```

# Reference

- [SharePoint Online: Upload Files to Document Library using PowerShell](https://www.sharepointdiary.com/2016/06/upload-files-to-sharepoint-online-using-powershell.html)