# Clip an Image to a Shape

Use `Save(DrawingOptions, params IPath[])` with `BooleanOperation.Intersection` when later drawing should be limited to a shape. This is useful for avatars, shaped thumbnails, masked hero images, and photo badges.

The important idea is that clipping is canvas state. Once saved, the clip applies to every later command until `Restore()` is called. Draw the clipped image while that state is active, then restore before drawing borders, labels, shadows, or other elements that should sit outside the mask.

Think about the image placement and the mask separately. The clip path decides where pixels are allowed to appear. The `DrawImage(...)` destination rectangle decides how the source image is cropped and scaled into the canvas. Matching the destination rectangle to the shape bounds gives predictable avatar-style crops; using a larger rectangle intentionally zooms or pans the source behind the mask.

Clipping is also stateful, so restore as soon as the clipped drawing is complete. If you forget to restore, later borders, shadows, and labels will be clipped too, which often looks like missing drawing rather than a clipping bug.

The clip path and destination rectangle do not need to be identical, but they should be chosen deliberately. Equal bounds give a simple fit. A larger destination rectangle zooms the source behind the mask. An offset destination rectangle pans the source without moving the mask. That separation is what lets one avatar shape support several crop choices.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> source = Image.Load<Rgba32>("portrait.jpg");
using Image<Rgba32> image = new(360, 360, Color.Transparent.ToPixel<Rgba32>());

PointF avatarCenter = new(180, 180);
SizeF avatarSize = new(300, 300);
EllipsePolygon avatar = new(avatarCenter, avatarSize);
RectangleF destination = new(30, 30, 300, 300);
DrawingOptions clipInside = new()
{
    ShapeOptions = new()
    {
        // Intersection keeps the image draw inside the avatar path instead of subtracting it.
        BooleanOperation = BooleanOperation.Intersection
    }
};

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Save(clipInside, avatar);

    // The active clip limits the photo to the ellipse while DrawImage handles resizing.
    canvas.DrawImage(source, source.Bounds, destination, KnownResamplers.Bicubic);
    canvas.Restore();

    canvas.Draw(Pens.Solid(Color.White, 8), avatar);
    canvas.Draw(Pens.Solid(Color.DarkSlateGray.WithAlpha(0.4F), 2), avatar);
}));

image.Save("avatar.png");
```

Keep the source image alive until the drawing operation has replayed. The `Paint(...)` pipeline handles the canvas lifetime for this example.

Use a destination rectangle that matches the visible shape bounds when you want predictable cropping. Use a larger destination rectangle when the source image should intentionally bleed beyond the shape, for example to zoom into a face inside an avatar.

## Related Topics

- [Clipping, Regions, and Layers](clippingregionslayers.md)
- [Images, Masks, and Processing](imagesandprocessing.md)
- [Troubleshooting](troubleshooting.md)

## Practical Guidance

Save clipped state only around the commands that should be constrained, then restore before drawing borders, labels, or shadows that should sit outside the clip. Keep the source image alive until canvas replay has finished. Match the destination rectangle to the visible shape unless an intentional zoom or bleed is required.
