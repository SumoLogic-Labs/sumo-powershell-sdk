
Import-Module -Name (Get-ChildItem -Filter *psd1 -Recurse ./psm/).FullName

if ($Env:SUMO_DEPLOYMENT -imatch '.+' -and $Env:SUMO_DEPLOYMENT -inotmatch 'prod') {
   $env:SUMOLOGIC_API_ENDPOINT="https://api.$(($Env:SUMO_DEPLOYMENT).ToLower()).sumologic.com/api/v1/"
   write-host "SUMOLOGIC_API_ENDPOINT is: $($env:SUMOLOGIC_API_ENDPOINT)"
} else {
   Write-Verbose 'SUMO_DEPLOYMENT is default'
}

if ((Get-Module -Name SumoLogic-Core).Name -ne "Sumologic-Core") {
   write-error "ERROR module import probably failed!"
} else {
   write-host "Welcome to Sumologic-Core: https://github.com/SumoLogic/sumo-powershell-sdk! `n`nTo see available commands:`nget-command -Module Sumologic-Core`n"

   if ($Env:SUMO_SESSION -eq $true) {
      if (!$Env:SUMO_ACCESS_ID -or !$Env:SUMO_ACCESS_KEY  ) { 
           write-host "ERROR SUMO_SESSION is set but you must set SUMO_DEPLOYMENT,SUMO_ACCESS_KEY and SUMO_ACCESS_KEY to run `nNew-SumoSession -Deployment `$Env:SUMO_DEPLOYMENT -AccessId `$Env:SUMO_ACCESS_ID -AccessKey `$Env:SUMO_ACCESS_KEY `nYou will need to make your own New-SumoSession" ; 
          
        } else {
           write-host 'SUMO_SESSION is true... making New-SumoSession'
           $accessKeyAsSecureString = ConvertTo-SecureString $Env:SUMO_ACCESS_KEY -AsPlainText -Force
           New-SumoSession -AccessId $Env:SUMO_ACCESS_ID -AccessKey $accessKeyAsSecureString
        }
       
   } else {
       write-host 'SUMO_SESSION is false, you must make your own with New-SumoSession '
   }
}

