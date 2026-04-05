# Getting Started

ImageSharp is easiest to learn if you think in terms of a simple flow: load or identify an image, optionally process it, then save it in the format you need. This page introduces the handful of types that show up most often in that flow so the rest of the docs feel familiar more quickly.

The main types you will run into first are:

- [`Image`](xref:SixLabors.ImageSharp.Image) is the format-agnostic image container used by the main loading, processing, and saving APIs.
- `Image<TPixel>` is the generic image container to use when you know the pixel format and want direct pixel access. See [Pixel Formats](pixelformats.md) for more detail.
- [`ImageFrame`](xref:SixLabors.ImageSharp.ImageFrame) and `ImageFrame<TPixel>` represent individual frames in multi-frame images such as GIF and WebP.
- [`ImageInfo`](xref:SixLabors.ImageSharp.ImageInfo) gives you dimensions, pixel information, and metadata without fully decoding the image.

## Load, Process, and Save an Image

The most common ImageSharp workflow is to load an image, apply a processing pipeline, and save it again:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x
    .AutoOrient()
    .Resize(800, 600));

image.Save("output.jpg");
```

This example shows the core workflow:

- `Image.Load()` detects the input format from the image data.
- `Mutate()` applies processors to the current image in order.
- `Save()` picks an encoder from the output path unless you pass one explicitly.

For more detail, see [Loading, Identifying, and Saving](loadingandsaving.md), [Processing Images](processing.md), and [Image Formats](imageformats.md).

## Read Image Information Without Decoding Pixels

If you only need image dimensions, pixel information, or metadata, use `Image.Identify()` instead of `Image.Load()`:

```csharp
using SixLabors.ImageSharp;

ImageInfo imageInfo = Image.Identify("input.jpg");

Console.WriteLine($"Width: {imageInfo.Width}");
Console.WriteLine($"Height: {imageInfo.Height}");
Console.WriteLine($"Frames: {imageInfo.FrameCount}");
```

This is usually much faster and allocates less memory because the full pixel buffer is never materialized.

## Create a New Image

You can also create images directly in memory:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

using Image<Rgba32> image = new(640, 480, Color.White);
```

Use `Image<TPixel>` when the pixel format matters to your workflow, for example when you need direct access to pixel rows or want to interoperate with a known buffer format.

## Mutate or Clone?

ImageSharp exposes two primary processing entry points:

- `Mutate()` changes the current image in place.
- `Clone()` creates a deep copy and applies the processors to that copy.

Use `Mutate()` when you want to transform the current image, and `Clone()` when you need to keep the original unchanged.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");
using Image thumbnail = image.Clone(x => x.Resize(160, 160));
```

## Dispose Images Promptly

ImageSharp images own pooled memory buffers and should be disposed as soon as you are done with them. Prefer `using` declarations or `using` blocks around `Image` and `Image<TPixel>` instances.

See [Memory Management](memorymanagement.md) for production guidance around pooling, contiguous buffers, and diagnostics.

## Next Steps

- [Loading, Identifying, and Saving](loadingandsaving.md)
- [Working with Metadata](metadata.md)
- [Processing Images](processing.md)
- [Pixel Formats](pixelformats.md)
- [Working with Pixel Buffers](pixelbuffers.md)
