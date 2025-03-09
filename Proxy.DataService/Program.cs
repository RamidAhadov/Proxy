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
        if (args.Length > 0)
        {
            configPath = args[0];
        }
        else if (!string.IsNullOrEmpty(Environment.GetEnvironmentVariable("CONFIG_PATH")))
        {
            configPath = Environment.GetEnvironmentVariable("CONFIG_PATH")!;
        }
        
        IConfigurationBuilder builder = new ConfigurationBuilder().AddJsonFile(configPath);
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