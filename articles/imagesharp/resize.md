# Resizing Images

Resizing is one of the most common ImageSharp operations. The simple `Resize()` overloads are good for direct width and height changes, while [`ResizeOptions`](xref:SixLabors.ImageSharp.Processing.ResizeOptions) gives you control over fit mode, anchor position, background padding, sampler choice, alpha handling, and manual target rectangles.

## Basic Resize

Use the basic overloads when you already know the destination size:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x.Resize(1200, 800));
image.Save("output.jpg");
```

ImageSharp defaults to [`KnownResamplers.Bicubic`](xref:SixLabors.ImageSharp.Processing.KnownResamplers.Bicubic), which is a solid general-purpose choice for both downscaling and upscaling.

If either `width` or `height` is `0`, ImageSharp calculates the missing dimension to preserve aspect ratio:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x.Resize(600, 0));
```

## Choose the Right Resampler

Resampler choice affects sharpness, smoothness, and aliasing:

- [`Bicubic`](xref:SixLabors.ImageSharp.Processing.KnownResamplers.Bicubic) is the balanced default.
- [`Lanczos3`](xref:SixLabors.ImageSharp.Processing.KnownResamplers.Lanczos3) is a strong choice for high-quality downscaling.
- [`Spline`](xref:SixLabors.ImageSharp.Processing.KnownResamplers.Spline) is often a good fit for enlargement.
- [`NearestNeighbor`](xref:SixLabors.ImageSharp.Processing.KnownResamplers.NearestNeighbor) is useful for pixel art and hard-edged imagery.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.png");

image.Mutate(x => x.Resize(320, 240, KnownResamplers.Lanczos3));
```

## Use ResizeOptions for Real-World Layout Rules

[`ResizeOptions`](xref:SixLabors.ImageSharp.Processing.ResizeOptions) is the main API for fit-and-fill workflows. When you use it, set [`Mode`](xref:SixLabors.ImageSharp.Processing.ResizeOptions.Mode) explicitly; its default is [`Crop`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Crop).

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x.Resize(new ResizeOptions
{
    Size = new Size(300, 300),
    Mode = ResizeMode.Crop,
    Position = AnchorPositionMode.Center,
    Sampler = KnownResamplers.Lanczos3,
    Compand = true
}));
```

The resize modes are:

- [`Crop`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Crop): fills the target box and crops overflow.
- [`Pad`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Pad): fits within the target box and fills the remainder.
- [`BoxPad`](xref:SixLabors.ImageSharp.Processing.ResizeMode.BoxPad): pads without upscaling the original image; when downscaling it behaves like `Pad`.
- [`Max`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Max): fits within the box without cropping.
- [`Min`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Min): scales until the shortest side reaches the target, without upscaling.
- [`Stretch`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Stretch): ignores aspect ratio and forces the exact size.
- [`Manual`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Manual): uses [`TargetRectangle`](xref:SixLabors.ImageSharp.Processing.ResizeOptions.TargetRectangle) to place the resized result explicitly.

## Position, Padding, and Manual Placement

`ResizeOptions` also controls where the result lands inside the output canvas:

- [`Position`](xref:SixLabors.ImageSharp.Processing.ResizeOptions.Position) sets the anchor for crop and pad operations.
- [`CenterCoordinates`](xref:SixLabors.ImageSharp.Processing.ResizeOptions.CenterCoordinates) lets you bias crop focus more precisely.
- [`PadColor`](xref:SixLabors.ImageSharp.Processing.ResizeOptions.PadColor) fills the background for padded results.
- [`TargetRectangle`](xref:SixLabors.ImageSharp.Processing.ResizeOptions.TargetRectangle) is required for [`ResizeMode.Manual`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Manual).

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.png");

image.Mutate(x => x.Resize(new ResizeOptions
{
    Size = new Size(1200, 1200),
    Mode = ResizeMode.Pad,
    Position = AnchorPositionMode.Center,
    PadColor = Color.White
}));
```

## Companding and Alpha Handling

[`Compand`](xref:SixLabors.ImageSharp.Processing.ResizeOptions.Compand) enables gamma-companded resizing, which can improve the visual quality of some photographic resizes. It is not always necessary, but it is worth testing when color accuracy matters.

[`PremultiplyAlpha`](xref:SixLabors.ImageSharp.Processing.ResizeOptions.PremultiplyAlpha) defaults to `true` and should usually stay enabled for transparent images, because interpolation behaves better when alpha is handled in premultiplied form.

## Decode Smaller When That Is Enough

If you only need a bounded preview or thumbnail, consider decoding directly to a smaller size with [`DecoderOptions.TargetSize`](xref:SixLabors.ImageSharp.Formats.DecoderOptions.TargetSize) instead of fully decoding and then resizing. ImageSharp treats that target as a fit-within box equivalent to [`ResizeMode.Max`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Max).

See [Loading, Identifying, and Saving](loadingandsaving.md) and [Security Considerations](security.md) for examples.

## WrapMemory Caveat

`Resize()` changes image dimensions and therefore needs a new backing buffer. Images created with `WrapMemory(...)` are best suited to fixed-size interop workflows, so resize them only after copying or cloning into a regular ImageSharp-owned image.

See [Interop and Raw Memory](interop.md) for the full wrapped-memory guidance.

## Related Topics

- [Processing Images](processing.md)
- [Crop, Pad, and Canvas](cropandcanvas.md)
- [Generate Thumbnails](thumbnails.md)
