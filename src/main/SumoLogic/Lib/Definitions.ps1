enum SumoSearchResultType
{
  Message
  Record
}

class SumoAPISession
{
  [string]$Endpoint
  [Microsoft.PowerShell.Commands.WebRequestSession]$WebSession
  
  SumoAPISession([string]$endpoint, [Microsoft.PowerShell.Commands.WebRequestSession]$webSession) {
    $this.Endpoint = $Endpoint
    $this.WebSession = $webSession
  }
}
