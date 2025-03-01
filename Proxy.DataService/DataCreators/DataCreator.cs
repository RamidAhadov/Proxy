using Proxy.DataService.Configuration.ConfigItems;
using Proxy.DataService.DataCreators.Abstractions;
using Proxy.Messaging.MessageManagers.Abstractions;

namespace Proxy.DataService.DataCreators;

public class DataCreator : IDataCreator
{
    private readonly CreationSettings _creationSettings;
    private readonly IMessageProducer _messageProducer;
    
    public DataCreator(
        CreationSettings creationSettings, 
        IMessageProducer messageProducer)
    {
        _creationSettings = creationSettings ?? throw new ArgumentNullException(nameof(creationSettings));
        _messageProducer = messageProducer ?? throw new ArgumentNullException(nameof(messageProducer));
    }
    
    public async Task CreateAsync()
    {
        for (int i = 0; i < _creationSettings.MaxSendMessagesCount; i++)
        {
            foreach (var topic in _creationSettings.Topics)
            {
                await _messageProducer.ProduceMessageAsync(topic,$"Message_{i}");
            }
            await Task.Delay(_creationSettings.CreationInterval);
        }
    }
}