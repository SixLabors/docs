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
- By default, that `Configuration` is not raw `Configuration.Default`; ImageSharp.Web installs web-oriented JPEG, PNG, and WebP encoders into it.
- [`OnParseCommandsAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnParseCommandsAsync) defaults to a callback that injects `autoorient=true` when the request does not already contain `autoorient`.
- [`MemoryStreamManager`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.MemoryStreamManager) controls pooled response streams.
- [`UseInvariantParsingCulture`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.UseInvariantParsingCulture) controls whether command parsing is culture-invariant.
- [`BrowserMaxAge`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.BrowserMaxAge), [`CacheMaxAge`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.CacheMaxAge), and [`CacheHashLength`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.CacheHashLength) control cache behavior.

```csharp
using SixLabors.ImageSharp.Web;
using SixLabors.ImageSharp.Web.Caching;
using SixLabors.ImageSharp.Web.Providers;

builder.Services.AddImageSharp(options =>
{
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

If you do not need to change format registrations or encoder defaults, leave [`ImageSharpMiddlewareOptions.Configuration`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.Configuration) alone. Replacing it opts you out of the middleware's built-in web defaults.

Likewise, if you do not need custom command augmentation, leave [`OnParseCommandsAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnParseCommandsAsync) alone. Replacing it opts you out of the default EXIF-normalization behavior unless you chain the existing callback yourself.

## Default Orientation Behavior

The default [`OnParseCommandsAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnParseCommandsAsync) callback inserts `autoorient=true` when the request does not already specify `autoorient`.

That makes EXIF normalization part of the default middleware behavior rather than an opt-in query-string feature. The main reason is web delivery: some browsers still ignore EXIF orientation in formats such as WebP, so relying on the encoded metadata alone does not produce consistent display results.

Two details matter in practice:

- `autoorient=false` still disables the behavior for that request because the middleware only inserts the command when it is absent.
- Replacing `OnParseCommandsAsync` with your own delegate removes the built-in insertion unless you invoke the previous delegate.

With the out-of-the-box local filesystem setup, that also means commandless image URLs are usually processed and cached instead of falling through to static files unchanged.

## Default Encoder and ICC Behavior

The default middleware [`Configuration`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.Configuration) is a cloned ImageSharp configuration with web-oriented encoder registrations:

- [`JpegEncoder`](xref:SixLabors.ImageSharp.Formats.Jpeg.JpegEncoder) uses `Quality = 75`, `Progressive = true`, `Interleaved = true`, and `ColorType = YCbCrRatio420`.
- [`PngEncoder`](xref:SixLabors.ImageSharp.Formats.Png.PngEncoder) uses `CompressionLevel = BestCompression` and `FilterMethod = Adaptive`.
- [`WebpEncoder`](xref:SixLabors.ImageSharp.Formats.Webp.WebpEncoder) uses `Quality = 75` and `Method = BestQuality`.

Those registrations are used whenever the middleware saves processed output in JPEG, PNG, or WebP format, whether the format came from the source image or from the `format` command.

If [`OnBeforeLoadAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnBeforeLoadAsync) returns `null`, the middleware also creates fallback [`DecoderOptions`](xref:SixLabors.ImageSharp.Formats.DecoderOptions) for you. The ICC-profile behavior depends on whether you kept the default configuration:

- With the default middleware configuration, [`DecoderOptions.ColorProfileHandling`](xref:SixLabors.ImageSharp.Formats.DecoderOptions.ColorProfileHandling) is [`ColorProfileHandling.Convert`](xref:SixLabors.ImageSharp.Formats.ColorProfileHandling.Convert).
- If you replace `options.Configuration`, the fallback changes to [`ColorProfileHandling.Compact`](xref:SixLabors.ImageSharp.Formats.ColorProfileHandling.Compact).

`Compact` only removes canonical sRGB ICC profile data. It does not convert non-sRGB source images. That distinction matters most when you transcode or resize JPEGs that arrive with CMYK or other non-sRGB profiles.

## Customize Encoders Without Losing ICC Conversion

If you want your own encoder registrations but still want the middleware to decode with [`ColorProfileHandling.Convert`](xref:SixLabors.ImageSharp.Formats.ColorProfileHandling.Convert), clone the current configuration, replace the encoders you care about, then return explicit decoder options:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;
using SixLabors.ImageSharp.Formats.Jpeg;
using SixLabors.ImageSharp.Web;

builder.Services.AddImageSharp(options =>
{
    Configuration configuration = options.Configuration.Clone();

    configuration.ImageFormatsManager.SetEncoder(JpegFormat.Instance, new JpegEncoder
    {
        Quality = 82,
        Progressive = true,
        Interleaved = true,
        ColorType = JpegColorType.YCbCrRatio420
    });

    options.Configuration = configuration;

    options.OnBeforeLoadAsync = (_, _) => Task.FromResult<DecoderOptions?>(new()
    {
        Configuration = configuration,
        ColorProfileHandling = ColorProfileHandling.Convert
    });
});
```

Use this pattern when you want to keep ImageSharp.Web's ICC-conversion behavior but need different encoder quality, chroma subsampling, format registrations, allocator settings, or other base ImageSharp customization.

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
- [`OnBeforeLoadAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnBeforeLoadAsync) can return custom [`DecoderOptions`](xref:SixLabors.ImageSharp.Formats.DecoderOptions) before the source image is decoded. If it returns `null`, the middleware supplies defaults based on the current `Configuration`.
- [`OnBeforeSaveAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnBeforeSaveAsync) can adjust the [`FormattedImage`](xref:SixLabors.ImageSharp.Web.FormattedImage) after processing but before encoding.
- [`OnProcessedAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnProcessedAsync) receives an [`ImageProcessingContext`](xref:SixLabors.ImageSharp.Web.Middleware.ImageProcessingContext) after encoding but before the result is cached.
- [`OnPrepareResponseAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnPrepareResponseAsync) runs after status code and headers are set but before the body is written.

```csharp
using SixLabors.ImageSharp.Web;
using SixLabors.ImageSharp.Web.Middleware;

builder.Services.AddImageSharp(options =>
{
    Func<ImageCommandContext, Task> defaultParse = options.OnParseCommandsAsync;

    options.OnParseCommandsAsync = async context =>
    {
        await defaultParse(context);

        if (!context.Commands.Contains("format"))
        {
            context.Commands["format"] = "webp";
        }

    };

    options.OnPrepareResponseAsync = context =>
    {
        context.Response.Headers["X-ImageSharp"] = "true";
        return Task.CompletedTask;
    };
});
```

These callbacks are often the right tool when you need small workflow adjustments without inventing a custom provider, parser, or processor. If you override `OnParseCommandsAsync`, preserve the existing delegate unless you intentionally want to remove the middleware's default `autoorient=true` insertion.

## Related Topics

- [Getting Started](gettingstarted.md)
- [Processing Commands](processingcommands.md)
- [Securing Requests](security.md)
- [Extensibility](extensibility.md)
