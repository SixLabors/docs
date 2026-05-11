# Processing Images

Once an image is in memory, most work in ImageSharp happens through small ordered processing pipelines. That is one of the library's strengths: the code you write usually reads in the same order the pixels are transformed, which makes even longer pipelines approachable for newcomers.

The main entry points are [`Mutate`](xref:SixLabors.ImageSharp.Processing.ProcessingExtensions.Mutate*?displayProperty=name) and [`Clone`](xref:SixLabors.ImageSharp.Processing.ProcessingExtensions.Clone*?displayProperty=name):

- `Mutate()` applies processors to the current image.
- `Clone()` creates a deep copy and applies the processors to that copy.

Processors are deliberately composable. Each call in the pipeline receives the result of the previous call, so the code order is also the image-processing order. That makes pipelines easy to read, but it also means a misplaced operation can change the result significantly.

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

Use `Mutate()` when the loaded image is an intermediate value and there is no need to keep the original pixels. This keeps ownership simple and avoids a second full image allocation.

`Mutate()` does not mean "unsafe"; it means the current image instance is the output. That is exactly what you want for many pipelines: load a file, normalize it, resize it, adjust it, and save the result. The important ownership question is whether any later code still needs the original pixels. If not, mutating keeps memory use and code shape straightforward.

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

Use `Clone()` when the original image is a reusable source asset: for example, generating several thumbnail sizes, producing multiple export formats, or running a preview operation while keeping an editable original.

`Clone()` creates a separate image with its own pixel buffers. That makes it the right tool for fan-out workflows, but it is not free. If a service generates five output sizes from one upload, cloning for each output may be worth the clarity. If a pipeline only writes one result, cloning usually just allocates another full image for no benefit.

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
- Save with an explicit encoder when output quality, metadata, compression, or compatibility matters.

A useful way to think about processor order is to group the pipeline into stages:

1. Normalize the source into the coordinate system you intend to work in.
2. Remove pixels you no longer need.
3. Resize or otherwise change geometry.
4. Apply visual effects that depend on the final output.
5. Encode with explicit output settings.

That ordering is not mandatory, but it gives you a good default. For example, a blur before resize looks different from a blur after resize, and a crop before an expensive effect can reduce the amount of work dramatically.

## Common Processing Topics

- [Resizing Images](resize.md) covers `Resize()` and [`ResizeOptions`](xref:SixLabors.ImageSharp.Processing.ResizeOptions).
- [Crop, Pad, and Canvas](cropandcanvas.md) covers `Crop()`, `Pad()`, `BackgroundColor()`, and `EntropyCrop()`.
- [Rotate, Flip, and Auto-Orient](orientation.md) covers `AutoOrient()`, `Rotate()`, `Flip()`, and `RotateFlip()`.
- [Color and Effects](colorandeffects.md) covers `Grayscale()`, `Sepia()`, `Brightness()`, `Contrast()`, `Hue()`, `Saturate()`, and `Opacity()`.
- [Quantization, Palettes, and Dithering](quantization.md) covers `Quantize()`, palette selection, encoder quantizers, and dithering algorithms.
- [Working with Animations](animations.md) covers multi-frame workflows for GIF, APNG, and WebP.

## Related APIs

Most built-in processors live under the [`SixLabors.ImageSharp.Processing`](xref:SixLabors.ImageSharp.Processing) namespace. Import that namespace in files where you build processing pipelines.

## Practical Guidance

Use `Mutate()` for one-way processing and `Clone()` when the original image remains a source. Order processors in the same order you would describe the visual transformation, and be especially deliberate around orientation, crop, resize, and effects. Save with explicit encoder options at the final boundary so the processed pixels are not undermined by accidental output defaults.
