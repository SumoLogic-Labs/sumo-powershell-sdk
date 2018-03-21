try { 
    $collectors = Get-Collector -limit 10000 -Offset 1 -verbose
    Write-Verbose "got $($collectors.Count) collectors "
}                   
catch { 
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    $hint = "An error occurred with get-collectors."
    write-host "$hint`n$ErrorMessage`n$FailedItem "; 
    exit 1
}

$collectors.name | sort