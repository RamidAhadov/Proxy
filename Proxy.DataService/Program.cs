﻿using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.AspNetCore.Http;
using Proxy.DataService.Configuration.ConfigItems;
using Proxy.DataService.Extensions;
using System.Threading.Tasks;

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

        if (File.Exists("/local/wildcard.pfx"))
        {
            Console.WriteLine("✅ Wildcard PFX file found!");
            Console.WriteLine($"File Size: {new FileInfo("/local/wildcard.pfx").Length} bytes");
        }
        else
        {
            Console.WriteLine("❌ ERROR: Wildcard PFX file NOT found!");
        }

        IConfigurationBuilder builder = new ConfigurationBuilder()
            .SetBasePath(Path.GetDirectoryName(configPath)!)
            .AddJsonFile(configPath, optional: false, reloadOnChange: true);

        IConfigurationRoot root = builder.Build();

        var builderWeb = WebApplication.CreateBuilder(args);
        ControllerSettings controllerSettings = new();
        root.GetSection("ControllerSettings").Bind(controllerSettings);
        
        builderWeb.WebHost.ConfigureKestrel(options =>
        {
            options.ListenAnyIP(controllerSettings.Port, listenOptions =>
            {
                listenOptions.UseHttps(controllerSettings.CertPath, controllerSettings.CertPassword);
            });
        });

        builderWeb.Services
            .ConfigureSettings(root)
            .ConfigureServices()
            .ConfigureLogging()
            .AddControllers();

        var app = builderWeb.Build();

        app.Use(async (context, next) =>
        {
            Console.WriteLine($"[GLOBAL LOG] Incoming request: {context.Request.Method} {context.Request.Path} {context.Request.QueryString}");
            await next.Invoke();
        });

        app.UseRouting();
        app.UseEndpoints(endpoints => endpoints.MapControllers());

        await app.RunAsync();
    }
}