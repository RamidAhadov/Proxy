using Microsoft.Extensions.Logging;
using Proxy.DataService.Configuration.ConfigItems;
using Proxy.DataService.DataCreators.Abstractions;
using Proxy.Messaging.MessageManagers.Abstractions;

namespace Proxy.DataService.DataCreators;

public class DataCreator : IDataCreator
{
    private readonly ILogger _logger;
    private readonly CreationSettings _creationSettings;
    private readonly IMessageProducer _messageProducer;
    
    public DataCreator(
        ILoggerFactory loggerFactory,
        CreationSettings creationSettings, 
        IMessageProducer messageProducer)
    {
        _logger = loggerFactory.CreateLogger(GetType().Name) ?? throw new ArgumentNullException(nameof(loggerFactory));
        _creationSettings = creationSettings ?? throw new ArgumentNullException(nameof(creationSettings));
        _messageProducer = messageProducer ?? throw new ArgumentNullException(nameof(messageProducer));
    }
    
    public async Task CreateAsync()
    {
        _logger.LogInformation("Starting produce messages to kafka.");
        for (int i = 0; i < _creationSettings.MaxSendMessagesCount; i++)
        {
            foreach (var topic in _creationSettings.Topics)
            {
                await _messageProducer.ProduceMessageAsync(topic,$"Message_{i}");
            }
            await Task.Delay(_creationSettings.CreationInterval);
        }
        
        _logger.LogInformation("Finished produce messages to kafka.");
    }
}