using Confluent.Kafka;
using Microsoft.Extensions.Logging;
using Proxy.DataService.Configuration.ConfigItems;
using Proxy.Messaging.MessageManagers.Abstractions;

namespace Proxy.Messaging.MessageManagers.Kafka;

public class KafkaProducer : IMessageProducer
{
    private readonly ILogger _logger;
    private readonly KafkaSettings _kafkaSettings;
    private readonly IProducer<Null, string> _producer;
    
    public KafkaProducer(
        ILoggerFactory loggerFactory, 
        KafkaSettings kafkaSettings)
    {
        _logger = loggerFactory.CreateLogger(GetType().Name) ?? throw new ArgumentNullException(nameof(loggerFactory));
        _kafkaSettings = kafkaSettings ?? throw new ArgumentNullException(nameof(kafkaSettings));
        var config = new ProducerConfig
        {
            BootstrapServers = _kafkaSettings.BootstrapServers,
            SecurityProtocol = SecurityProtocol.Plaintext,
            ApiVersionRequest = false
        };
        Console.WriteLine($"Creating producer for {_kafkaSettings.BootstrapServers}");
        _producer = new ProducerBuilder<Null, string>(config).Build();
    }

    public async Task ProduceMessageAsync(string topic, string message)
    {
        try
        {
            Console.WriteLine($"Producing message to {topic}");
                _ = await _producer.ProduceAsync(topic, new Message<Null, string> { Value = message });
            _logger.LogInformation($"Produced message: {message}");

        }
        catch (ProduceException<Null, string> e)
        {
            Console.WriteLine($"Error occured: {e.Error.Reason}");
            _logger.LogError(e, "An error occured while producing message");
        }
    }
}