﻿namespace Proxy.DataService.Configuration.ConfigItems;

public class CreationSettings : IConfigItem
{
    public List<string> Topics { get; set; }
    public int MaxSendMessagesCount { get; set; }
    public int CreationInterval { get; set; }
}