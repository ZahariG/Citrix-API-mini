## AQUIRING BEARER TOKEN 
function Get-BearerToken{
    param (
        [Parameter(Mandatory=$true)]
        [string]$clientID,
        [Parameter(Mandatory=$true)]
        [string]$clientSecret,
        [Parameter(Mandatory=$true)]
        [string]$bearerTokenUrl
    )
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

## AQUIRING SITE-ID
function Get-SiteID{
    param (
        [Parameter(Mandatory=$true)]
        [string]$customerID,
        [Parameter(Mandatory=$true)]
        [string]$bearerToken,
        [Parameter(Mandatory=$true)]
        [string]$siteIdUrl
    )

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
    
    Write-Host "Amazing! SiteID was aquired too." -ForegroundColor White -BackgroundColor DarkGreen
    return $response.Customers.Sites.Id
    
    }catch{
        Write-Host $_.Exception.Message -ForegroundColor Red -BackgroundColor Yellow
        Write-Host $_ -ForegroundColor Red -BackgroundColor Yellow
        Write-Host "Could not get SITE-ID ..." -ForegroundColor White -BackgroundColor Red
        break
    }

}

## API QUERRY 
function Get-Data{
    
    param (
        [Parameter(Mandatory=$true)]
        [string]$bearerToken,
        [Parameter(Mandatory=$true)]
        [string]$customerID,
        [Parameter(Mandatory=$true)]
        [string]$siteID,
        [Parameter(Mandatory=$true)]
        [string]$apiEndpointUrl,
        [Parameter(Mandatory=$true)]
        [string]$folderName,
        [Parameter(Mandatory=$true)]
        [string]$root,
        [Parameter(Mandatory=$true)]
        [string]$resource,
        [Parameter(Mandatory=$true)]
        [string]$filter
    )

    $timestampFile = (Get-Date).ToString("HH-mm")
    $requestUri = "${apiEndpointUrl}${resource}${filter}"
    
    # Write-Host $requestUri
    
    $headers = @{        
        "Accept" = "application/json"
        "Authorization" = "CWSAuth Bearer=$bearerToken"
        "Citrix-CustomerId" = $customerID
        "Citrix-InstanceId" = $siteID
    }
    
    try {
        $response = Invoke-RestMethod `
        -Headers $headers `
        -Method GET `
        -Uri $requestUri `
        # -ContentType "application/x-www-form-urlencoded"
        
        $jsonFileName = "${timestampFile}_${resource}.json"
        $jsonFilePath = "$root/$folderName/$jsonFileName"
        $response | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonFilePath
        
        Write-Host "...Success!! Saved it for you to read in '${root}/${folderName}/' as '${jsonFileName}' ! " -ForegroundColor DarkGreen
        return $true
        
    } catch {
        Write-Host $_.Exception.Message -ForegroundColor Yellow
        Write-Host "Could not get DATA, Abort ..." -BackgroundColor Red
        return $false
    }
}

## CREATE FOLDER
function New-Folder{
    param (
        [Parameter(Mandatory=$true)]
        [string]$root
    )
    # check if there is a folder with today's date, else create new folder with today's date
    $timestampFolder = Get-Date -Format "yyyy-MM-dd"
    $folderName = "${timestampFolder}"
    if (!(Test-Path -Path "$root/$folderName" -PathType Container)) {
        New-Item -Path "$root/$folderName/" -ItemType Directory | Out-Null
    }
    return $folderName;
}







# IF DATE WILL BE NEEDED OR RELEVANT:
##################################################################################################

# TODAYS DATE AS STARTPARAMETER IF NONE IS HANDED WITH START OF SCRIPT
# param(
#     [Parameter(Mandatory=$false)]
#     [string]$startDate = (Get-Date -Hour 0 -Minute 0 -Second 0).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ"),
    
#     [Parameter(Mandatory=$false)]
#     [string]$endDate = (Get-Date -Hour 23 -Minute 59 -Second 59).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
#     )