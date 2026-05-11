# Getting Started

ImageSharp.Drawing adds high-performance vector drawing, brush and pen styling, image composition, and text rendering to ImageSharp. It is designed for generated graphics where the image pipeline and drawing pipeline need to work together: badges, charts, thumbnails, watermarks, annotations, documents, server-side render output, and GPU-backed drawing targets.

The main workflow is:

1. Create or load an `Image`.
2. Call `Mutate(...)`.
3. Use [`Paint(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.PaintExtensions) to receive a [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas).
4. Draw onto the canvas with brushes, pens, paths, shapes, images, or text.

The same canvas can mix all of those operations. The important idea is that drawing is recorded through [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas) in the order you call it, then replayed into the current frame. That replay model lets the library share the same public drawing code across CPU images, retained backend scenes, and WebGPU targets.

## Draw a Shape

Start with geometry, then choose how it is painted. Built-in shapes such as [`StarPolygon`](xref:SixLabors.ImageSharp.Drawing.StarPolygon), [`RectanglePolygon`](xref:SixLabors.ImageSharp.Drawing.RectanglePolygon), and [`EllipsePolygon`](xref:SixLabors.ImageSharp.Drawing.EllipsePolygon) are reusable geometry objects. A brush fills the area covered by the shape, and a pen generates and fills the stroke outline.

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

[`Paint(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.PaintExtensions) creates a canvas for each frame being processed. Drawing is recorded through that canvas, and the canvas is disposed by the paint processor after your callback returns. That disposal step replays the recorded timeline into the frame.

## Combine Drawing Operations

Most real compositions combine background fills, path drawing, text, image drawing, clipping, and image processors. Keep those concerns separate in the code: geometry decides where drawing can happen, brushes and pens decide how pixels are produced, text options decide layout, and canvas state decides which later commands are clipped, transformed, blended, or processed.

Keep source images, image brushes, fonts, and reusable paths alive until the `Paint(...)` call has completed because the canvas records commands first and replays them later. The `Apply(...)` call in this example is also a replay barrier: it processes the pixels produced by earlier commands and does not include drawing that happens later.

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

EllipsePolygon focus = new(320, 195, 360, 190);
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

[`DrawingOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingOptions) controls the shared drawing state used by the canvas. It is not a brush, pen, or shape; it is the context used to interpret later commands. `GraphicsOptions` controls edge coverage and pixel composition, `ShapeOptions` controls fill and clip behavior, and `Transform` moves vector output from local coordinates into final canvas coordinates.

Pass options to `Paint(...)` when the whole callback should use that state. Use `Save(options)` and `Restore()` when only part of the drawing should use it.

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

Brush brush = Brushes.Horizontal(Color.DeepSkyBlue, Color.Navy);

image.Mutate(ctx => ctx.Paint(options, canvas =>
{
    canvas.FillEllipse(brush, new(160, 100), new(210, 96));
    canvas.DrawEllipse(Pens.Solid(Color.Black, 3), new(160, 100), new(210, 96));
}));
```

## Draw Text

Text drawing uses SixLabors.Fonts for font discovery, shaping, measurement, and layout. Use [`RichTextOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.RichTextOptions) when you draw directly to a canvas. The options are the text layout contract: font, origin, wrapping, alignment, fallback, culture, and rich runs should be the same when measuring and drawing.

Prefer layout options over manual width subtraction. Wrapping and alignment let the text engine account for line height, glyph metrics, shaping, and fallback fonts, which manual coordinate guesses cannot do reliably.

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

## Practical Guidance

- Keep reusable geometry, pens, brushes, fonts, and source images alive until `Paint(...)` completes.
- Create drawing options for the state you want to scope, then use `Save(...)` and `Restore()` around that scope.
- Use `Apply(...)` after the commands whose pixels should be processed.
- Move from primitive helpers to reusable paths when the same geometry drives more than one command.
