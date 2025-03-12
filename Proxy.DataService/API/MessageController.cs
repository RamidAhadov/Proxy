using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Proxy.Messaging.MessageManagers.Abstractions;

namespace Proxy.DataService.API;


[ApiController]
[Route("[controller]")]
public class MessageController:ControllerBase
{
    private readonly ILogger _logger;
    private readonly IMessageProducer _messageProducer;
    
    
    public MessageController(
        ILoggerFactory loggerFactory,
        IMessageProducer messageProducer)
    {
        _logger = loggerFactory.CreateLogger(GetType().Name) ?? throw new ArgumentNullException(nameof(loggerFactory));
        _messageProducer = messageProducer ?? throw new ArgumentNullException(nameof(messageProducer));
    }
    
    
    [HttpPut(nameof(PutMessageAsync))]
    public async Task<IActionResult> PutMessageAsync(string topic, string message)
    {
        try
        {
            _logger.LogInformation($"Received message: {message}");
            await _messageProducer.ProduceMessageAsync(topic, message);
            
            return Ok("Message received");
        }
        catch (Exception e)
        {
            _logger.LogError(e, $"Error while processing message: {message}");
            
            return StatusCode(500);
        }
    }
}