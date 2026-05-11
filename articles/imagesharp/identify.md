# Read Image Info Without Decoding

When you are working with uploads, queues, or validation rules, fully decoding every image is often unnecessary work. `Image.Identify()` and `Image.DetectFormat()` let you answer the early questions first: what is this file, how large is it, how many frames does it have, what kind of pixel data does it claim to contain, and how much pixel memory might a full decode require?

## Read Dimensions, Frame Count, and Pixel Info

`Image.Identify()` returns an [`ImageInfo`](xref:SixLabors.ImageSharp.ImageInfo) with dimensions, frame count, pixel type, and metadata:

```csharp
using SixLabors.ImageSharp;

ImageInfo imageInfo = Image.Identify("input.webp");

Console.WriteLine($"{imageInfo.Width}x{imageInfo.Height}");
Console.WriteLine($"Frames: {imageInfo.FrameCount}");
Console.WriteLine($"Bits per pixel: {imageInfo.PixelType.BitsPerPixel}");
Console.WriteLine($"Estimated pixel memory: {imageInfo.GetPixelMemorySize():N0} bytes");
```

## Estimate Pixel Memory Before Decoding

[`ImageInfo.GetPixelMemorySize()`](xref:SixLabors.ImageSharp.ImageInfo.GetPixelMemorySize) reports the estimated in-memory size of the decoded pixel data represented by the identified image.

```csharp
using SixLabors.ImageSharp;

ImageInfo imageInfo = Image.Identify("input.gif");
long pixelBytes = imageInfo.GetPixelMemorySize();

if (pixelBytes > 256L * 1024 * 1024)
{
    throw new InvalidOperationException("Image is too large to decode safely.");
}
```

This is especially useful for upload validation and other untrusted-input workflows. A file can be small on disk but still expand into a very large decoded pixel budget, especially for multi-frame formats such as GIF, animated WebP, or TIFF. If frame metadata is available, the reported size includes all frames.

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

Use `DetectFormat()` when routing depends only on the encoded format. Use `Identify()` when you need dimensions, frame count, pixel type, or metadata-driven decisions. `DetectFormat()` answers a narrower question and does less work.

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
- `ImageInfo.GetPixelMemorySize()` estimates decoded pixel memory before you commit to a full load.
- `Image.DetectFormat()` is focused on encoded format detection, while `Image.Identify()` returns the broader inspection result.
- Identification is not a replacement for decode-time error handling. It is a cheap preflight step; malformed input can still fail later when pixels are decoded.

For more detail, see [Loading, Identifying, and Saving](loadingandsaving.md), [Working with Metadata](metadata.md), [Convert Between Formats](formatconversion.md), and [Pixel Formats](pixelformats.md).

## Practical Guidance

- Use `DetectFormat(...)` for routing by encoded format only.
- Use `Identify(...)` when dimensions, frame count, pixel type, or metadata affect the decision.
- Use `GetPixelMemorySize()` before decoding untrusted or very large inputs.
- Still handle decode failures; identification is preflight, not a guarantee that the full image is valid.
