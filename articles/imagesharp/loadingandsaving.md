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

If you want to preserve the original encoded format after processing, reuse the decoded format stored in metadata:
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

## Related Topics

- [Working with Metadata](metadata.md)
- [Image Formats](imageformats.md)
- [Processing Images](processing.md)
