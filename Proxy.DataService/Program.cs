using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Proxy.DataService.Extensions;
using Proxy.DataService.DataCreators.Abstractions;

namespace Proxy.DataService;

public class Program
{
    public static async Task Main(string[] args)
    {
        IConfigurationBuilder builder = new ConfigurationBuilder().AddJsonFile(
            "");
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