namespace WakeMeUp.Models;

/// <summary>
/// Data Transfer Object for Server - only exposes the server name to the frontend
/// MAC address, broadcast address, and gateway IP are kept private for security
/// </summary>
public class ServerDto
{
    public string Name { get; set; } = string.Empty;
    public string PrettyName { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
}
