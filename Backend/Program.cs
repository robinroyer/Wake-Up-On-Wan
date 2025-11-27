using WakeMeUp.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddOpenApi();
builder.Configuration.AddEnvironmentVariables();

builder.Logging.AddConsole();

// Register Wake-on-LAN service
builder.Services.AddScoped<IWakeOnLanService, WakeOnLanService>();

var app = builder.Build();

// Log configuration
var logger = app.Services.GetRequiredService<ILogger<Program>>();
var urls = builder.Configuration.GetSection("Kestrel:Endpoints:Http:Url").Value
    ?? builder.Configuration["ASPNETCORE_URLS"]
    ?? "http://0.0.0.0:8080";
logger.LogInformation("Server will listen on: {Urls}", urls);
logger.LogInformation("Environment: {Environment}", app.Environment.EnvironmentName);

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

// Serve static files from wwwroot
app.UseDefaultFiles();
app.UseStaticFiles();

app.UseAuthorization();

app.MapControllers();

// SPA fallback - serve index.html for any request that doesn't match an API route
app.MapFallbackToFile("index.html");

app.Run();
