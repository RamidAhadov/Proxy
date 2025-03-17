using Prometheus;
using Proxy.DataService.Monitoring.Abstractions;

namespace Proxy.DataService.Monitoring;

public class PrometheusMetricReporter : IServiceMetricReporter
{
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