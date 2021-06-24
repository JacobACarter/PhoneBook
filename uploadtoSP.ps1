param( [Parameter(mandatory=$true)] $Credential)

#Variables for processing
$URL = "https://YOURDOMAIN.sharepoint.com"
$AdminCenterURL = "https://YOURDOMAIN-admin.sharepoint.com"

#Connecting to SharePointOnline and Ensuring DenyAddAndCustomizePages is Disabled
Import-Module SharePointPnPPowerShellOnline
Connect-PnPOnline $URL -Credentials $Credential
Connect-SPOService -Url $AdminCenterURL -Credential $Credential
Set-SPOSite -Identity https://YOURDOMAIN.sharepoint.com -DenyAddAndCustomizePages 0
  
#Upload SourceFile to Folder in SharePoint
$SourceFile = "./phonebookembed.aspx"
Add-PnPFile -Folder "Shared%20Documents" -Path $SourceFile
