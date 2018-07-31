Add-Type -TypeDefinition @"
public enum SumoSearchResultType
{
    Message,
    Record
}
"@

Add-Type -TypeDefinition @"
public class SumoAPISession
{
    public SumoAPISession(string Endpoint, object WebSession) {
        this.Endpoint = Endpoint;
        this.WebSession = WebSession;
    }
    public string Endpoint;
    public object WebSession;
}
"@