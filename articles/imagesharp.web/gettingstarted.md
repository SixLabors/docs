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

`app.UseImageSharp()` must appear before `app.UseStaticFiles()`. If static files run first, requests such as `/images/photo.jpg?width=400` will be served directly from disk and ImageSharp.Web will never see them.

## What the Default Registration Includes

`AddImageSharp()` wires up the core middleware services plus a sensible default pipeline:

- [`QueryCollectionRequestParser`](xref:SixLabors.ImageSharp.Web.Commands.QueryCollectionRequestParser) reads commands from the query string.
- [`PhysicalFileSystemProvider`](xref:SixLabors.ImageSharp.Web.Providers.PhysicalFileSystemProvider) resolves source images from the web root by default.
- [`PhysicalFileSystemCache`](xref:SixLabors.ImageSharp.Web.Caching.PhysicalFileSystemCache) stores processed output under `wwwroot/is-cache` by default.
- [`UriRelativeLowerInvariantCacheKey`](xref:SixLabors.ImageSharp.Web.Caching.UriRelativeLowerInvariantCacheKey) and [`SHA256CacheHash`](xref:SixLabors.ImageSharp.Web.Caching.SHA256CacheHash) create hashed cache filenames.
- [`ResizeWebProcessor`](xref:SixLabors.ImageSharp.Web.Processors.ResizeWebProcessor), [`FormatWebProcessor`](xref:SixLabors.ImageSharp.Web.Processors.FormatWebProcessor), [`BackgroundColorWebProcessor`](xref:SixLabors.ImageSharp.Web.Processors.BackgroundColorWebProcessor), [`QualityWebProcessor`](xref:SixLabors.ImageSharp.Web.Processors.QualityWebProcessor), and [`AutoOrientWebProcessor`](xref:SixLabors.ImageSharp.Web.Processors.AutoOrientWebProcessor) provide the built-in command set.
- A middleware-specific ImageSharp [`Configuration`](xref:SixLabors.ImageSharp.Configuration) with web-oriented [`JpegEncoder`](xref:SixLabors.ImageSharp.Formats.Jpeg.JpegEncoder), [`PngEncoder`](xref:SixLabors.ImageSharp.Formats.Png.PngEncoder), and [`WebpEncoder`](xref:SixLabors.ImageSharp.Formats.Webp.WebpEncoder) defaults.

With that setup in place, requests like these are processed automatically:

```text
/images/photo.jpg?width=400
/images/photo.jpg?width=400&height=250&rmode=crop
/images/logo.png?bgcolor=white&format=jpg&quality=85
```

That default configuration is intentionally opinionated for web output. Processed JPEGs use quality `75` with progressive, interleaved `YCbCrRatio420` encoding, processed PNGs use `BestCompression` with adaptive filtering, and processed WebP output uses quality `75` with `BestQuality` encoding method.

When you keep the default middleware configuration and do not return custom [`DecoderOptions`](xref:SixLabors.ImageSharp.Formats.DecoderOptions) from [`OnBeforeLoadAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnBeforeLoadAsync), the middleware also decodes with [`ColorProfileHandling.Convert`](xref:SixLabors.ImageSharp.Formats.ColorProfileHandling.Convert). That normalizes embedded ICC profiles for web-oriented re-encoding instead of blindly carrying source color encodings through the pipeline.

If you later replace [`ImageSharpMiddlewareOptions.Configuration`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.Configuration), you also replace those encoder defaults. See [Configuration and Pipeline](configuration.md) for the details and the explicit ICC-profile override pattern.

## A Useful Default Mental Model

With the default [`PhysicalFileSystemProvider`](xref:SixLabors.ImageSharp.Web.Providers.PhysicalFileSystemProvider), plain file requests still fall through to static files because it uses [`ProcessingBehavior.CommandOnly`](xref:SixLabors.ImageSharp.Web.Providers.ProcessingBehavior.CommandOnly). That means:

- `/images/photo.jpg` is served by ASP.NET Core static files.
- `/images/photo.jpg?width=400` is intercepted and processed by ImageSharp.Web.

This is usually the behavior you want for local images because it keeps the unmodified path fast and predictable.

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
