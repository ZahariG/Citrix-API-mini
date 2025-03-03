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

######################################### SET FILTER AND DEFINE THE TABLE WE WANT TO GET DATA FROM ############################

# Select which table we want to get the data from
$resource = "Machines"  # This needs to be converted to an array and put into an while-loop, if we want to expand the tables

# Create Filter limit the fields we need so we dont have too much useless data 
$filter = "?fields=Name,PowerState,RegistrationState,FaultState,LastErrorTime,LastErrorReason,MachineCatalog"

Write-Host "###### Looking for data ...  ##########" -ForegroundColor Yellow
Get-Data $bearerToken $customerID $siteID $apiEndpointUrl $folderName $root $resource $filter 









