# Configuration and Pipeline

ImageSharp.Web is assembled through `AddImageSharp()` and the returned [`IImageSharpBuilder`](xref:SixLabors.ImageSharp.Web.IImageSharpBuilder). Most applications never need to replace every piece, but it helps to know what is there so you can change the correct layer without over-customizing the whole pipeline.

## What `AddImageSharp()` Registers

The default registration wires up:

- [`QueryCollectionRequestParser`](xref:SixLabors.ImageSharp.Web.Commands.QueryCollectionRequestParser) for query-string command parsing.
- [`PhysicalFileSystemCache`](xref:SixLabors.ImageSharp.Web.Caching.PhysicalFileSystemCache) for processed-output storage.
- [`UriRelativeLowerInvariantCacheKey`](xref:SixLabors.ImageSharp.Web.Caching.UriRelativeLowerInvariantCacheKey) and [`SHA256CacheHash`](xref:SixLabors.ImageSharp.Web.Caching.SHA256CacheHash) for cache naming.
- [`PhysicalFileSystemProvider`](xref:SixLabors.ImageSharp.Web.Providers.PhysicalFileSystemProvider) for source image resolution.
- The built-in resize, format, quality, background-color, and auto-orient processors.
- The built-in command converters for numbers, booleans, strings, arrays, lists, colors, and enums.

That gives you a fully working middleware out of the box, but every one of those pieces can be swapped or extended.

## Configure Middleware Options

[`ImageSharpMiddlewareOptions`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions) controls the shared middleware behavior:

- [`Configuration`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.Configuration) is the underlying ImageSharp [`Configuration`](xref:SixLabors.ImageSharp.Configuration).
- [`MemoryStreamManager`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.MemoryStreamManager) controls pooled response streams.
- [`UseInvariantParsingCulture`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.UseInvariantParsingCulture) controls whether command parsing is culture-invariant.
- [`BrowserMaxAge`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.BrowserMaxAge), [`CacheMaxAge`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.CacheMaxAge), and [`CacheHashLength`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.CacheHashLength) control cache behavior.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Web;
using SixLabors.ImageSharp.Web.Caching;
using SixLabors.ImageSharp.Web.Providers;

builder.Services.AddImageSharp(options =>
{
    options.Configuration = Configuration.Default.Clone();
    options.UseInvariantParsingCulture = true;
    options.BrowserMaxAge = TimeSpan.FromDays(7);
    options.CacheMaxAge = TimeSpan.FromDays(30);
    options.CacheHashLength = 16;
})
.Configure<PhysicalFileSystemProviderOptions>(options =>
{
    options.ProviderRootPath = "assets";
    options.ProcessingBehavior = ProcessingBehavior.CommandOnly;
})
.Configure<PhysicalFileSystemCacheOptions>(options =>
{
    options.CacheRootPath = "cache";
    options.CacheFolder = "imagesharp";
    options.CacheFolderDepth = 8;
});
```

Use a cloned ImageSharp configuration when you need a different format set, allocator behavior, or other base ImageSharp customization for the middleware.

## Change Individual Pipeline Pieces

The builder methods let you replace only the layer you actually need to change:

- `SetRequestParser<TParser>()` replaces the request parser.
- `SetCache<TCache>()` replaces the backend cache.
- `SetCacheKey<TCacheKey>()` and `SetCacheHash<TCacheHash>()` change cache naming.
- `AddProvider<TProvider>()`, `InsertProvider<TProvider>()`, `RemoveProvider<TProvider>()`, and `ClearProviders()` manage source providers.
- `AddProcessor<TProcessor>()`, `RemoveProcessor<TProcessor>()`, and `ClearProcessors()` manage the processing command set.
- `AddConverter<TConverter>()`, `RemoveConverter<TConverter>()`, and `ClearConverters()` manage typed command parsing.
- `Configure<TOptions>(...)` binds or mutates option objects for any registered provider, cache, or parser.

For example, if you want to keep the default middleware but remove format conversion:

```csharp
using SixLabors.ImageSharp.Web;
using SixLabors.ImageSharp.Web.Processors;

builder.Services.AddImageSharp()
    .RemoveProcessor<FormatWebProcessor>();
```

## Use Presets Instead of Free-Form Query Strings

[`PresetOnlyQueryCollectionRequestParser`](xref:SixLabors.ImageSharp.Web.Commands.PresetOnlyQueryCollectionRequestParser) is the built-in alternative to the normal query parser. Instead of reading every query-string command, it reads a single `preset` key and expands that to a predefined command set.

```csharp
using SixLabors.ImageSharp.Web;
using SixLabors.ImageSharp.Web.Commands;

builder.Services.AddImageSharp()
    .SetRequestParser<PresetOnlyQueryCollectionRequestParser>()
    .Configure<PresetOnlyQueryCollectionRequestParserOptions>(options =>
    {
        options.Presets["thumb"] = "width=160&height=160&rmode=crop";
        options.Presets["card"] = "width=640&height=360&rmode=crop&format=webp&quality=75";
    });
```

That turns requests like `/images/photo.jpg?preset=thumb` into a controlled, named command set without exposing arbitrary query-string processing.

## Middleware Callbacks

[`ImageSharpMiddlewareOptions`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions) also exposes targeted callbacks for app-specific customization:

- [`OnParseCommandsAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnParseCommandsAsync) runs after a provider has matched the request and after the command set has been sanitized, but before the source image is resolved.
- [`OnBeforeLoadAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnBeforeLoadAsync) can return custom [`DecoderOptions`](xref:SixLabors.ImageSharp.Formats.DecoderOptions) before the source image is decoded.
- [`OnBeforeSaveAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnBeforeSaveAsync) can adjust the [`FormattedImage`](xref:SixLabors.ImageSharp.Web.FormattedImage) after processing but before encoding.
- [`OnProcessedAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnProcessedAsync) receives an [`ImageProcessingContext`](xref:SixLabors.ImageSharp.Web.Middleware.ImageProcessingContext) after encoding but before the result is cached.
- [`OnPrepareResponseAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnPrepareResponseAsync) runs after status code and headers are set but before the body is written.

```csharp
using SixLabors.ImageSharp.Web;

builder.Services.AddImageSharp(options =>
{
    options.OnParseCommandsAsync = context =>
    {
        if (!context.Commands.Contains("format"))
        {
            context.Commands["format"] = "webp";
        }

        return Task.CompletedTask;
    };

    options.OnPrepareResponseAsync = context =>
    {
        context.Response.Headers["X-ImageSharp"] = "true";
        return Task.CompletedTask;
    };
});
```

These callbacks are often the right tool when you need small workflow adjustments without inventing a custom provider, parser, or processor.

>[!NOTE]
>`OnParseCommandsAsync` runs after HMAC generation. If you sign requests, keep any command mutations in that callback deterministic and within your own trust boundary.

## Related Topics

- [Getting Started](gettingstarted.md)
- [Processing Commands](processingcommands.md)
- [Securing Requests](security.md)
- [Extensibility](extensibility.md)
