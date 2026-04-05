# Crop, Pad, and Canvas

ImageSharp includes several processors for changing the visible region of an image or the size of its canvas. The most commonly used are `Crop()`, `Pad()`, `BackgroundColor()`, and `EntropyCrop()`.

## Crop to an Explicit Rectangle

Use `Crop()` when you know the exact rectangle you want to keep:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x.Crop(new Rectangle(100, 80, 1200, 800)));
```

This removes everything outside the requested bounds.

## Crop by Width and Height

If the crop should start at the top-left corner, you can pass just width and height:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x.Crop(800, 600));
```

## Pad to a Larger Canvas

Use `Pad()` when you want to enlarge the canvas without scaling the image:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.png");

image.Mutate(x => x.Pad(1200, 1200, Color.White));
```

This is useful when generating square thumbnails, social cards, or export assets that require a fixed output size.

## Fill Transparent Areas or Flatten Onto a Background

Use `BackgroundColor()` to fill transparent pixels or composite the current image over a solid color:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.png");

image.Mutate(x => x.BackgroundColor(Color.White));
```

This is a common step before saving a transparent source image to a format that does not support transparency.

## Crop Automatically Based on Content

Use `EntropyCrop()` when you want ImageSharp to trim low-information borders automatically:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x.EntropyCrop());
```

This can be useful for removing large flat borders or whitespace-like areas before additional processing.

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
