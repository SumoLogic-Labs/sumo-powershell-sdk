enum SumoSearchResultType
{
  Message
  Record
}

class SumoAPISession
{
  [string]$Endpoint
  [Microsoft.PowerShell.Commands.WebRequestSession]$WebSession
}


[SumoAPISession]$Script:defaultSesion = $null
