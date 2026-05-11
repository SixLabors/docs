# Getting Started

>[!NOTE]
>This guide assumes intermediate C# and .NET knowledge. If you are new to .NET, start with the language and runtime basics first, then come back to the image and drawing APIs.

ImageSharp.Drawing adds vector drawing, brush and pen styling, and text rendering to ImageSharp. The main workflow is:

1. Create or load an `Image`.
2. Call `Mutate(...)`.
3. Use [`Paint(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.PaintExtensions) to receive a [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas).
4. Draw onto the canvas with brushes, pens, paths, shapes, images, or text.

The same canvas can mix all of those operations. This model scales from small badges to poster-style artwork, route maps, typography sheets, image masking, and WebGPU scenes.

## Draw a Shape

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(320, 200, Color.White.ToPixel<Rgba32>());

StarPolygon star = new(x: 160, y: 100, prongs: 5, innerRadii: 42, outerRadii: 86);
Pen outline = Pens.DashDot(Color.MidnightBlue, 4);

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.Gold), star);
    canvas.Draw(outline, star);
}));

image.Save("star.png");
```

[`Paint(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.PaintExtensions) creates a canvas for each frame being processed. Drawing is recorded through that canvas and applied when the paint operation runs.

## Combine Drawing Operations

Most real compositions combine background fills, path drawing, text, image drawing, clipping, and image processors. Keep the source images and brushes alive until the `Paint(...)` call has completed because the canvas records commands first and replays them later.

```csharp
using SixLabors.Fonts;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> source = Image.Load<Rgba32>("photo.jpg");
using Image<Rgba32> image = new(640, 360, Color.White.ToPixel<Rgba32>());

Font font = SystemFonts.CreateFont("Arial", 34);
RichTextOptions titleOptions = new(font)
{
    Origin = new(40, 42),
    WrappingLength = 560,
    HorizontalAlignment = HorizontalAlignment.Center
};

EllipsePolygon focus = new(new PointF(320, 195), new SizeF(360, 190));
RectangleF photoArea = new(80, 92, 480, 230);
DrawingOptions clipToFocus = new()
{
    ShapeOptions = new()
    {
        BooleanOperation = BooleanOperation.Intersection
    }
};

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.AliceBlue));
    canvas.DrawText(titleOptions, "Clipped photo with local processing", Brushes.Solid(Color.MidnightBlue), pen: null);

    _ = canvas.Save(clipToFocus, focus);

    // DrawImage scales the selected source rectangle into the destination rectangle.
    canvas.DrawImage(source, source.Bounds, photoArea, KnownResamplers.Bicubic);
    canvas.Apply(focus, region => region.GaussianBlur(3));
    canvas.Restore();

    canvas.Draw(Pens.Solid(Color.DarkSlateBlue, 3), focus);
}));

image.Save("composition.png");
```

## Use Drawing Options

[`DrawingOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingOptions) controls the shared drawing state used by the canvas. The most common settings are graphics options for blending and antialiasing, shape options for fill behavior, and transforms for vector output.

```csharp
using System.Numerics;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(320, 200, Color.White.ToPixel<Rgba32>());

DrawingOptions options = new()
{
    GraphicsOptions = new()
    {
        Antialias = true,
        BlendPercentage = 0.85F
    },

    // Transform is applied to vector output before rasterization.
    Transform = new(Matrix3x2.CreateRotation(-0.18F, new(160, 100)))
};

EllipsePolygon shape = new(new PointF(160, 100), new SizeF(210, 96));
Brush brush = Brushes.Horizontal(Color.DeepSkyBlue, Color.Navy);

image.Mutate(ctx => ctx.Paint(options, canvas =>
{
    canvas.Fill(brush, shape);
    canvas.Draw(Pens.Solid(Color.Black, 3), shape);
}));
```

## Draw Text

Text drawing uses SixLabors.Fonts for font discovery, shaping, measurement, and layout. Use [`RichTextOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.RichTextOptions) when you draw directly to a canvas.

```csharp
using SixLabors.Fonts;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(640, 240, Color.White.ToPixel<Rgba32>());

Font font = SystemFonts.CreateFont("Arial", 42);
RichTextOptions textOptions = new(font)
{
    Origin = new(48, 70),
    WrappingLength = 540,
    HorizontalAlignment = HorizontalAlignment.Center
};

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.DrawText(textOptions, "Drawing text with ImageSharp", Brushes.Solid(Color.Black), pen: null);
}));
```

For deeper text guidance, see the [Fonts](../fonts/index.md) docs.

## Next Steps

- [Canvas Drawing](canvas.md)
- [Paths and Shapes](pathsandshapes.md)
- [Brushes and Pens](brushesandpens.md)
- [Drawing Text](text.md)
