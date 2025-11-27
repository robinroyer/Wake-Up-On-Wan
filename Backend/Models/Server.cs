namespace WakeMeUp.Models;

public class Server
{
    public string PrettyName { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
    public string Name { get; set; } = string.Empty;
    public string MacAddress { get; set; } = string.Empty;
    public string GatewayIp { get; set; } = string.Empty;
}
