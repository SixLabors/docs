# Security Considerations

Image processing is powerful, but it is also one of the easier places for an application to burn CPU, memory, and time on untrusted input. This page is written as a practical hardening guide: what to check early, what to limit, and which ImageSharp hooks help you keep risky inputs under control.

## Preflight with Identify When Possible

If you only need to validate dimensions, frame count, metadata presence, or pixel information, use [`Image.Identify()`](xref:SixLabors.ImageSharp.Image.Identify(System.String)) instead of a full decode.

```csharp
using SixLabors.ImageSharp;

ImageInfo info = Image.Identify("upload.bin");

Console.WriteLine($"{info.Width}x{info.Height}");
Console.WriteLine($"Frames: {info.FrameCount}");
Console.WriteLine($"Bits per pixel: {info.PixelType.BitsPerPixel}");
Console.WriteLine($"Estimated pixel memory: {info.GetPixelMemorySize():N0} bytes");
```

This lets you reject obviously unsuitable files before allocating the full decoded image buffers.

[`ImageInfo.GetPixelMemorySize()`](xref:SixLabors.ImageSharp.ImageInfo.GetPixelMemorySize) is particularly useful here. It gives you a decoded pixel-memory estimate up front, which helps protect services against inputs that are cheap to upload but expensive to expand into memory, especially when many frames are involved.

## Reduce Decode Cost with DecoderOptions

[`DecoderOptions`](xref:SixLabors.ImageSharp.Formats.DecoderOptions) is the main place to constrain decode behavior:

- [`TargetSize`](xref:SixLabors.ImageSharp.Formats.DecoderOptions.TargetSize) decodes to a bounded fit-within size equivalent to [`ResizeMode.Max`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Max).
- [`MaxFrames`](xref:SixLabors.ImageSharp.Formats.DecoderOptions.MaxFrames) limits how many frames are decoded from animated formats.
- [`SkipMetadata`](xref:SixLabors.ImageSharp.Formats.DecoderOptions.SkipMetadata) avoids loading encoded metadata when you do not need it.
- [`SegmentIntegrityHandling`](xref:SixLabors.ImageSharp.Formats.DecoderOptions.SegmentIntegrityHandling) controls how tolerant decoding is of damaged segments.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;

DecoderOptions options = new()
{
    MaxFrames = 1,
    SkipMetadata = true,
    TargetSize = new Size(1600, 1600),
    SegmentIntegrityHandling = SegmentIntegrityHandling.IgnoreNone
};

using Image image = Image.Load(options, stream);
```

For public upload endpoints, `MaxFrames = 1` is often appropriate when you only need a poster frame or preview. Likewise, `SkipMetadata = true` is a straightforward win when EXIF, ICC, IPTC, and XMP data are irrelevant to the workflow.

## Be Deliberate About Error Tolerance

[`SegmentIntegrityHandling`](xref:SixLabors.ImageSharp.Formats.DecoderOptions.SegmentIntegrityHandling) is a tradeoff between strictness and recovery:

- [`IgnoreNone`](xref:SixLabors.ImageSharp.Formats.SegmentIntegrityHandling.IgnoreNone) rejects files on any segment validation error.
- [`IgnoreNonCritical`](xref:SixLabors.ImageSharp.Formats.SegmentIntegrityHandling.IgnoreNonCritical) is the library default.
- [`IgnoreData`](xref:SixLabors.ImageSharp.Formats.SegmentIntegrityHandling.IgnoreData) and [`IgnoreAll`](xref:SixLabors.ImageSharp.Formats.SegmentIntegrityHandling.IgnoreAll) are better suited to recovery tools than to public-facing ingest paths.

That recommendation is an inference from the enum semantics: the more errors you ignore, the more "best effort" your decode path becomes.

## Restrict the Supported Format Set

If your service only needs a small number of formats, build a dedicated [`Configuration`](xref:SixLabors.ImageSharp.Configuration) instead of exposing every registered codec:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Jpeg;
using SixLabors.ImageSharp.Formats.Png;

Configuration config = new(
    new PngConfigurationModule(),
    new JpegConfigurationModule());

DecoderOptions options = new()
{
    Configuration = config
};
```

This reduces the amount of format detection and decoder surface area involved in that pipeline.

## Limit Memory Use

You can impose conservative allocation limits with a custom [`MemoryAllocator`](xref:SixLabors.ImageSharp.Memory.MemoryAllocator):

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Memory;

Configuration config = Configuration.Default.Clone();
config.MemoryAllocator = MemoryAllocator.Create(new MemoryAllocatorOptions
{
    // Roughly limits the workload to about 64 megapixels of Rgba32 data.
    AllocationLimitMegabytes = 256
});
```

This is one of the most important safeguards for services that handle arbitrary uploads. For broader guidance on allocator behavior and tradeoffs, see [Memory Management](memorymanagement.md).

## Put Outer Limits Around Streams and Requests

ImageSharp requires a readable stream, and for non-seekable streams it copies the input into an internal seekable memory stream before decoding. In practice that means request-body limits, upload-size limits, and outer buffering rules still matter even before pixel buffers are allocated.

Use your hosting layer to enforce:

- maximum request body size;
- authentication or signed commands when appropriate;
- rate limiting;
- reverse proxy limits; and
- service or container isolation for expensive workloads.

For ImageSharp.Web command signing, see [Securing Requests in ImageSharp.Web](../imagesharp.web/security.md).

## Practical Security Defaults

- Use `Identify()` first whenever a full decode is not necessary.
- Use `GetPixelMemorySize()` during identify-based preflight when you need a decoded memory budget check.
- Use `TargetSize`, `MaxFrames`, and `SkipMetadata` to shrink decode cost up front.
- Prefer `IgnoreNone` or the default `IgnoreNonCritical` over broader error ignoring on untrusted inputs.
- Restrict the enabled format modules when your workload only needs a few codecs.
- Use allocator limits and host-level request limits together rather than relying on only one layer.
