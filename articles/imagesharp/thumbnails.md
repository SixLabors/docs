# Generate Thumbnails

Thumbnail generation is one of those jobs that sounds trivial until you have to decide what "good enough" means. Do you keep the whole image visible? Do you crop to fill? Do you normalize orientation first? This page covers the two thumbnail patterns people use most often.

The usual patterns are:

- fit the image within a bounding box while preserving aspect ratio, and
- create a fixed-size thumbnail that fills the target area by cropping.

Before choosing between them, decide what the thumbnail promises to users. A catalog image often needs to show the whole object, so fit-within-box is safer. Avatars, cards, and masonry layouts usually need consistent dimensions, so crop-to-fill is a better match. That product decision should drive the resize mode rather than the other way around.

## Fit Within a Bounding Box

Use [`ResizeOptions`](xref:SixLabors.ImageSharp.Processing.ResizeOptions) with [`ResizeMode.Max`](xref:SixLabors.ImageSharp.Processing.ResizeMode) when you want the full image to fit inside a target box:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Jpeg;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x
    .AutoOrient()
    .Resize(new ResizeOptions
    {
        Size = new Size(300, 300),
        Mode = ResizeMode.Max
    }));

image.Save("thumbnail.jpg", new JpegEncoder { Quality = 85 });
```

This keeps the whole image visible and preserves aspect ratio.

The output may be smaller than the requested box in one dimension. That is the point of `ResizeMode.Max`: it respects both the maximum bounds and the source aspect ratio. If your downstream layout requires an exact canvas size, resize first and then pad onto a fixed background.

## Create a Square Center-Crop Thumbnail

Use [`ResizeMode.Crop`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Crop) to fill the target bounds and crop the overflow:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x
    .AutoOrient()
    .Resize(new ResizeOptions
    {
        Size = new Size(256, 256),
        Mode = ResizeMode.Crop,
        Position = AnchorPositionMode.Center
    }));

image.Save("avatar.jpg");
```

This is the usual pattern for avatars, cards, and tile-based UI.

For user-generated photos, consider exposing a focal point or crop anchor instead of always using the center. Faces, products, and text are not always centered in the source image.

## Keep Transparency in Thumbnails

If the source image uses transparency and you want to preserve it, save the thumbnail to a format that supports alpha, such as PNG or WebP:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Png;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.png");

image.Mutate(x => x.Resize(new ResizeOptions
{
    Size = new Size(256, 256),
    Mode = ResizeMode.Max
}));

image.Save("thumbnail.png", new PngEncoder());
```

## Notes

- `AutoOrient()` is usually the right first step for user-uploaded photos.
- `ResizeMode.Max` is for fit-within-box results.
- `ResizeMode.Crop` is for fixed output dimensions that must be fully filled.
- Use explicit encoders when thumbnail quality, metadata, color profile behavior, or file size needs to be predictable.

For more detail on resizing behavior, see [Resizing Images](resize.md).
