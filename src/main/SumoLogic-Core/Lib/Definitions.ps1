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
    public string Endpoint;
    public object WebSession;
}
"@