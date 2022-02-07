# Getting Started

>[!NOTE]
>The official guide assumes intermediate level knowledge of C# and .NET. If you are totally new to .NET development, it might not be the best idea to jump right into a framework as your first step - grasp the basics then come back. Prior experience with other languages and frameworks helps, but is not required.

### Setup and Configuration

Once installed you will need to add the following code  to `ConfigureServices` and `Configure` in your `Startup.cs` file.

This installs the the default service and options.

``` c#
public void ConfigureServices(IServiceCollection services) {
    // Add the default service and options.
    services.AddImageSharp();
}

public void Configure(IApplicationBuilder app, IWebHostEnvironment env) {

    // Add the image processing middleware.
    app.UseImageSharp();
}
```

The fluent configuration is flexible allowing you to configure a multitude of different options. For example you can add the default service and custom options.

``` c#
// Add the default service and custom options.
services.AddImageSharp(
    options =>
        {
            // You only need to set the options you want to change here
            // All properties have been listed for demonstration purposes
            // only.
            options.Configuration = Configuration.Default;
            options.MemoryStreamManager = new RecyclableMemoryStreamManager();
            options.BrowserMaxAge = TimeSpan.FromDays(7);
            options.CacheMaxAge = TimeSpan.FromDays(365);
            options.CachedHashLength = 8;
            options.OnParseCommandsAsync = _ => Task.CompletedTask;
            options.OnBeforeSaveAsync = _ => Task.CompletedTask;
            options.OnProcessedAsync = _ => Task.CompletedTask;
            options.OnPrepareResponseAsync = _ => Task.CompletedTask;
        });
```

Or you can fine-grain control adding the default options and configure other services.

``` c#
// Fine-grain control adding the default options and configure other services.
services.AddImageSharp()
        .RemoveProcessor<FormatWebProcessor>()
        .RemoveProcessor<BackgroundColorWebProcessor>();
```

There are also factory methods for each builder that will allow building from configuration files.

``` c#
// Use the factory methods to configure the PhysicalFileSystemCacheOptions
services.AddImageSharp()
    .Configure<PhysicalFileSystemCacheOptions>(options =>
    {
        options.CacheFolder = "different-cache";
    });
```  
  
Full Configuration API options are available [here](xref:SixLabors.ImageSharp.Web.DependencyInjection.ImageSharpBuilderExtensions).