using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using NLog;
using NLog.Extensions.Logging;
using Prometheus;
using Proxy.DataService.Configuration.ConfigItems;
using Proxy.DataService.DataCreators.Abstractions;
using Proxy.DataService.DataCreators;

using Proxy.Messaging.MessageManagers.Abstractions;
using Proxy.Messaging.MessageManagers.Kafka;

namespace Proxy.DataService.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection ConfigureServices(this IServiceCollection services)
    {
        services.AddSingleton<IDataCreator, DataCreator>();
        services.AddSingleton<IMessageProducer, KafkaProducer>();
        
        return services;
    }
    
    public static IServiceCollection ConfigureSettings(this IServiceCollection services, IConfigurationRoot root)
    {
        CreationSettings creationSettings = new();
        KafkaSettings kafkaSettings = new();

        root.GetSection("CreationSettings").Bind(creationSettings);
        root.GetSection("KafkaSettings").Bind(kafkaSettings);

        services.AddSingleton(creationSettings);
        services.AddSingleton(kafkaSettings);

        return services;
    }
    
    public static IServiceCollection ConfigureLogging(this IServiceCollection services)
    {
        LogManager.Setup().LoadConfigurationFromFile("/etc/Proxy/Configuration/NLog.config");

        services.AddLogging(loggingBuilder =>
        {
            loggingBuilder.ClearProviders();
            loggingBuilder.AddNLog();
        });

        return services;
    }

    public static IServiceCollection ConfigureKestrelServer(this IServiceCollection services, IConfigurationRoot root)
    {
        try
        {
            KestrelMetricsServerSettings kestrelMetricsServerSettings = new();
            root.GetSection("KestrelMetricsServerSettings").Bind(kestrelMetricsServerSettings);
            KestrelMetricServer server = new KestrelMetricServer(kestrelMetricsServerSettings.Url, kestrelMetricsServerSettings.Port);
            server.Start();
            Console.WriteLine("Kestrel server running...");
        
            return services;
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            throw;
        }
    }
}