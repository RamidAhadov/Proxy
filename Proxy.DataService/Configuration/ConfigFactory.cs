using Microsoft.Extensions.Configuration;


namespace Proxy.DataService.Configuration;

public class ConfigFactory
{
    private readonly IConfigurationRoot _configuration;

    
    public ConfigFactory()
    {
        var builder = new ConfigurationBuilder()
            .AddJsonFile("", optional: true, reloadOnChange: true);
        
        _configuration = builder.Build();
    }
    
    
    public void Bind(object section)
    {
        string sectionName = section.GetType().Name;
        
        bind(section, sectionName);
    }

    public void BindByName(object section, string sectionName)
    {
        bind(section, sectionName);
    }

    private void bind(object section, string sectionName)
    {
        var configSection = _configuration.GetSection(sectionName);
        if (configSection.Exists())
        {
            configSection.Bind(section);
        }
    }
}