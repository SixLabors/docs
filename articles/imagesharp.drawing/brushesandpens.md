# Brushes and Pens

Brushes fill covered pixels. Pens define the outline generated when you stroke a path, line, or shape.

## Solid Brushes and Pens

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(320, 200, Color.White.ToPixel<Rgba32>());

image.Mutate(ctx => ctx.Paint(canvas =>
{
    Rectangle panel = new(30, 28, 140, 92);
    canvas.Fill(Brushes.Solid(Color.LightSkyBlue), panel);
    canvas.Draw(Pens.Solid(Color.Navy, 4), panel);

    EllipsePolygon ellipse = new(new PointF(230, 118), new SizeF(118, 72));
    canvas.Fill(Brushes.Solid(Color.Gold), ellipse);
    canvas.Draw(Pens.Solid(Color.DarkOrange, 5), ellipse);
}));
```

## Pattern Brushes and Pattern Pens

The `Brushes` and `Pens` factories include common hatch and dash styles.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 240, Color.White.ToPixel<Rgba32>());

Brush hatchBrush = Brushes.ForwardDiagonal(Color.DarkSlateGray.WithAlpha(0.72F), Color.Transparent);
Pen dashPen = Pens.Dash(Color.MidnightBlue, 5);
Pen dotPen = Pens.Dot(Color.Crimson, 4);
Pen dashDotPen = Pens.DashDot(Color.Black, 3);

image.Mutate(ctx => ctx.Paint(canvas =>
{
    Rectangle hatchArea = new(28, 28, 160, 138);
    canvas.Fill(hatchBrush, hatchArea);
    canvas.Draw(dashPen, hatchArea);

    canvas.DrawEllipse(dotPen, new(292, 96), new(170, 92));
    canvas.DrawLine(dashDotPen, new(38, 206), new(150, 178), new(264, 210), new(382, 172));
}));
```

Pattern pens can also use a brush as their stroke fill, which is useful for gradient or hatch-pattern outlines.

Dash patterns are expressed as multiples of the pen width. The pattern `[3F, 1F]` means draw for three stroke widths, skip for one stroke width, then repeat.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 180, Color.White.ToPixel<Rgba32>());

PenOptions customDashOptions = new(Brushes.Solid(Color.DarkSlateBlue), 8, [4F, 1F, 1F, 1F])
{
    StrokeOptions = new()
    {
        LineCap = LineCap.Round,
        LineJoin = LineJoin.Round
    }
};

PatternPen customDash = new(customDashOptions);

PathBuilder builder = new();
builder.AddCubicBezier(new(32, 120), new(118, 18), new(286, 24), new(388, 132));

image.Mutate(ctx => ctx.Paint(canvas =>
{

    // The dash array is measured relative to the pen width.
    canvas.Draw(customDash, builder.Build());
}));
```

## Gradient Brushes

Gradient brushes shade fills across space. Use color stops to describe the gradient ramp.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 240, Color.White.ToPixel<Rgba32>());

LinearGradientBrush linear = new(
    new(24, 24),
    new(220, 150),
    GradientRepetitionMode.None,
    new(0F, Color.LightYellow),
    new(0.5F, Color.DeepSkyBlue),
    new(1F, Color.MediumBlue));

RadialGradientBrush radial = new(
    new(306, 116),
    82F,
    GradientRepetitionMode.Reflect,
    new(0F, Color.Orange),
    new(1F, Color.MediumVioletRed.WithAlpha(0.25F)));

EllipsePolygon radialShape = new(new PointF(306, 116), new SizeF(156, 112));

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(linear, new Rectangle(24, 24, 190, 132));
    canvas.Fill(radial, radialShape);
}));
```

## Image and Matrix Pattern Brushes

`PatternBrush` repeats a matrix of foreground/background values across the target. Use the `Brushes` helpers for common hatch styles, or construct a `PatternBrush` when you need a custom repeating matrix.

`ImageBrush<TPixel>` uses an image as the brush source. The source image is not disposed by the brush, so keep it alive for as long as the canvas might replay commands that reference it.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> tile = new(24, 24, Color.Transparent.ToPixel<Rgba32>());
tile.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.LightYellow));
    canvas.DrawLine(Pens.Solid(Color.DarkGoldenrod, 3), new PointF(0, 24), new PointF(24, 0));
}));

using Image<Rgba32> image = new(420, 220, Color.White.ToPixel<Rgba32>());

ImageBrush<Rgba32> imageBrush = new(tile, new RectangleF(0, 0, 24, 24), new Point(0, 0));
PatternBrush matrixBrush = new(
    Color.DarkSlateGray.WithAlpha(0.75F),
    Color.Transparent,
    new bool[,]
    {
        { true, false, false, false },
        { false, true, false, false },
        { false, false, true, false },
        { false, false, false, true }
    });

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(imageBrush, new Rectangle(28, 28, 160, 132));
    canvas.Fill(matrixBrush, new Rectangle(232, 28, 160, 132));
}));
```

## Stroke Shape Options

`StrokeOptions` controls how outlines are generated before rasterization.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 220, Color.White.ToPixel<Rgba32>());

StrokeOptions strokeOptions = new()
{
    LineJoin = LineJoin.Round,
    LineCap = LineCap.Round,
    MiterLimit = 4,
    ArcDetailScale = 1
};

PenOptions penOptions = new(Brushes.Solid(Color.MidnightBlue), 12, strokePattern: null)
{
    StrokeOptions = strokeOptions
};

SolidPen pen = new(penOptions);

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.DrawLine(pen, new(40, 170), new(130, 42), new(250, 166), new(374, 54));
}));
```

Pens do not paint centered pixels directly. A pen describes an outline generated from the source path, line, or shape. The generated outline is then filled with the pen's brush. This is why caps, joins, miter limits, dashes, and stroke width belong to the pen.

Use `Pen.GeneratePath(...)` when you need to inspect or reuse the stroked outline as a shape.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 220, Color.White.ToPixel<Rgba32>());

PathBuilder builder = new();
builder.AddLine(new(52, 164), new(178, 44));
builder.AddLine(new(178, 44), new(328, 166));

IPath centerLine = builder.Build();
Pen outlinePen = Pens.Solid(Color.MediumVioletRed, 18);
IPath outline = outlinePen.GeneratePath(centerLine);

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.Pink.WithAlpha(0.45F)), outline);
    canvas.Draw(Pens.Solid(Color.DarkRed, 2), outline);
    canvas.Draw(Pens.Dash(Color.Gray, 1.5F), centerLine);
}));
```

## Clipping Brushes and Pens

Clipping is canvas state, not a brush or pen property. Use `Save(DrawingOptions, params IPath[])` to apply one or more clip paths to later brush and pen commands, then `Restore()` when the clipped work is complete.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 240, Color.White.ToPixel<Rgba32>());

EllipsePolygon clip = new(new PointF(210, 120), new SizeF(300, 150));
LinearGradientBrush brush = new(
    new PointF(40, 40),
    new PointF(380, 200),
    GradientRepetitionMode.None,
    new ColorStop(0F, Color.Gold),
    new ColorStop(1F, Color.MediumPurple));
DrawingOptions clipInside = new()
{
    ShapeOptions = new()
    {
        BooleanOperation = BooleanOperation.Intersection
    }
};

image.Mutate(ctx => ctx.Paint(canvas =>
{
    _ = canvas.Save(clipInside, clip);

    // Both the fill and the dashed outline are clipped by the saved canvas state.
    canvas.Fill(brush, new Rectangle(32, 34, 356, 172));
    canvas.Draw(Pens.Dash(Color.Black, 5), new Rectangle(32, 34, 356, 172));
    canvas.Restore();

    canvas.Draw(Pens.Solid(Color.DarkSlateGray, 2), clip);
}));
```
