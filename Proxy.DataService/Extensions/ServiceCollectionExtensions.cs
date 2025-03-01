using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

using Proxy.DataService.Configuration.ConfigItems;
using Proxy.DataService.DataCreators;
using Proxy.DataService.DataCreators.Abstractions;
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
}