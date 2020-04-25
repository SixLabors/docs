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

The fluent configuration is flexible allowing you to configure a mutlitude of different options. For example you can add the default service and custom options.

``` c#
// Add the default service and custom options.
services.AddImageSharp(
    options =>
        {
            // You only need to set the options you want to change here.
            options.Configuration = Configuration.Default;
            options.MaxBrowserCacheDays = 7;
            options.MaxCacheDays = 365;
            options.CachedNameLength = 8;
            options.OnParseCommands = _ => { };
            options.OnBeforeSave = _ => { };
            options.OnProcessed = _ => { };
            options.OnPrepareResponse = _ => { };
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
services.AddImageSharpCore(
    options =>
        {
            options.Configuration = Configuration.Default;
            options.MaxBrowserCacheDays = 7;
            options.MaxCacheDays = 365;
            options.CachedNameLength = 8;
            options.OnParseCommands = _ => { };
            options.OnBeforeSave = _ => { };
            options.OnProcessed = _ => { };
            options.OnPrepareResponse = _ => { };
        })
    .SetRequestParser<QueryCollectionRequestParser>()
    .SetMemoryAllocator(provider => ArrayPoolMemoryAllocator.CreateWithMinimalPooling())
    .Configure<PhysicalFileSystemCacheOptions>(options =>
    {
        options.CacheFolder = "different-cache";
    })
    .SetCache<PhysicalFileSystemCache>()
    .SetCacheHash<CacheHash>()
    .AddProvider<PhysicalFileSystemProvider>()
    .AddProcessor<ResizeWebProcessor>()
    .AddProcessor<FormatWebProcessor>()
    .AddProcessor<BackgroundColorWebProcessor>();
```