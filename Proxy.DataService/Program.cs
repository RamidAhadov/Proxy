using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Proxy.DataService.Extensions;

namespace Proxy.DataService;

public class Program
{
    public static async Task Main(string[] args)
    {
        string configPath = "/etc/Proxy/Configuration/appsettings.json";

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