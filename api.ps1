# TODAYS DATE AS STARTPARAMETER IF NONE IS HANDED WITH START OF SCRIPT
param(
    [Parameter(Mandatory=$false)]
    [string]$startDate = (Get-Date -Hour 0 -Minute 0 -Second 0).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ"),

    [Parameter(Mandatory=$false)]
    [string]$endDate = (Get-Date -Hour 23 -Minute 59 -Second 59).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
)

# IMPORT CREDENTIALS FROM secureclient.csv
$path ="./secureclient.csv"
$credentials = Import-Csv -Path $path

foreach ($row in $credentials) {
    #$name = $row."Name"  ---> Not needed atm
    $clientID = $row."Client-ID"
    $clientSecret = $row."Secret"
    $customerID = $row."Customer-ID"
}

# URLS 
$bearerTokenUrl = "https://api-eu.cloud.com/cctrustoauth2/$customerID/tokens/clients"   # Get-BearerToken
$siteIdUrl = "https://api.cloud.com/cvad/manage/me";                                    # Get-SiteID
$apiEndpointUrl = "https://api-eu.cloud.com/monitorodata/";                             # Execute-Odata

# BEARER TOKEN #############################################################
function Get-BearerToken {
    
    $headers = @{
            "Accept" = "application/json"
            "Content-Type" = "application/x-www-form-urlencoded"
        }

    $body = @{        
        "grant_type" = "client_credentials"
        "client_id" = $clientID
        "client_secret" = $clientSecret
    }

    try {
        $response = Invoke-RestMethod `
        -Headers $headers `
        -Method POST `
        -Uri $bearerTokenUrl `
        -Body $body `
        -ContentType "application/x-www-form-urlencoded"

        Write-Host "Amazing! Bearer-Token was aquired and expires in $($response.expires_in) seconds!" -ForegroundColor White -BackgroundColor DarkGreen
        return $response.access_token

    }catch {
        Write-Host $_.Exception.Message -ForegroundColor Red 
        Write-Host $_ -ForegroundColor Yellow
        Write-Host "Could not get bearer token. Abort..." -ForegroundColor Red
        break
    }
}
$bearerToken = Get-BearerToken 

# SITE ID ##################################################################
function Get-SiteID{
    $headers = @{
        "Accept" = "application/json"
        "Authorization" = "CWSAuth Bearer=$bearerToken"
        "Citrix-CustomerId" = $customerID
    }
    
    try{
    
    $response = Invoke-RestMethod `
        -Uri $siteIdUrl `
        -Method GET `
        -Headers $headers
        
        Write-Host "Amazing! SiteID was aquired." -ForegroundColor White -BackgroundColor DarkGreen
        return $response.Customers.Sites.Id

    }catch{
        Write-Host $_.Exception.Message -ForegroundColor Red -BackgroundColor Yellow
        Write-Host $_ -ForegroundColor Red -BackgroundColor Yellow
        Write-Host "Could not get SITE-ID ..." -ForegroundColor White -BackgroundColor Red
    }
    
}
$siteID = Get-SiteID

# API QUERRY ###############################################################
function Execute-Odata($resource){
    
    $headers = @{        
        "Accept" = "application/json"
        "charset" = "utf-8"
        "Authorization" = "CWSAuth Bearer=$bearerToken"
        "Citrix-CustomerId" = $customerID
        "Citrix-InstanceId" = $siteID
        "Content-Type" = "application/json"
    }

    $uri = "${apiEndpointUrl}${resource}"
    Write-Host $uri

    try {
        $response = Invoke-RestMethod `
            -Headers $headers `
            -Method GET `
            -Uri $uri `
            -ContentType "application/x-www-form-urlencoded"
            
        return $response.value
        
    } catch {
        Write-Host $_.Exception.Message -ForegroundColor Yellow
        Write-Host "Could not get DATA, Abort ..." -BackgroundColor Red
        
    }
}
# Write-Host "###### Get all NON active machines ##########"
# Execute-Odata -resource 'Machines?$filter=LifecycleState eq 1 ' | Format-Table

Write-Host "###### Get all machines with SELECTED FILEDS ##########"
Execute-Odata -resource 'Machines?$select=Name,LifecycleState,IsInMaintenanceMode,IsAssigned,CurrentPowerState,ModifiedDate ' | Format-Table



