Add-Type -TypeDefinition @"
public enum SumoDeployment
{
  US1,
  US2,
  AU,
  EU,
  DE  
}
"@

Add-Type -TypeDefinition @"
public enum SumoSearchResultType
{
  Message,
  Record
}
"@

$Script:defaultHeaders = @{
  'content-type' = 'application/json'
  'accept' = 'application/json'
}

$Script:apiPoints = @{
  [SumoDeployment]::US1 = 'https://api.sumologic.com/api/v1/'
  [SumoDeployment]::US2 = 'https://api.us2.sumologic.com/api/v1/'
  [SumoDeployment]::AU = 'https://api.au.sumologic.com/api/v1/'
  [SumoDeployment]::EU = 'https://api.eu.sumologic.com/api/v1/'
  [SumoDeployment]::DE = 'https://api.de.sumologic.com/api/v1/'
}

$Script:sumoSesion = $null

# TLS 1.1+ is not enabled by default in Windows PowerShell, but it is
# required to communicate with the Sumo Logic API service.
# Enable it if needed
if ([System.Net.ServicePointManager]::SecurityProtocol -ne [System.Net.SecurityProtocolType]::SystemDefault) {
  Write-Warning "Enabling TLS 1.2 usage via [System.Net.ServicePointManager]::SecurityProtocol"
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
}
