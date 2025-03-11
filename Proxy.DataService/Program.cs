using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Proxy.DataService.Extensions;
using Proxy.DataService.DataCreators.Abstractions;

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
        
        IServiceCollection collection = new ServiceCollection();
        collection
            .ConfigureSettings(root)
            .ConfigureServices()
            .ConfigureLogging();
        
        ServiceProvider provider = collection.BuildServiceProvider();

        await provider.GetService<IDataCreator>()?.CreateAsync()!;
    }
}