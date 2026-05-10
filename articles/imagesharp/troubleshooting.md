# Troubleshooting

Most ImageSharp issues turn out to be understandable once you know which layer is complaining: format detection, decoding, memory, streams, or disposal. This page groups the common failures that way so it is easier to move from symptom to likely cause.

## "Image format is unknown"

[`UnknownImageFormatException`](xref:SixLabors.ImageSharp.UnknownImageFormatException) means ImageSharp could not match the input to a registered format detector or decoder.

Common causes:

- the input is empty;
- the stream is positioned incorrectly;
- the format is not registered in the current [`Configuration`](xref:SixLabors.ImageSharp.Configuration);
- the input is not an image at all.

Useful first checks:

```csharp
using SixLabors.ImageSharp;

var format = Image.DetectFormat(bytes);
ImageInfo? info = Image.Identify(bytes);
```

If `DetectFormat(...)` fails, focus on the source bytes or the active configuration before debugging anything else.

## "The format is known, but loading still fails"

[`InvalidImageContentException`](xref:SixLabors.ImageSharp.InvalidImageContentException) means the decoder recognized the format but the encoded data was invalid, truncated, or unsupported in some way.

That usually points to corrupted input, partial downloads, damaged metadata blocks, or malformed animation/frame data rather than a registration issue.

`Identify(...)` is often useful here because it lets you confirm whether basic header parsing works before you commit to a full decode.

## Stream Position Problems

By default, ImageSharp respects the current position of a seekable stream. If your stream has already been read from, loading may fail even though the underlying data is valid.

You can fix that either by resetting the stream manually or by using [`ReadOrigin.Begin`](xref:SixLabors.ImageSharp.ReadOrigin.Begin) on a custom configuration:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;

Configuration config = Configuration.Default.Clone();
config.ReadOrigin = ReadOrigin.Begin;

DecoderOptions options = new()
{
    Configuration = config
};

using Image image = Image.Load(options, stream);
```

## Large Images or Animations Use Too Much Memory

If decoding fails with an [`InvalidImageContentException`](xref:SixLabors.ImageSharp.InvalidImageContentException) that wraps an [`InvalidMemoryOperationException`](xref:SixLabors.ImageSharp.Memory.InvalidMemoryOperationException), the requested image size or frame set may be beyond the allocator limits or practical memory budget.

Before loading, run `Identify(...)` and inspect [`ImageInfo.GetPixelMemorySize()`](xref:SixLabors.ImageSharp.ImageInfo.GetPixelMemorySize). That gives you a decoded pixel-memory estimate up front and is often the fastest way to spot small encoded files that expand into very large multi-frame allocations.

Ways to reduce decode cost:

- use [`DecoderOptions.TargetSize`](xref:SixLabors.ImageSharp.Formats.DecoderOptions.TargetSize) when a smaller decode is acceptable;
- use [`DecoderOptions.MaxFrames`](xref:SixLabors.ImageSharp.Formats.DecoderOptions.MaxFrames) to cap animated formats;
- use [`DecoderOptions.SkipMetadata`](xref:SixLabors.ImageSharp.Formats.DecoderOptions.SkipMetadata) when metadata is not needed;
- adjust [`MemoryAllocatorOptions.AllocationLimitMegabytes`](xref:SixLabors.ImageSharp.Memory.MemoryAllocatorOptions.AllocationLimitMegabytes) for a larger per-allocation budget.

Also avoid turning on [`PreferContiguousImageBuffers`](xref:SixLabors.ImageSharp.Configuration.PreferContiguousImageBuffers) unless you explicitly need contiguous memory for interop.

## `DangerousTryGetSinglePixelMemory(...)` Returns `false`

That means the image is not backed by one contiguous buffer. This is normal for ImageSharp.

If you truly need a single [`Memory<T>`](xref:System.Memory`1), create or load the image with a local configuration that has [`PreferContiguousImageBuffers`](xref:SixLabors.ImageSharp.Configuration.PreferContiguousImageBuffers) set to `true`. Even then, very large images may still be unable to satisfy a contiguous allocation request.

## Raw Memory Import Fails

`LoadPixelData(...)` and `WrapMemory(...)` validate:

- width and height;
- row stride;
- byte-stride divisibility by pixel size;
- required buffer length.

If you get [`ArgumentException`](xref:System.ArgumentException) or [`ArgumentOutOfRangeException`](xref:System.ArgumentOutOfRangeException), double-check:

- whether the buffer is tightly packed or padded;
- whether you passed pixel stride or byte stride to the correct overload;
- whether the `TPixel` matches the actual input layout.

## Transform Operations Throw `DegenerateTransformException`

[`DegenerateTransformException`](xref:SixLabors.ImageSharp.Processing.Processors.Transforms.DegenerateTransformException) means a transform matrix or builder input collapsed into an invalid transform.

This usually happens when a perspective or affine transform is built from duplicate points, zero-area geometry, or other mathematically degenerate inputs.

When that happens, validate the source geometry before building the transform rather than treating it as a decoder or encoder problem.

## Memory Keeps Growing

The first question to ask is whether images are being disposed promptly.

Use:

- [`MemoryDiagnostics.TotalUndisposedAllocationCount`](xref:SixLabors.ImageSharp.Diagnostics.MemoryDiagnostics.TotalUndisposedAllocationCount) for a low-overhead signal;
- [`MemoryDiagnostics.UndisposedAllocation`](xref:SixLabors.ImageSharp.Diagnostics.MemoryDiagnostics.UndisposedAllocation) when you need stack traces for leaked allocations.

```csharp
using SixLabors.ImageSharp.Diagnostics;

Console.WriteLine(MemoryDiagnostics.TotalUndisposedAllocationCount);
```

If that number trends upward in a steady-state workload, start looking for missing `Dispose()` or `using` blocks.

## A Good Debugging Order

When an image pipeline misbehaves, this order is usually productive:

1. Run `DetectFormat(...)` or `Identify(...)`.
2. Confirm the stream position and active configuration.
3. Check whether the problem is a format-registration issue or an invalid-content issue.
4. Reduce decode cost with `TargetSize`, `MaxFrames`, or `SkipMetadata` if memory is the problem.
5. Only then investigate deeper processing or interop assumptions.

## Related Topics

- [Loading, Identifying, and Saving](loadingandsaving.md)
- [Configuration](configuration.md)
- [Memory Management](memorymanagement.md)
- [Interop and Raw Memory](interop.md)
