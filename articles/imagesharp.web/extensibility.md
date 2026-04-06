# Extensibility

ImageSharp.Web is designed as a set of replaceable layers rather than one monolithic middleware. Most customizations only need one of those layers, so the first job is choosing the lightest extension point that matches your problem.

## Choose the Right Extension Point

- Use [`OnParseCommandsAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnParseCommandsAsync) when the request shape is already close to what you want and you only need to add, remove, or normalize commands.
- Use [`IRequestParser`](xref:SixLabors.ImageSharp.Web.Commands.IRequestParser) when the request syntax changes completely.
- Use [`IImageWebProcessor`](xref:SixLabors.ImageSharp.Web.Processors.IImageWebProcessor) when you need a new image-processing command.
- Use [`ICommandConverter`](xref:SixLabors.ImageSharp.Web.Commands.Converters.ICommandConverter) when your processor needs a custom typed command value.
- Use [`IImageProvider`](xref:SixLabors.ImageSharp.Web.Providers.IImageProvider) and [`IImageResolver`](xref:SixLabors.ImageSharp.Web.Resolvers.IImageResolver) when source images come from a new backend.
- Use [`IImageCache`](xref:SixLabors.ImageSharp.Web.Caching.IImageCache) and [`IImageCacheResolver`](xref:SixLabors.ImageSharp.Web.Resolvers.IImageCacheResolver) when processed output should be stored in a new backend.
- Use [`ICacheKey`](xref:SixLabors.ImageSharp.Web.Caching.ICacheKey) or [`ICacheHash`](xref:SixLabors.ImageSharp.Web.Caching.ICacheHash) when only cache naming needs to change.

## Add a Custom Processor

Custom processors are the usual way to introduce a new query-string command. Implement [`IImageWebProcessor`](xref:SixLabors.ImageSharp.Web.Processors.IImageWebProcessor), parse your command values from the [`CommandCollection`](xref:SixLabors.ImageSharp.Web.Commands.CommandCollection), and mutate the [`FormattedImage`](xref:SixLabors.ImageSharp.Web.FormattedImage):

```csharp
using System.Globalization;
using Microsoft.Extensions.Logging;
using SixLabors.ImageSharp.Processing;
using SixLabors.ImageSharp.Web;
using SixLabors.ImageSharp.Web.Commands;
using SixLabors.ImageSharp.Web.Processors;

public sealed class SepiaWebProcessor : IImageWebProcessor
{
    public IEnumerable<string> Commands { get; } = new[] { "sepia" };

    public FormattedImage Process(
        FormattedImage image,
        ILogger logger,
        CommandCollection commands,
        CommandParser parser,
        CultureInfo culture)
    {
        if (parser.ParseValue<bool>(commands.GetValueOrDefault("sepia"), culture))
        {
            image.Image.Mutate(x => x.Sepia());
        }

        return image;
    }

    public bool RequiresTrueColorPixelFormat(
        CommandCollection commands,
        CommandParser parser,
        CultureInfo culture) => false;
}
```

Register it with the builder:

```csharp
builder.Services.AddImageSharp()
    .AddProcessor<SepiaWebProcessor>();
```

Processor order is driven by the order of the recognized command keys in the request, so custom processors participate in the same ordering model as the built-in ones.

## Custom Command Converters

The built-in converters already cover integral types, floating-point values, booleans, strings, arrays, lists, colors, and enums. If your processor wants a custom command type, implement `ICommandConverter<T>`, register it with `AddConverter<TConverter>()`, then parse it inside the processor with `CommandParser.ParseValue<T>()`.

This is the right place to centralize parsing rules for custom value syntaxes instead of repeating string parsing inside each processor.

## Custom Providers and Caches

Implement a custom provider when your source image is not on disk, in Azure Blob Storage, or in S3. A provider owns request matching and returns a resolver that can:

- open the source stream;
- report source last-write and cache metadata;
- decide whether requests are `CommandOnly` or always handled.

When the source maps naturally to an `IFileProvider`, [`FileProviderImageProvider`](xref:SixLabors.ImageSharp.Web.Providers.FileProviderImageProvider) is the easiest base class.

Implement a custom cache when processed images should live somewhere other than the built-in physical filesystem cache or the cloud caches. A cache receives the hashed key, encoded stream, and [`ImageCacheMetadata`](xref:SixLabors.ImageSharp.Web.ImageCacheMetadata), then later returns an [`IImageCacheResolver`](xref:SixLabors.ImageSharp.Web.Resolvers.IImageCacheResolver) that can reopen the cached entry.

If you only need different cache naming rather than a whole new backend, replace [`ICacheKey`](xref:SixLabors.ImageSharp.Web.Caching.ICacheKey) or [`ICacheHash`](xref:SixLabors.ImageSharp.Web.Caching.ICacheHash) instead of writing a new cache.

## Replace the Request Syntax

Implement [`IRequestParser`](xref:SixLabors.ImageSharp.Web.Commands.IRequestParser) when commands should come from somewhere other than the raw query string, for example:

- route values;
- a compact signed token;
- database-backed presets;
- application-specific aliases.

Your parser returns an ordered [`CommandCollection`](xref:SixLabors.ImageSharp.Web.Commands.CommandCollection). That order matters because it is what the middleware uses to decide processor execution order.

## Extend Razor Integration

If you add custom processors and want equally natural Razor markup, derive from [`ImageTagHelper`](xref:SixLabors.ImageSharp.Web.TagHelpers.ImageTagHelper) and override `AddProcessingCommands(...)` to write your custom command keys into the outgoing URL.

That lets your Razor layer stay strongly typed instead of falling back to raw query-string fragments.

## Related Topics

- [Configuration and Pipeline](configuration.md)
- [Processing Commands](processingcommands.md)
- [Image Providers](imageproviders.md)
- [Image Caches](imagecaches.md)
- [Tag Helpers](taghelpers.md)
