Import-Module ./SumoLogic.psm1

if ($Env:SHOW_CONNECTION_INFO -eq $true) {
    Write-Host "Available commands in sumologic loaded module are:"
    get-command -Module Sumologic
}

if ($Env:SUMO_SESSION -eq $true ) {
    if (!$Env:SUMO_DEPLOYMENT -or !$Env:SUMO_ACCESS_ID -or !$Env:SUMO_ACCESS_KEY  ) { 
        Write-Error "ERROR! SUMO_SESSION is set but you must set SUMO_DEPLOYMENT,SUMO_ACCESS_KEY and SUMO_ACCESS_KEY to run `nNew-SumoSession -Deployment `$Env:SUMO_DEPLOYMENT -AccessId `$Env:SUMO_ACCESS_ID -AccessKey `$Env:SUMO_ACCESS_KEY `nYou will need to make your own New-SumoSession" ; 
       
    }
    else {
      
        try { 
            Write-Verbose "establishing connection to: $deployment"
            $session = New-SumoSession -Deployment $Env:SUMO_DEPLOYMENT -AccessId $Env:SUMO_ACCESS_ID -AccessKey $Env:SUMO_ACCESS_KEY
        }                   
        catch { 
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $hint = "An error occurred creating connection to SumoLogic API."
            Write-Error "$hint`n$ErrorMessage`n$FailedItem"; exit 4
        }

        if ($Env:SHOW_CONNECTION_INFO -eq $true) {
            Write-Host "Connected to $($session.endpoint)"
        }
    }
    
}
else {
    Write-Warning 'WARNING! SUMO_SESSION is not set you must make your own with New-SumoSession '
}


