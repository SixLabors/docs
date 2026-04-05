# Migrating from System.Drawing

If you are coming from `System.Drawing`, the biggest adjustment is not learning a brand-new set of image concepts. It is mostly learning that ImageSharp makes a few things explicit that GDI+ used to hide: pixel type, processing pipelines, and encoder choices.

Once that shift lands, most everyday workflows map over cleanly.

## Core Type Mapping

| `System.Drawing` concept | ImageSharp equivalent |
|---|---|
| `Image` / `Bitmap` | [`Image`](xref:SixLabors.ImageSharp.Image) or [`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1) |
| `Color` | [`Color`](xref:SixLabors.ImageSharp.Color) or a specific pixel type such as [`Rgba32`](xref:SixLabors.ImageSharp.PixelFormats.Rgba32) |
| `PixelFormat` | generic `TPixel` plus [`PixelTypeInfo`](xref:SixLabors.ImageSharp.PixelFormats.PixelTypeInfo) |
| `GetPixel` / `SetPixel` | indexers or `ProcessPixelRows(...)` |
| `LockBits` / `UnlockBits` | `ProcessPixelRows(...)`, `CopyPixelDataTo(...)`, `LoadPixelData(...)`, `WrapMemory(...)`, `DangerousTryGetSinglePixelMemory(...)` |
| `Image.Save(...)` with codec choices | `Save(...)`, `SaveAsJpeg(...)`, `SaveAsPng(...)`, or explicit encoder types |
| `Graphics.DrawImage(...)` | `Mutate(...)` with `DrawImage(...)` |

## Loading, Processing, and Saving

A typical `System.Drawing` workflow translates to:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(context => context
    .AutoOrient()
    .Resize(400, 300));

image.SaveAsPng("output.png");
```

Instead of mutating through a separate `Graphics` object, ImageSharp uses processing pipelines built with `Mutate(...)` or `Clone(...)`.

## Pixels: Prefer Row Access Over Per-Pixel APIs

If you used `Bitmap.GetPixel()` or `Bitmap.SetPixel()` heavily, the closest ImageSharp equivalent is the indexer:

```csharp
using SixLabors.ImageSharp.PixelFormats;

Rgba32 pixel = image[10, 20];
image[10, 20] = Rgba32.White;
```

For real throughput, move to `ProcessPixelRows(...)` instead. That is the ImageSharp replacement for most `LockBits`-driven loops:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

using Image<Rgba32> image = Image.Load<Rgba32>("input.png");

image.ProcessPixelRows(accessor =>
{
    for (int y = 0; y < accessor.Height; y++)
    {
        Span<Rgba32> row = accessor.GetRowSpan(y);
        row.Reverse();
    }
});
```

## `Color` and `TPixel` Are Different

This is one of the biggest mental shifts.

[`Color`](xref:SixLabors.ImageSharp.Color) in ImageSharp is a general color value that can convert to any [`IPixel<TSelf>`](xref:SixLabors.ImageSharp.PixelFormats.IPixel`1) type. It is not the same thing as the `TPixel` storage type used by [`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1).

That means:

- use [`Color`](xref:SixLabors.ImageSharp.Color) when you want a pixel-agnostic color value;
- use [`Rgba32`](xref:SixLabors.ImageSharp.PixelFormats.Rgba32), [`Bgra32`](xref:SixLabors.ImageSharp.PixelFormats.Bgra32), [`L8`](xref:SixLabors.ImageSharp.PixelFormats.L8), and similar types when you care about actual in-memory layout.

## Replace `PixelFormat` with `TPixel`

Instead of storing a runtime `PixelFormat` enum and branching on it later, ImageSharp encourages you to choose a generic working type:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

using Image<Rgba32> rgba = Image.Load<Rgba32>("input.tiff");
using Image<Bgra32> bgra = rgba.CloneAs<Bgra32>();
```

If you only need metadata about the decoded source layout, [`ImageInfo.PixelType`](xref:SixLabors.ImageSharp.ImageInfo.PixelType) exposes [`PixelTypeInfo`](xref:SixLabors.ImageSharp.PixelFormats.PixelTypeInfo).

## Replace `LockBits` with the Right Raw-Pixel API

If your old code used `LockBits`, the best ImageSharp replacement depends on what the code was really trying to do:

- use `ProcessPixelRows(...)` for most in-place managed algorithms;
- use `CopyPixelDataTo(...)` when you need a copied export buffer;
- use `LoadPixelData(...)` when you want to import raw bytes or pixels into a normal owned image;
- use `WrapMemory(...)` when you need a zero-copy bridge to existing memory;
- use `DangerousTryGetSinglePixelMemory(...)` only when you truly need one contiguous ImageSharp-owned buffer.

## Compositing vs Drawing APIs

If your `System.Drawing` code mainly used `Graphics.DrawImage(...)`, the closest ImageSharp equivalent is `DrawImage(...)` inside a processing pipeline.

If the old code also draws shapes, paths, or text, you will usually want the companion packages documented elsewhere in this repo:

- `SixLabors.ImageSharp.Drawing`
- `SixLabors.Fonts`

## Practical Migration Strategy

For most migrations, the least painful path is:

1. Keep the old high-level workflow the same.
2. Replace `Bitmap` with `Image<TPixel>`.
3. Replace `Graphics` operations with `Mutate(...)` or `Clone(...)`.
4. Replace `LockBits` loops with `ProcessPixelRows(...)`.
5. Standardize on a working pixel format such as [`Rgba32`](xref:SixLabors.ImageSharp.PixelFormats.Rgba32) unless you have a reason not to.

## Related Topics

- [Getting Started](gettingstarted.md)
- [Working with Pixel Buffers](pixelbuffers.md)
- [Interop and Raw Memory](interop.md)
- [Pixel Formats](pixelformats.md)
