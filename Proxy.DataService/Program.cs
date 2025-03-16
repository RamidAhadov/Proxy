using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Proxy.DataService.Configuration.ConfigItems;
using Proxy.DataService.Extensions;

namespace Proxy.DataService
{
    public class Program
    {
        public static async Task Main(string[] args)
        {
            string configPath = "/local/appsettings.json";
            int retryDelay = 3000;

            try
            {
                // Wait for config file to be available
                while (!File.Exists(configPath))
                {
                    Console.WriteLine($"[ERROR] Config file {configPath} not found! Retrying in {retryDelay / 1000} seconds...");
                    await Task.Delay(retryDelay);
                }

                IConfigurationBuilder builder = new ConfigurationBuilder()
                    .SetBasePath(Path.GetDirectoryName(configPath)!)
                    .AddJsonFile(configPath, optional: false, reloadOnChange: true);

                IConfigurationRoot root = builder.Build();

                var builderWeb = WebApplication.CreateBuilder(args);

                // Load controller settings
                ControllerSettings controllerSettings = new();
                root.GetSection("ControllerSettings").Bind(controllerSettings);
                builderWeb.WebHost.UseUrls(controllerSettings.AspNetUrl);

                // Configure services
                builderWeb.Services
                    .ConfigureSettings(root)
                    .ConfigureServices()
                    .ConfigureLogging()
                    .ConfigureKestrelServer(root)
                    .AddControllers();

                var app = builderWeb.Build();

                // Log all incoming requests
                app.Use(async (context, next) =>
                {
                    Console.WriteLine($"[REQUEST] {context.Request.Method} {context.Request.Path}{context.Request.QueryString}");
                    await next.Invoke();
                });

                // Error handling middleware
                app.Use(async (context, next) =>
                {
                    try
                    {
                        await next.Invoke();
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"[ERROR] {ex.Message}\n{ex.StackTrace}");
                        context.Response.StatusCode = 500;
                        await context.Response.WriteAsync("Internal Server Error");
                    }
                });

                app.UseRouting();
                app.UseEndpoints(endpoints => endpoints.MapControllers());

                Console.WriteLine("🚀 Proxy.DataService is running...");
                await app.RunAsync();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[FATAL ERROR] {ex.Message}\n{ex.StackTrace}");
            }
        }
    }
}