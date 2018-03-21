if (!$Env:SUMO_DEPLOYMENT ) { write-host 'ERROR you must set $Env:SUMO_DEPLOYMENT for this container to function properly... exiting'; exit 1  }
if (!$Env:SUMO_ACCESS_ID  ) { write-host 'ERROR you must set $Env:SUMO_ACCESS_ID for this container to function properly... exiting'; exit 1  }
if (!$Env:SUMO_ACCESS_KEY  ) { write-host 'ERROR you must set $Env:SUMO_ACCESS_KEY for this container to function properly... exiting' ; exit 1 }

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

write-host "Connected to $($session.endpoint)"

try { 
    $collectors = Get-Collector -limit 10 -Offset 1 -verbose
    Write-host "got $($collectors.Count) collectors "
}                   
catch { 
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    $hint = "An error occurred with get-collectors."
    write-host "$hint`n$ErrorMessage`n$FailedItem "; 
    exit 1
}

$collectors | format-table -Property id, name, ephemeral, sourceSyncMode, collectorType, collectorVersion, osVersion