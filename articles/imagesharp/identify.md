# Read Image Info Without Decoding

When you are working with uploads, queues, or validation rules, fully decoding every image is often unnecessary work. `Image.Identify()` and `Image.DetectFormat()` let you answer the early questions first: what is this file, how large is it, how many frames does it have, and what kind of pixel data does it claim to contain?

## Read Dimensions, Frame Count, and Pixel Info

`Image.Identify()` returns an [`ImageInfo`](xref:SixLabors.ImageSharp.ImageInfo) with dimensions, frame count, pixel type, and metadata:

```csharp
using SixLabors.ImageSharp;

ImageInfo imageInfo = Image.Identify("input.webp");

Console.WriteLine($"{imageInfo.Width}x{imageInfo.Height}");
Console.WriteLine($"Frames: {imageInfo.FrameCount}");
Console.WriteLine($"Bits per pixel: {imageInfo.PixelType.BitsPerPixel}");
```

## Inspect the Encoded Pixel Type

[`ImageInfo.PixelType`](xref:SixLabors.ImageSharp.ImageInfo.PixelType) gives you the encoded pixel characteristics reported by the format metadata. This is more than a single bit-depth number. [`PixelTypeInfo`](xref:SixLabors.ImageSharp.PixelFormats.PixelTypeInfo) can tell you whether the source is indexed, grayscale, RGB, alpha-bearing, or higher precision:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

ImageInfo imageInfo = Image.Identify("input.tiff");
PixelTypeInfo pixelType = imageInfo.PixelType;

Console.WriteLine($"Bits per pixel: {pixelType.BitsPerPixel}");
Console.WriteLine($"Color type: {pixelType.ColorType}");
Console.WriteLine($"Alpha: {pixelType.AlphaRepresentation}");

if (pixelType.ComponentInfo is { } componentInfo)
{
    Console.WriteLine($"Components: {componentInfo.ComponentCount}");
    Console.WriteLine($"Max component precision: {componentInfo.GetMaximumComponentPrecision()}");
}
```

This is especially useful before format conversion, because the same pixel-type information is used by ImageSharp's format-bridging metadata to choose the best destination encoding options the target format can support.

## Detect the Encoded Format

If you specifically want to know what encoded format a file contains, use `Image.DetectFormat()`:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;

IImageFormat format = Image.DetectFormat("input.bin");

Console.WriteLine(format.Name);
```

This is useful when file extensions are missing or untrustworthy.

## Use Async APIs

For asynchronous workflows, use `IdentifyAsync()`:

```csharp
using SixLabors.ImageSharp;

ImageInfo imageInfo = await Image.IdentifyAsync("input.webp");

Console.WriteLine(imageInfo.Width);
Console.WriteLine(imageInfo.Height);
```

## Notes

- `Image.Identify()` is usually much cheaper than `Image.Load()` for inspection-only workflows.
- `ImageInfo.Metadata` still gives you access to metadata without allocating a full pixel buffer.
- `ImageInfo.PixelType` includes color model, alpha behavior, bit depth, and component precision without decoding the full image.
- `Image.DetectFormat()` is focused on encoded format detection, while `Image.Identify()` returns the broader inspection result.

For more detail, see [Loading, Identifying, and Saving](loadingandsaving.md), [Working with Metadata](metadata.md), [Convert Between Formats](formatconversion.md), and [Pixel Formats](pixelformats.md).
