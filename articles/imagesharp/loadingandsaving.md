# Loading, Identifying, and Saving

Most ImageSharp applications start here. Whether images come from disk, streams, or upload buffers, the same load, identify, and save model applies, which makes it easy to move from a quick sample to a production pipeline without relearning the API surface.

The core idea is straightforward: use `Image.Load()` when you need pixels, `Image.Identify()` when you only need dimensions or metadata, and `Image.DetectFormat()` when you only need to know what kind of file you were given.

## Load Images

You can load images from a file path, a stream, or an in-memory byte buffer:

```csharp
using SixLabors.ImageSharp;

using Image fromFile = Image.Load("input.webp");

using FileStream stream = File.OpenRead("input.webp");
using Image fromStream = Image.Load(stream);

byte[] buffer = File.ReadAllBytes("input.webp");
using Image fromBytes = Image.Load(buffer);
```

All of these overloads inspect the image data to determine which decoder to use.

If you know the target pixel format you want in memory, use the generic overloads such as `Image.Load<Rgba32>()`.

## Use Async APIs for I/O-Bound Work

ImageSharp also exposes async load and save methods for file and stream based workflows:

```csharp
using SixLabors.ImageSharp;

await using FileStream input = File.OpenRead("input.png");
using Image image = await Image.LoadAsync(input);

await image.SaveAsync("output.webp");
```

Use the async overloads when your application already uses asynchronous I/O, for example in ASP.NET Core or background processing pipelines.

## Identify Without Decoding Pixel Data

Use `Image.Identify()` when you only need dimensions, pixel information, metadata, or a quick decoded memory estimate:

```csharp
using SixLabors.ImageSharp;

ImageInfo imageInfo = Image.Identify("input.jpg");

Console.WriteLine($"{imageInfo.Width}x{imageInfo.Height}");
Console.WriteLine($"Bits per pixel: {imageInfo.PixelType.BitsPerPixel}");
Console.WriteLine($"Frames: {imageInfo.FrameCount}");
Console.WriteLine($"Estimated pixel memory: {imageInfo.GetPixelMemorySize():N0} bytes");
```

This avoids allocating the full pixel buffer and is usually the right choice for validation, metadata extraction, thumbnail planning, and rejecting images whose decoded pixel budget is too large for your workload.

## Detect the Encoded Format

Use `Image.DetectFormat()` when you need to know what encoded format a source contains before loading it:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;

IImageFormat format = Image.DetectFormat("input.bin");

Console.WriteLine(format.Name);
```

This is useful when files arrive without a trustworthy extension or when you want to route work based on the encoded format.

## Save Images

When you save by path, ImageSharp selects an encoder from the file extension:

```csharp
using SixLabors.ImageSharp;

using Image image = Image.Load("input.jpg");

image.Save("output.png");
```

If you save by path, ImageSharp already chooses the encoder from the destination file extension. Use `DecodedImageFormat` when you want to explicitly save to the originally decoded format, especially when writing to a stream:

```csharp
using SixLabors.ImageSharp;

using Image image = Image.Load("input.jpg");

if (image.Metadata.DecodedImageFormat is not null)
{
    using FileStream output = File.Create("output.jpg");
    image.Save(output, image.Metadata.DecodedImageFormat);
}
```

`DecodedImageFormat` is only populated for images that were decoded from an existing source. Images created from scratch do not have an original encoded format to preserve.

Preserving the original format is not always the right choice. Choose the output format based on the job: JPEG or WebP for photographic delivery, PNG for lossless graphics or transparency, GIF/APNG/WebP for animations, TIFF or OpenEXR for workflows that need richer image data.

## Choose Encoders Explicitly

When you need control over output settings, pass an encoder directly:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Jpeg;
using SixLabors.ImageSharp.Formats.Png;

using Image image = Image.Load("input.jpg");

image.Save("output.jpg", new JpegEncoder { Quality = 85 });
image.Save("output.png", new PngEncoder());
```

See [Image Formats](imageformats.md) for a deeper look at encoder and decoder behavior.

## Control Decoding with DecoderOptions

Use [`DecoderOptions`](xref:SixLabors.ImageSharp.Formats.DecoderOptions) to customize decoding behavior:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;

DecoderOptions options = new()
{
    MaxFrames = 1,
    SkipMetadata = true,
    TargetSize = new Size(1200, 1200)
};

using Image image = Image.Load(options, "animated.webp");
```

These options let you limit decoded frames, skip metadata work, or decode directly to a target size when the format supports it.

Use `DecoderOptions` at trust boundaries. For upload validation, background queues, and web requests, it is better to decide frame limits, metadata policy, color-profile handling, and target decode size before allocating a full image.

## Practical Guidance

For production code, decide how much information you need before you decode pixels. `DetectFormat(...)` is the cheapest useful step when the only question is "which decoder would handle this?". `Identify(...)` is the better preflight when routing, validation, or policy depends on dimensions, frame count, encoded pixel type, or metadata. `Load(...)` should be the point where you have already decided the image is worth decoding.

Streams must remain open and readable until the load operation completes. In web and queue-based systems, prefer the async overloads so image I/O follows the rest of the application’s asynchronous flow. Once the image is decoded, treat it as a significant resource: decoded pixel buffers can be much larger than the source file, especially for high-resolution photos and multi-frame formats.

Saving deserves the same deliberate boundary. Save by extension for quick tools and samples; pass an explicit encoder when output quality, metadata, color profiles, animation settings, or compression tradeoffs are part of the contract. If a file crosses an API boundary, is cached publicly, or is compared in tests, the encoder settings should usually be visible in code.

## Related Topics

- [Working with Metadata](metadata.md)
- [Image Formats](imageformats.md)
- [Processing Images](processing.md)
