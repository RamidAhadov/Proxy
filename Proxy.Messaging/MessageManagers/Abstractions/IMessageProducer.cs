namespace Proxy.Messaging.MessageManagers.Abstractions;

public interface IMessageProducer
{
    Task ProduceMessageAsync(string topic, string message);
}