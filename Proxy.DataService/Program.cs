using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Proxy.DataService.Configuration.ConfigItems;
using Proxy.DataService.Extensions;

namespace Proxy.DataService;

public class Program
{
    public static async Task Main(string[] args)
    {
        string configPath = "/local/appsettings.json";

        if (!File.Exists(configPath))
        {
            Console.WriteLine($"Error: Config file {configPath} not found!");
            return;
        }

        IConfigurationBuilder builder = new ConfigurationBuilder()
            .SetBasePath(Path.GetDirectoryName(configPath)!)
            .AddJsonFile(configPath, optional: false, reloadOnChange: true);

        IConfigurationRoot root = builder.Build();

        var builderWeb = WebApplication.CreateBuilder(args);
        ControllerSettings controllerSettings = new();
        root.GetSection("ControllerSettings").Bind(controllerSettings);
        builderWeb.WebHost.UseUrls(controllerSettings.AspNetCoreAddress);

        builderWeb.Services
            .ConfigureSettings(root)
            .ConfigureServices()
            .ConfigureLogging()
            .AddControllers();

        var app = builderWeb.Build();

        app.UseRouting();
        app.UseEndpoints(endpoints => endpoints.MapControllers());

        await app.RunAsync();
    }
}