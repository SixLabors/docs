# Getting Started

ImageSharp.Web is easiest to understand as a request pipeline: match a source image, parse commands, process with ImageSharp, cache the result, then serve the cached bytes on later requests. This page shows the smallest setup first and then explains what the default registration gives you.

## Minimal ASP.NET Core Setup

```csharp
using SixLabors.ImageSharp.Web;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.Services.AddImageSharp();

WebApplication app = builder.Build();

app.UseImageSharp();
app.UseStaticFiles();

app.Run();
```

`app.UseImageSharp()` must appear before `app.UseStaticFiles()`. If static files run first, requests such as `/images/photo.jpg` or `/images/photo.jpg?width=400` will be served directly from disk and ImageSharp.Web will never see them.

## What the Default Registration Includes

`AddImageSharp()` wires up the core middleware services plus a sensible default pipeline:

- [`QueryCollectionRequestParser`](xref:SixLabors.ImageSharp.Web.Commands.QueryCollectionRequestParser) reads commands from the query string.
- [`PhysicalFileSystemProvider`](xref:SixLabors.ImageSharp.Web.Providers.PhysicalFileSystemProvider) resolves source images from the web root by default.
- [`PhysicalFileSystemCache`](xref:SixLabors.ImageSharp.Web.Caching.PhysicalFileSystemCache) stores processed output under `wwwroot/is-cache` by default.
- [`UriRelativeLowerInvariantCacheKey`](xref:SixLabors.ImageSharp.Web.Caching.UriRelativeLowerInvariantCacheKey) and [`SHA256CacheHash`](xref:SixLabors.ImageSharp.Web.Caching.SHA256CacheHash) create hashed cache filenames.
- [`ResizeWebProcessor`](xref:SixLabors.ImageSharp.Web.Processors.ResizeWebProcessor), [`FormatWebProcessor`](xref:SixLabors.ImageSharp.Web.Processors.FormatWebProcessor), [`BackgroundColorWebProcessor`](xref:SixLabors.ImageSharp.Web.Processors.BackgroundColorWebProcessor), [`QualityWebProcessor`](xref:SixLabors.ImageSharp.Web.Processors.QualityWebProcessor), and [`AutoOrientWebProcessor`](xref:SixLabors.ImageSharp.Web.Processors.AutoOrientWebProcessor) provide the built-in command set.
- A default [`OnParseCommandsAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnParseCommandsAsync) callback that inserts `autoorient=true` when the request does not already specify `autoorient`.
- A middleware-specific ImageSharp [`Configuration`](xref:SixLabors.ImageSharp.Configuration) with web-oriented [`JpegEncoder`](xref:SixLabors.ImageSharp.Formats.Jpeg.JpegEncoder), [`PngEncoder`](xref:SixLabors.ImageSharp.Formats.Png.PngEncoder), and [`WebpEncoder`](xref:SixLabors.ImageSharp.Formats.Webp.WebpEncoder) defaults.

With that setup in place, requests like these are processed automatically:

```text
/images/photo.jpg?width=400
/images/photo.jpg?width=400&height=250&rmode=crop
/images/logo.png?bgcolor=white&format=jpg&quality=85
```

That default configuration is intentionally opinionated for web output. Processed JPEGs use quality `75` with progressive, interleaved `YCbCrRatio420` encoding, processed PNGs use `BestCompression` with adaptive filtering, and processed WebP output uses quality `75` with `BestQuality` encoding method.

The default command path is opinionated too: ImageSharp.Web transparently adds `autoorient=true` unless the request already contains an `autoorient` value. That means processed output is EXIF-normalized by default, which is especially important for WebP delivery where browser orientation support is inconsistent.

When you keep the default middleware configuration and do not return custom [`DecoderOptions`](xref:SixLabors.ImageSharp.Formats.DecoderOptions) from [`OnBeforeLoadAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnBeforeLoadAsync), the middleware also decodes with [`ColorProfileHandling.Convert`](xref:SixLabors.ImageSharp.Formats.ColorProfileHandling.Convert). That normalizes embedded ICC profiles for web-oriented re-encoding instead of blindly carrying source color encodings through the pipeline.

If you later replace [`ImageSharpMiddlewareOptions.Configuration`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.Configuration), you also replace those encoder defaults. If you replace [`OnParseCommandsAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnParseCommandsAsync), you replace the default auto-orientation injection unless you explicitly preserve it. See [Configuration and Pipeline](configuration.md) for both patterns.

## A Useful Default Mental Model

With the default [`PhysicalFileSystemProvider`](xref:SixLabors.ImageSharp.Web.Providers.PhysicalFileSystemProvider), the provider itself still uses [`ProcessingBehavior.CommandOnly`](xref:SixLabors.ImageSharp.Web.Providers.ProcessingBehavior.CommandOnly), but the default middleware callback inserts `autoorient=true` when no `autoorient` command is present. In practice that means:

- `/images/photo.jpg` is intercepted, auto-oriented, cached, and served by ImageSharp.Web.
- `/images/photo.jpg?width=400` is also intercepted and processed by ImageSharp.Web.

That default favors display correctness over passthrough behavior, especially for formats such as WebP where browser EXIF-orientation support is unreliable.

If you want passthrough behavior that only processes URLs that already contain commands, you must replace [`OnParseCommandsAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnParseCommandsAsync) or otherwise bypass the middleware for those paths. `ProcessingBehavior.CommandOnly` by itself is not enough while the default auto-orientation callback is active.

## Configure the Physical Provider and Cache

If your source images or cache should live somewhere other than the default web root locations, configure the provider and cache options explicitly:

```csharp
using SixLabors.ImageSharp.Web;
using SixLabors.ImageSharp.Web.Caching;
using SixLabors.ImageSharp.Web.Providers;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

builder.Services.AddImageSharp(options =>
{
    options.BrowserMaxAge = TimeSpan.FromDays(7);
    options.CacheMaxAge = TimeSpan.FromDays(30);
})
.Configure<PhysicalFileSystemProviderOptions>(options =>
{
    options.ProviderRootPath = "assets";
})
.Configure<PhysicalFileSystemCacheOptions>(options =>
{
    options.CacheRootPath = "cache";
    options.CacheFolder = "imagesharp";
    options.CacheFolderDepth = 8;
});
```

Relative paths are resolved against the application content root. If your app does not define a web root, set both `ProviderRootPath` and `CacheRootPath` explicitly.

## Next Steps

- [Configuration and Pipeline](configuration.md)
- [Processing Commands](processingcommands.md)
- [Image Providers](imageproviders.md)
- [Image Caches](imagecaches.md)
- [Securing Requests](security.md)
