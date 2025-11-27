using Microsoft.AspNetCore.Mvc;
using WakeMeUp.Models;
using WakeMeUp.Services;

namespace WakeMeUp.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ServersController : ControllerBase
{
    private readonly IWakeOnLanService _wakeOnLanService;
    private readonly List<Server> _servers;
    private readonly ILogger<ServersController> _logger;

    public ServersController(
        IWakeOnLanService wakeOnLanService,
        IConfiguration configuration,
        ILogger<ServersController> logger)
    {
        _wakeOnLanService = wakeOnLanService;
        _logger = logger;
        _servers = configuration.GetSection("Servers").Get<List<Server>>() ?? new List<Server>();
    }

    [HttpGet]
    public ActionResult<IEnumerable<ServerDto>> GetServers()
    {
        // Only return server names, not sensitive network information
        var serverDtos = _servers
            .Select(s => new ServerDto
            {
                Name = s.Name,
                IsActive = s.IsActive,
                PrettyName = s.PrettyName
            })
            .ToList();
        return Ok(serverDtos);
    }

    [HttpPost("{serverName}/wake")]
    public async Task<IActionResult> WakeServer(string serverName)
    {
        var server = _servers.FirstOrDefault(s =>
            s.Name.Equals(serverName, StringComparison.OrdinalIgnoreCase));

        if (server == null)
        {
            _logger.LogWarning("Server not found: {ServerName}", serverName);
            return NotFound(new { message = $"Server '{serverName}' not found" });
        }

        if (!server.IsActive)
        {
            _logger.LogWarning("Server found: {ServerName} but not active", serverName);
            return BadRequest(new { message = $"Server '{serverName}' is not active" });
        }

        try
        {
            await _wakeOnLanService.WakeUpServerAsync(server);
            return Ok(new { message = $"Wake-on-LAN packet sent to {server.Name}" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error waking server {ServerName}", serverName);
            return StatusCode(500, new { message = "Failed to send Wake-on-LAN packet" });
        }
    }
}
