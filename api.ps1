# Import-Module "./modules/common.config.psm1";
Import-Module "./modules/common.functions.psm1";

# IMPORTING CREDENTIALS FROM CSV-FILE
$path ="./secureclient.csv"
$credentials = Import-Csv -Path $path
foreach ($row in $credentials) {
    #$name = $row."Name"  ---> Not needed atm
    $clientID = $row."Client-ID"
    $clientSecret = $row."Secret"
    $customerID = $row."Customer-ID"
}

# URLS #################################################################### 
$bearerTokenUrl = "https://api-eu.cloud.com/cctrustoauth2/$customerID/tokens/clients"   # Get-BearerToken
$siteIdUrl = "https://api.cloud.com/cvad/manage/me"                                     # Get-SiteID
$apiEndpointUrl = "https://api.cloud.com/cvad/manage/"                                  # Execute-Odata

$root = "./logs" # WHERE DO TOU WANT TO SAVE THE JSON RESULTS

# BEARER TOKEN #############################################################
$bearerToken = Get-BearerToken $clientID $clientSecret $bearerTokenUrl
# Write-Host $bearerToken
# SITE ID ##################################################################
$siteID = Get-SiteID $customerID $bearerToken $siteIdUrl
# Write-Host $siteID 
# Create New Folder for JSON to be saved to ################################
$folderName = ""
$folderName = New-Folder $root
# Create Filter to get only the Fields we need #############################
$filter = "?fields=Name,PowerState,RegistrationState,FaultState,LastErrorTime,LastErrorReason,MachineCatalog"

Write-Host "###### Looking for data ...  ##########" -ForegroundColor Yellow
$data = Get-Data $bearerToken $customerID $siteID $apiEndpointUrl $folderName $root 'Machines' $filter 








