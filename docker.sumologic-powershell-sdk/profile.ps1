Import-Module ./SumoLogic.psm1

if ($env:SHOW_CONNECTION_INFO -eq $true) {
    write-host "Available commands in sumologic loaded module are:"
    get-command -Module Sumologic
}

if ($Env:SUMO_SESSION) {
    if (!$Env:SUMO_DEPLOYMENT -or !$Env:SUMO_ACCESS_ID -or !$Env:SUMO_ACCESS_KEY  ) { 
        write-host "ERROR! SUMO_SESSION is set but you must set SUMO_DEPLOYMENT,SUMO_ACCESS_KEY and SUMO_ACCESS_KEY to run `nNew-SumoSession -Deployment `$Env:SUMO_DEPLOYMENT -AccessId `$Env:SUMO_ACCESS_ID -AccessKey `$Env:SUMO_ACCESS_KEY `nYou will need to make your own New-SumoSession" ; 
       
    }
    else {
      
        try { 
            write-verbose "establishing connection to: $deployment"
            $session = New-SumoSession -Deployment $Env:SUMO_DEPLOYMENT -AccessId $Env:SUMO_ACCESS_ID -AccessKey $Env:SUMO_ACCESS_KEY
        }                   
        catch { 
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            $hint = "An error occurred creating connection to SumoLogic API."
            write-host "$hint`n$ErrorMessage`n$FailedItem"; exit 4
        }

        if ($env:SHOW_CONNECTION_INFO -eq $true) {
            write-host "Connected to $($session.endpoint)"
        }
    }
    
}
else {
    write-host 'WARNING! SUMO_SESSION is not set you must make your own with New-SumoSession '
}


