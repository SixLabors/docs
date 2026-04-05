# Processing Images

ImageSharp processing pipelines are imperative and ordered. The processors you add inside `Mutate()` or `Clone()` run in the same order you write them, which makes the pipeline easy to reason about and compose.

The main entry points are [`Mutate`](xref:SixLabors.ImageSharp.Processing.ProcessingExtensions.Mutate*?displayProperty=name) and [`Clone`](xref:SixLabors.ImageSharp.Processing.ProcessingExtensions.Clone*?displayProperty=name):

- `Mutate()` applies processors to the current image.
- `Clone()` creates a deep copy and applies the processors to that copy.

## Mutate the Current Image

Use `Mutate()` when you want to transform the current image in place:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x
    .AutoOrient()
    .Resize(1200, 800)
    .Grayscale());

image.Save("output.jpg");
```

This is the most common choice for request processing, thumbnails, and one-way export workflows.

## Clone When You Need to Preserve the Original

Use `Clone()` when the original image must remain unchanged:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");
using Image thumbnail = image.Clone(x => x
    .Resize(160, 160)
    .Sepia());

thumbnail.Save("thumbnail.jpg");
```

This is useful when you need multiple derived outputs from the same source image.

## Build Ordered Pipelines

Processor order matters. For example, auto-orienting before resizing usually produces more predictable results than resizing first and correcting orientation later:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x
    .AutoOrient()
    .Crop(new Rectangle(200, 100, 1200, 800))
    .Resize(600, 400)
    .BackgroundColor(Color.White));
```

As a rule of thumb:

- Normalize orientation early.
- Crop before expensive down-stream work when the crop meaningfully reduces the pixel area.
- Apply output-specific effects near the end of the pipeline.

## Common Processing Topics

- [Resizing Images](resize.md) covers `Resize()` and [`ResizeOptions`](xref:SixLabors.ImageSharp.Processing.ResizeOptions).
- [Crop, Pad, and Canvas](cropandcanvas.md) covers `Crop()`, `Pad()`, `BackgroundColor()`, and `EntropyCrop()`.
- [Rotate, Flip, and Auto-Orient](orientation.md) covers `AutoOrient()`, `Rotate()`, `Flip()`, and `RotateFlip()`.
- [Color and Effects](colorandeffects.md) covers `Grayscale()`, `Sepia()`, `Brightness()`, `Contrast()`, `Hue()`, `Saturate()`, and `Opacity()`.
- [Quantization, Palettes, and Dithering](quantization.md) covers `Quantize()`, palette selection, encoder quantizers, and dithering algorithms.
- [Create an animated GIF](animatedgif.md) covers a multi-frame workflow.

## Related APIs

Most built-in processors live under the [`SixLabors.ImageSharp.Processing`](xref:SixLabors.ImageSharp.Processing) namespace. Import that namespace in files where you build processing pipelines.
