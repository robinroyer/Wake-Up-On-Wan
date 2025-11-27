using System.Net;
using System.Net.Sockets;
using WakeMeUp.Models;

namespace WakeMeUp.Services;

public interface IWakeOnLanService
{
    Task WakeUpServerAsync(Server server);
}

public class WakeOnLanService : IWakeOnLanService
{
    private readonly ILogger<WakeOnLanService> _logger;

    public WakeOnLanService(ILogger<WakeOnLanService> logger)
    {
        _logger = logger;
    }

    public async Task WakeUpServerAsync(Server server)
    {
        try
        {
            _logger.LogInformation("Sending Wake-on-LAN packet to {ServerName} ({MacAddress})",
                server.Name, server.MacAddress);

            var macBytes = ParseMacAddress(server.MacAddress);
            var magicPacket = CreateMagicPacket(macBytes);

            using var client = new UdpClient();
            client.EnableBroadcast = true;

            var broadcastEndpoint = new IPEndPoint(
                IPAddress.Parse(server.GatewayIp),
                9); // Port 9 is standard for WOL

            await client.SendAsync(magicPacket, magicPacket.Length, broadcastEndpoint);

            _logger.LogInformation("Wake-on-LAN packet sent successfully to {ServerName} {GatewayIp}",
                server.Name,
                server.GatewayIp);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send Wake-on-LAN packet to {ServerName}",
                server.Name);
            throw;
        }
    }

    private static byte[] ParseMacAddress(string macAddress)
    {
        // Remove common separators (: or -)
        var cleanMac = macAddress.Replace(":", "").Replace("-", "");

        if (cleanMac.Length != 12)
        {
            throw new ArgumentException($"Invalid MAC address format: {macAddress}");
        }

        var macBytes = new byte[6];
        for (int i = 0; i < 6; i++)
        {
            macBytes[i] = Convert.ToByte(cleanMac.Substring(i * 2, 2), 16);
        }

        return macBytes;
    }

    private static byte[] CreateMagicPacket(byte[] macBytes)
    {
        // Magic packet consists of:
        // - 6 bytes of 0xFF
        // - MAC address repeated 16 times
        var packet = new byte[102];

        // Fill first 6 bytes with 0xFF
        for (int i = 0; i < 6; i++)
        {
            packet[i] = 0xFF;
        }

        // Repeat MAC address 16 times
        for (int i = 0; i < 16; i++)
        {
            Array.Copy(macBytes, 0, packet, 6 + (i * 6), 6);
        }

        return packet;
    }
}
