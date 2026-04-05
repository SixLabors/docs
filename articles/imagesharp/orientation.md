# Rotate, Flip, and Auto-Orient

Orientation issues usually show up the first time a phone photo looks rotated even though the file came straight from a camera roll. This page covers the small set of operations you will use most often to normalize orientation metadata or apply explicit geometric transforms.

The most common entry points are `AutoOrient()`, `Rotate()`, `Flip()`, and `RotateFlip()`.

## Correct Orientation from EXIF Metadata

Use `AutoOrient()` early in your pipeline to normalize images captured by cameras and phones:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x.AutoOrient());
```

`AutoOrient()` uses embedded EXIF orientation metadata when it is present. This is often the right first processing step for user-uploaded photos.

## Rotate by a Known Angle

Use `Rotate()` to rotate by a specific number of degrees or a known rotate mode:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x.Rotate(90));
```

ImageSharp also supports [`RotateMode`](xref:SixLabors.ImageSharp.Processing.RotateMode) when you want a predefined quarter-turn rotation.

## Flip Horizontally or Vertically

Use `Flip()` to mirror the image:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x.Flip(FlipMode.Horizontal));
```

See [`FlipMode`](xref:SixLabors.ImageSharp.Processing.FlipMode) for the available options.

## Combine Rotation and Flipping

Use `RotateFlip()` when you need both operations together:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x.RotateFlip(RotateMode.Rotate90, FlipMode.Vertical));
```

This can make intent clearer than chaining separate calls when the final transformation is a single orientation step.

## Normalize Orientation Before Resizing

In most workflows, orient the image before cropping or resizing:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x
    .AutoOrient()
    .Resize(1200, 800));
```

That keeps downstream dimensions and crop coordinates aligned with the final visual orientation.

## Related Topics

- [Processing Images](processing.md)
- [Crop, Pad, and Canvas](cropandcanvas.md)
- [Working with Metadata](metadata.md)
