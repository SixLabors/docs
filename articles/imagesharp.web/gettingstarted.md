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

>[!IMPORTANT]
>ImageSharp.Web v2.0.0 contains breaking changes to caching which require additional configuration for v1.x installs.

With ImageSharp.Web v2.0.0 a new concept @SixLabors.ImageSharp.Web.Caching.ICacheKey was introduced to allow greater flexibility when generating cached file names. To preserve the v1.x cache format users must configure two settings:

1. @SixLabors.ImageSharp.Web.Caching.ICacheKey should be configured to use @SixLabors.ImageSharp.Web.Caching.LegacyV1CacheKey
2. @SixLabors.ImageSharp.Web.Caching.PhysicalFileSystemCacheOptions.CacheFolderDepth should be configured to use the same value as @SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.CacheHashLength - Default `12`.

A complete configuration sample allowing the replication of legacy v1.x behavior can be found below:

```c#
services.AddImageSharp(options =>
{
    // Set to previous default value of CachedNameLength
    options.CacheHashLength = 12;

    // Use the same command parsing as v1.x
    options.OnParseCommandsAsync = c =>
    {
        if (c.Commands.Count == 0)
        {
            return Task.CompletedTask;
        }

        // It's a good idea to have this to provide very basic security.
        // We can safely use the static resize processor properties.
        uint width = c.Parser.ParseValue<uint>(
            c.Commands.GetValueOrDefault(ResizeWebProcessor.Width),
            c.Culture);

        uint height = c.Parser.ParseValue<uint>(
            c.Commands.GetValueOrDefault(ResizeWebProcessor.Height),
            c.Culture);

        if (width > 4000 && height > 4000)
        {
            c.Commands.Remove(ResizeWebProcessor.Width);
            c.Commands.Remove(ResizeWebProcessor.Height);
        }

        return Task.CompletedTask;
    });
})
.Configure<PhysicalFileSystemCacheOptions>(options =>
{
    // Ensure this value is the same as CacheHashLength to generate a backwards-compatible cache folder structure
    options.CacheFolderDepth = 12;
})
.SetCacheKey<LegacyV1CacheKey>()
.ClearProviders()
.AddProvider<WebRootImageProvider>();
```

Full Configuration API options are available [here](xref:SixLabors.ImageSharp.Web.DependencyInjection.ImageSharpBuilderExtensions).