# Configuration

Most applications can use ImageSharp exactly as it comes out of the box. [`Configuration`](xref:SixLabors.ImageSharp.Configuration) only becomes interesting when you need to change what formats are available, how memory is allocated, how streams are read, or how aggressively work is parallelized.

That is why this page treats configuration as an opt-in advanced topic. Start with [`Configuration.Default`](xref:SixLabors.ImageSharp.Configuration.Default), and customize only the parts your workload truly needs.

## Use a Local Configuration for Targeted Overrides

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;

Configuration config = Configuration.Default.Clone();
config.MaxDegreeOfParallelism = 2;
config.PreferContiguousImageBuffers = true;

DecoderOptions options = new()
{
    Configuration = config
};

using Image image = Image.Load(options, stream);
```

This pattern is usually better than mutating [`Configuration.Default`](xref:SixLabors.ImageSharp.Configuration.Default) when the override only matters for one pipeline.

## What Configuration Controls

The main knobs on [`Configuration`](xref:SixLabors.ImageSharp.Configuration) are:

- [`ImageFormatsManager`](xref:SixLabors.ImageSharp.Configuration.ImageFormatsManager) for format registration, encoders, decoders, and detectors.
- [`MemoryAllocator`](xref:SixLabors.ImageSharp.Configuration.MemoryAllocator) for pooled buffer allocation and custom allocator limits.
- [`MaxDegreeOfParallelism`](xref:SixLabors.ImageSharp.Configuration.MaxDegreeOfParallelism) for row and processor parallelism.
- [`PreferContiguousImageBuffers`](xref:SixLabors.ImageSharp.Configuration.PreferContiguousImageBuffers) for interop-oriented contiguous buffers.
- [`StreamProcessingBufferSize`](xref:SixLabors.ImageSharp.Configuration.StreamProcessingBufferSize) for stream copy buffer size.
- [`ReadOrigin`](xref:SixLabors.ImageSharp.Configuration.ReadOrigin) for whether decode operations read from the current stream position or from the beginning.
- [`Properties`](xref:SixLabors.ImageSharp.Configuration.Properties) for processor-specific defaults and shared settings.

## Register a Specific Format Set

[`Configuration`](xref:SixLabors.ImageSharp.Configuration) can be created with an explicit set of [`IImageFormatConfigurationModule`](xref:SixLabors.ImageSharp.Formats.IImageFormatConfigurationModule) registrations:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Gif;
using SixLabors.ImageSharp.Formats.Jpeg;
using SixLabors.ImageSharp.Formats.Png;

Configuration config = new(
    new PngConfigurationModule(),
    new JpegConfigurationModule(),
    new GifConfigurationModule());
```

This is useful when you want a deliberately restricted format set for a service or plugin boundary. For more advanced scenarios, [`ImageFormatManager`](xref:SixLabors.ImageSharp.Formats.ImageFormatManager) also exposes methods such as `SetEncoder(...)`, `SetDecoder(...)`, and `AddImageFormatDetector(...)`.

## Tune Processor Defaults

ImageSharp stores some processor defaults through [`Configuration.Properties`](xref:SixLabors.ImageSharp.Configuration.Properties). A common example is [`GraphicsOptions`](xref:SixLabors.ImageSharp.GraphicsOptions):

```csharp
using SixLabors.ImageSharp;

Configuration config = Configuration.Default.Clone();
config.SetGraphicsOptions(options =>
{
    options.Antialias = false;
    options.BlendPercentage = 0.75F;
});
```

Those defaults then flow into processing APIs that read graphics options from the current configuration or processing context.

## Parallelism and Throughput

[`MaxDegreeOfParallelism`](xref:SixLabors.ImageSharp.Configuration.MaxDegreeOfParallelism) defaults to the machine processor count. That is often a good default for desktop and batch workloads.

For server-side applications running many requests at once, lowering this value on a local configuration can improve overall throughput by avoiding excessive per-image parallel work.

## Stream Behavior

[`ReadOrigin`](xref:SixLabors.ImageSharp.Configuration.ReadOrigin) controls whether decoding starts at the current stream position or the beginning of a seekable stream.

[`StreamProcessingBufferSize`](xref:SixLabors.ImageSharp.Configuration.StreamProcessingBufferSize) controls the buffer size used when ImageSharp copies stream data internally. Most applications should leave it alone unless profiling shows a reason to change it.

## When to Customize Configuration

Use a custom or cloned configuration when:

- You want a restricted set of supported formats.
- You need a custom [`MemoryAllocator`](xref:SixLabors.ImageSharp.Memory.MemoryAllocator).
- You want different parallelism settings for a specific workload.
- You need contiguous buffers for interop.
- You need different stream-origin behavior for a pipeline that reads partially consumed streams.

## Related Topics

- [Image Formats](imageformats.md)
- [Memory Management](memorymanagement.md)
- [Interop and Raw Memory](interop.md)
- [Troubleshooting](troubleshooting.md)
