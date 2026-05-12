# Memory Management

ImageSharp is designed so large images are practical to process without forcing every workload into one giant contiguous allocation. That is a big part of why the library scales well, but it also means memory behavior is worth understanding once you move beyond simple load-process-save samples.

This page explains the parts most developers eventually need: the default pooled allocator, when to customize it, and how those choices affect lower-level interop code.

## Compressed Size Is Not Memory Size

An encoded file can be much smaller than the image memory needed to process it. A 20 MB JPEG may decode into hundreds of megabytes of pixel data, and a multi-frame image can require far more when all frames are loaded. Memory planning should therefore start from decoded dimensions, pixel format, and frame count rather than the source file size alone.

Use [`Image.Identify()`](xref:SixLabors.ImageSharp.Image.Identify*) and [`ImageInfo.GetPixelMemorySize()`](xref:SixLabors.ImageSharp.ImageInfo.GetPixelMemorySize) when you need to estimate decoded memory before loading pixels. Use [`DecoderOptions.MaxFrames`](xref:SixLabors.ImageSharp.Formats.DecoderOptions.MaxFrames) and [`DecoderOptions.TargetSize`](xref:SixLabors.ImageSharp.Formats.DecoderOptions.TargetSize) when the workload can deliberately load less data.

## Default Behavior

[`Configuration.MemoryAllocator`](xref:SixLabors.ImageSharp.Configuration.MemoryAllocator) defaults to [`MemoryAllocator.Default`](xref:SixLabors.ImageSharp.Memory.MemoryAllocator.Default). For most applications, that default allocator is the right choice.

The ImageSharp source explicitly recommends using a single busy allocator per process. If you customize allocation behavior, prefer doing so by replacing the allocator on a shared configuration rather than creating many short-lived allocators.

## Customize the Allocator

If you need tighter control over pool size or allocation limits, create a custom allocator with [`MemoryAllocator.Create(...)`](xref:SixLabors.ImageSharp.Memory.MemoryAllocator.Create*) and [`MemoryAllocatorOptions`](xref:SixLabors.ImageSharp.Memory.MemoryAllocatorOptions):

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Memory;

Configuration config = Configuration.Default.Clone();
config.MemoryAllocator = MemoryAllocator.Create(new MemoryAllocatorOptions
{
    MaximumPoolSizeMegabytes = 128,
    AllocationLimitMegabytes = 1024,
    AccumulativeAllocationLimitMegabytes = 2048
});
```

[`MaximumPoolSizeMegabytes`](xref:SixLabors.ImageSharp.Memory.MemoryAllocatorOptions.MaximumPoolSizeMegabytes) controls retained pool size. [`AllocationLimitMegabytes`](xref:SixLabors.ImageSharp.Memory.MemoryAllocatorOptions.AllocationLimitMegabytes) controls the maximum discontiguous buffer size the allocator will allow for one live allocation group. When it is unset, the platform default is 1 GB on 32-bit processes and 4 GB on 64-bit processes. [`AccumulativeAllocationLimitMegabytes`](xref:SixLabors.ImageSharp.Memory.MemoryAllocatorOptions.AccumulativeAllocationLimitMegabytes) controls the maximum combined size of all active allocations made through that allocator instance. It is unset by default, so the allocator does not impose an accumulative cap unless you configure one.

## Prefer Contiguous Buffers Only When You Need Them

[`PreferContiguousImageBuffers`](xref:SixLabors.ImageSharp.Configuration.PreferContiguousImageBuffers) asks ImageSharp to use contiguous image buffers whenever possible:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

Configuration config = Configuration.Default.Clone();
config.PreferContiguousImageBuffers = true;

using Image<Rgba32> image = new(config, 2048, 2048);

bool contiguous = image.DangerousTryGetSinglePixelMemory(out Memory<Rgba32> pixels);
```

This is primarily for interop scenarios. It is not something to enable globally without a reason, because it reduces ImageSharp's flexibility around large pooled allocations and can hurt throughput.

For more on that workflow, see [Interop and Raw Memory](interop.md).

## Dispose Images Promptly

`Image` and `Image<TPixel>` own unmanaged resources. Always dispose them with `using` or `await using` patterns where appropriate.

ImageSharp includes finalizer-based safety nets, but relying on finalization instead of deterministic disposal can still create avoidable memory pressure and latency.

## Track Undisposed Allocations

[`MemoryDiagnostics`](xref:SixLabors.ImageSharp.Diagnostics.MemoryDiagnostics) exposes two useful diagnostics:

- [`TotalUndisposedAllocationCount`](xref:SixLabors.ImageSharp.Diagnostics.MemoryDiagnostics.TotalUndisposedAllocationCount)
- [`UndisposedAllocation`](xref:SixLabors.ImageSharp.Diagnostics.MemoryDiagnostics.UndisposedAllocation)

```csharp
using SixLabors.ImageSharp.Diagnostics;

Console.WriteLine(MemoryDiagnostics.TotalUndisposedAllocationCount);
```

For troubleshooting, you can subscribe to `UndisposedAllocation` to capture allocation stack traces for resources that leaked to the finalizer. That event is intended for diagnostics and carries significant overhead, so it should not stay enabled in normal production traffic.

## Releasing Retained Resources

If you create a custom allocator and later retire it, dispose all associated images first and then call [`ReleaseRetainedResources()`](xref:SixLabors.ImageSharp.Memory.MemoryAllocator.ReleaseRetainedResources):

```csharp
using SixLabors.ImageSharp.Memory;

MemoryAllocator allocator = MemoryAllocator.Create(new MemoryAllocatorOptions
{
    MaximumPoolSizeMegabytes = 64
});

allocator.ReleaseRetainedResources();
```

That tells the allocator to drop retained pooled buffers that are no longer needed.

## Practical Guidance

- Keep [`MemoryAllocator.Default`](xref:SixLabors.ImageSharp.Memory.MemoryAllocator.Default) unless profiling shows a real need to customize it.
- Use one shared allocator per process rather than many temporary allocators.
- Use [`AccumulativeAllocationLimitMegabytes`](xref:SixLabors.ImageSharp.Memory.MemoryAllocatorOptions.AccumulativeAllocationLimitMegabytes) when the total amount of live ImageSharp allocation should be capped, not only the size of one image allocation group.
- Avoid forcing contiguous buffers unless you truly need a single `Memory<T>` or pointer.
- Use [`DecoderOptions.TargetSize`](xref:SixLabors.ImageSharp.Formats.DecoderOptions.TargetSize) and [`DecoderOptions.MaxFrames`](xref:SixLabors.ImageSharp.Formats.DecoderOptions.MaxFrames) when you want to limit decode cost up front.
- Track leaked images with [`MemoryDiagnostics`](xref:SixLabors.ImageSharp.Diagnostics.MemoryDiagnostics) if disposal bugs are suspected.

## Related Topics

- [Configuration](configuration.md)
- [Working with Pixel Buffers](pixelbuffers.md)
- [Interop and Raw Memory](interop.md)
- [Troubleshooting](troubleshooting.md)
