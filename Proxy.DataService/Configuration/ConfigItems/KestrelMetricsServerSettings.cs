namespace Proxy.DataService.Configuration.ConfigItems;

public class KestrelMetricsServerSettings : IConfigItem
{
    public string Url { get; set; }
    public int Port { get; set; }
}