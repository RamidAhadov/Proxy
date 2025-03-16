namespace Proxy.DataService.Monitoring.Abstractions;

public interface IServiceMetricReporter
{
    void RegisterReceivedMessage(string topic);
    
    void RegisterReceivedMessageError(string topic);
}