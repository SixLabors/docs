# Images, Masks, and Processing

ImageSharp.Drawing can draw images through the canvas, use images as brushes, and run ImageSharp processors inside drawing regions.

## Draw an Image

`DrawImage(...)` copies a source rectangle from an image into a destination rectangle on the canvas. The destination is affected by the current transform and clip state.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> source = Image.Load<Rgba32>("photo.jpg");
using Image<Rgba32> image = new(480, 300, Color.White.ToPixel<Rgba32>());

DrawingOptions clipInside = new()
{
    ShapeOptions = new()
    {
        BooleanOperation = BooleanOperation.Intersection
    }
};

EllipsePolygon clip = new(new PointF(240, 150), new SizeF(340, 190));

image.Mutate(ctx => ctx.Paint(canvas =>
{
    _ = canvas.Save(clipInside, clip);

    // The selected source pixels are scaled into the destination rectangle.
    canvas.DrawImage(source, new Rectangle(20, 10, 280, 180), new RectangleF(70, 54, 340, 190), KnownResamplers.Bicubic);
    canvas.Restore();

    canvas.Draw(Pens.Solid(Color.Black, 3), clip);
}));
```

Keep the source image alive until the canvas has replayed the command. With `Paint(...)`, that means the source must remain alive until `Mutate(...)` completes.

## Use an Image as a Brush

Use `ImageBrush<TPixel>` when an image should fill any path as a texture. This is different from `DrawImage(...)`: the brush samples image pixels while the supplied path controls coverage.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> source = Image.Load<Rgba32>("photo.jpg");
using Image<Rgba32> image = new(420, 260, Color.White.ToPixel<Rgba32>());

Star star = new(x: 210, y: 130, prongs: 5, innerRadii: 62, outerRadii: 118);
RectangleF sourceRegion = new(0, 0, source.Width, source.Height);
ImageBrush<Rgba32> brush = new(source, sourceRegion, new Point(-120, -70));

image.Mutate(ctx => ctx.Paint(canvas =>
{

    // The star path controls coverage; the brush supplies the sampled image pixels.
    canvas.Fill(brush, star);
    canvas.Draw(Pens.Solid(Color.DarkSlateGray, 3), star);
}));
```

## Apply Processors Inside a Shape

`Apply(...)` runs normal ImageSharp processors inside a rectangle, path, or path builder. It is a replay barrier: commands before it affect the pixels being processed, and commands after it do not.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> source = Image.Load<Rgba32>("photo.jpg");
using Image<Rgba32> image = new(520, 320, Color.White.ToPixel<Rgba32>());

RectangleF destination = new(40, 38, 440, 244);
EllipsePolygon redaction = new(new PointF(300, 168), new SizeF(150, 96));

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.DrawImage(source, source.Bounds, destination, KnownResamplers.Bicubic);

    // Apply scopes the processor to the path; pixels outside the ellipse stay unchanged.
    canvas.Apply(redaction, region => region.Pixelate(10));
    canvas.Draw(Pens.Solid(Color.OrangeRed, 3), redaction);
}));
```

On GPU-backed canvases, `Apply(...)` requires the affected pixels to be read back, processed by the CPU pipeline, and written back before presentation. Keep regions as small as the effect allows.
