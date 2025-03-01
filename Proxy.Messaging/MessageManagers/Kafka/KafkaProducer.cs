using Confluent.Kafka;
using Proxy.DataService.Configuration.ConfigItems;
using Proxy.Messaging.MessageManagers.Abstractions;

namespace Proxy.Messaging.MessageManagers.Kafka;

public class KafkaProducer : IMessageProducer
{
    private readonly KafkaSettings _kafkaSettings;
    private readonly IProducer<Null, string> _producer;
    
    public KafkaProducer(KafkaSettings kafkaSettings)
    {
        _kafkaSettings = kafkaSettings ?? throw new ArgumentNullException(nameof(kafkaSettings));
        ProducerConfig config = new ProducerConfig { BootstrapServers = _kafkaSettings.BootstrapServers };
        _producer = new ProducerBuilder<Null, string>(config).Build();
    }

    public async Task ProduceMessageAsync(string topic, string message)
    {
        try
        {
            var deliveryResult = await _producer.ProduceAsync(topic, new Message<Null, string> { Value = message });
            Console.WriteLine($"Message delivered to {deliveryResult.TopicPartitionOffset}");
        }
        catch (ProduceException<Null, string> e)
        {
            Console.WriteLine($"Error producing message: {e.Error.Reason}");
        }
    }
}