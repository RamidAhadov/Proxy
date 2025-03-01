namespace Proxy.DataService.Configuration.ConfigItems;

public class KafkaSettings
{
    public string BootstrapServers { get; set; }
    public List<string> Topics { get; set; }
    public string GroupId { get; set; }
    public string AutoOffsetReset { get; set; }
    public bool EnableAutoCommit { get; set; }
}