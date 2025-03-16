using Prometheus;
using Proxy.DataService.Monitoring.Abstractions;

namespace Proxy.DataService.Monitoring;

public class PrometheusMetricReporter : IServiceMetricReporter
{
    public PrometheusMetricReporter()
    {
        // In order to not see no data in startup
        _receivedMessagesTotal.IncTo(0);
    }
    
    private readonly Counter _receivedMessagesTotal = Metrics.CreateCounter(
        "received_messages",
        "Total received messages by topic",
        labelNames: ["topic"]);
    
    private readonly Counter _receivedMessageErrorsTotal = Metrics.CreateCounter(
        "received_message_errors",
        "Total errors for received messages by topic",
        labelNames: ["topic"]);
    
    public void RegisterReceivedMessage(string topic)
    {
        _receivedMessagesTotal.WithLabels(topic).Inc();
    }

    public void RegisterReceivedMessageError(string topic)
    {
        _receivedMessageErrorsTotal.WithLabels(topic).Inc();
    }
}