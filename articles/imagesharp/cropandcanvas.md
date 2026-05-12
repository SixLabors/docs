# Crop, Pad, and Canvas

Cropping and canvas operations are closely related, but they solve different problems. Cropping decides which part of the current pixels you keep. Canvas operations decide how much room the image has and where those pixels sit inside it.

Thinking about those as separate questions makes the API much easier to navigate.

Coordinate choices matter here. Crop rectangles describe source pixels you want to keep. Padding and canvas-style operations describe the destination bounds you want after the operation. When a workflow feels confusing, write those two rectangles down separately: source region first, output canvas second.

## Crop to an Explicit Rectangle

Use `Crop()` when you know the exact rectangle you want to keep:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x.Crop(new Rectangle(100, 80, 1200, 800)));
```

This removes everything outside the requested bounds.

The crop rectangle is expressed in the image's current coordinate space. If the source may contain EXIF orientation, call `AutoOrient()` before choosing crop coordinates that should match what a person sees.

Cropping changes the image size and shifts the remaining pixels so the cropped rectangle becomes the new image. Any coordinates you calculated before the crop no longer refer to the same positions afterward. In workflows that add overlays, annotations, or drawing after cropping, calculate those later positions against the post-crop image.

## Crop by Width and Height

If the crop should start at the top-left corner, you can pass just width and height:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x.Crop(800, 600));
```

This overload is intentionally simple: it keeps the top-left region of the current image. Use the rectangle overload when the crop needs to be centered, anchored, or based on detected content.

## Pad to a Larger Canvas

Use `Pad()` when you want to enlarge the canvas without scaling the image:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.png");

image.Mutate(x => x.Pad(1200, 1200, Color.White));
```

This is useful when generating square thumbnails, social cards, or export assets that require a fixed output size.

Padding does not scale the original image. If the image must fit inside a larger box with a background, resize to the intended content size first, then pad to the final canvas size.

## Fill Transparent Areas or Flatten Onto a Background

Use `BackgroundColor()` to fill transparent pixels or composite the current image over a solid color:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.png");

image.Mutate(x => x.BackgroundColor(Color.White));
```

This is a common step before saving a transparent source image to a format that does not support transparency.

The background color becomes real pixel data. If you flatten before resizing, the background participates in interpolation at transparent edges. If you resize first and flatten later, transparent edge pixels are resized with alpha preserved and then composited onto the chosen background. For logos and cutouts, the difference can be visible around antialiased edges.

## Crop Automatically Based on Content

Use `EntropyCrop()` when you want ImageSharp to trim low-information borders automatically:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x.EntropyCrop());
```

This can be useful for removing large flat borders or whitespace-like areas before additional processing.

Automatic cropping is content-driven, so treat it as a convenience rather than a layout contract. It is useful for cleanup workflows, but explicit rectangles or resize anchors are better when output dimensions must be predictable.

## Combine Crop and Resize

Cropping and resizing are often used together:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x
    .AutoOrient()
    .Crop(new Rectangle(200, 120, 1000, 1000))
    .Resize(400, 400));
```

Cropping first can reduce the amount of pixel data that later processors need to touch.

## Related Topics

- [Processing Images](processing.md)
- [Resizing Images](resize.md)
- [Rotate, Flip, and Auto-Orient](orientation.md)

## Practical Guidance

Normalize orientation before choosing crop rectangles that should match what users see. Keep source-region decisions separate from final canvas-size decisions: crop decides what pixels survive, resize decides how large they become, and padding decides how much output room surrounds them. Use automatic cropping for cleanup, but prefer explicit rectangles, anchors, or resize options when the output dimensions are part of a layout contract.
