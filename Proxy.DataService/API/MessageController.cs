using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Proxy.DataService.Monitoring.Abstractions;
using Proxy.Messaging.MessageManagers.Abstractions;

namespace Proxy.DataService.API;


[ApiController]
[Route("[controller]")]
public class MessageController:ControllerBase
{
    private readonly ILogger _logger;
    private readonly IMessageProducer _messageProducer;
    private readonly IServiceMetricReporter _metricReporter;
    
    
    public MessageController(
        ILoggerFactory loggerFactory,
        IMessageProducer messageProducer, 
        IServiceMetricReporter metricReporter)
    {
        _logger = loggerFactory.CreateLogger(GetType().Name) ?? throw new ArgumentNullException(nameof(loggerFactory));
        _messageProducer = messageProducer ?? throw new ArgumentNullException(nameof(messageProducer));
        _metricReporter = metricReporter ?? throw new ArgumentNullException(nameof(metricReporter));
    }
    
    
    [HttpPut(nameof(PutMessageAsync))]
    public async Task<IActionResult> PutMessageAsync(string topic, string message)
    {
        try
        {
            Console.WriteLine($"Message: {message}");
            _logger.LogInformation($"Received message: {message}");
            _metricReporter.RegisterReceivedMessage(topic);
            await _messageProducer.ProduceMessageAsync(topic, message);
            
            return Ok("Message received");
        }
        catch (Exception e)
        {
            _logger.LogError(e, $"Error while processing message: {message}");
            Console.WriteLine($"Error while processing message: {message}. Exception: {e.Message}");
            _metricReporter.RegisterReceivedMessageError(topic);
            
            return BadRequest();
        }
    }
}