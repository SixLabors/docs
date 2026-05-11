# Brushes and Pens

Brushes and pens separate *coverage* from *style*. A shape, path, text glyph, or generated stroke decides which pixels are covered. The brush then shades those covered pixels using a solid color, gradient, repeated pattern, image tile, or other brush source.

Pens are built on top of brushes. A pen does not directly paint a centerline; it expands the source line, path, or shape into stroke geometry using the pen width, caps, joins, miter limit, and dash pattern. That generated outline is then filled with the pen's brush. This matters when you debug output: stroke shape problems belong to `StrokeOptions`, while color, gradient, hatch, and image-fill problems belong to the brush.

Brushes and pens are recorded as part of canvas drawing intent, so keep any referenced resources alive until the canvas has replayed. This is especially important for `ImageBrush<TPixel>`, which references the source image rather than taking ownership of it.

## Solid Brushes and Pens

Solid brushes and solid pens are the simplest styling objects. Use them for flat fills, outlines, guides, and most annotation work. The same brush can be used directly in `Fill(...)` or as the fill used by a pen stroke.

The pen width is expressed in the path's local coordinate space before the active drawing transform is applied. If you save a scaled transform on the canvas, the stroke geometry is prepared with that state during replay, so a scaled drawing state can scale the visible stroke as well as the path.

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

    canvas.FillEllipse(Brushes.Solid(Color.Gold), new(230, 118), new(118, 72));
    canvas.DrawEllipse(Pens.Solid(Color.DarkOrange, 5), new(230, 118), new(118, 72));
}));
```

## Pattern Brushes and Pattern Pens

Pattern brushes are small repeating color matrices. The built-in hatch helpers on [`Brushes`](xref:SixLabors.ImageSharp.Drawing.Processing.Brushes) create common foreground/background matrices such as horizontal, vertical, diagonal, and percentage patterns. Use a transparent background when the pattern should sit over existing pixels, or pass an opaque background color when the pattern should fully cover the area.

Pattern pens combine the same stroke-generation model as other pens with a dash pattern. [`Pens.Dash(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.Pens.Dash*), [`Pens.Dot(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.Pens.Dot*), [`Pens.DashDot(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.Pens.DashDot*), and [`Pens.DashDotDot(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.Pens.DashDotDot*) are convenience factories for the common sequences. Pass a brush instead of a color when the stroke itself should be filled with a gradient, hatch, or image pattern.

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

Gradient brushes shade covered pixels from positions in canvas space. The color stops describe the ramp, and the brush geometry describes how that ramp is mapped into the drawn area. A linear gradient moves along a line between two points. A radial gradient expands from a center point and radius. Repetition mode controls what happens outside the primary gradient span: clamp to the edge colors, repeat the ramp, or reflect it.

Because the brush is evaluated over the covered pixels, the same gradient can be reused across several shapes to make them appear lit by one continuous source. If each shape needs its own independent gradient, create a brush whose points and radius match that shape instead of sharing one global brush.

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

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(linear, new Rectangle(24, 24, 190, 132));
    canvas.FillEllipse(radial, new(306, 116), new(156, 112));
}));
```

## Image and Matrix Pattern Brushes

[`PatternBrush`](xref:SixLabors.ImageSharp.Drawing.Processing.PatternBrush) repeats a matrix of foreground/background values across the target. Use the [`Brushes`](xref:SixLabors.ImageSharp.Drawing.Processing.Brushes) helpers for common hatch styles, or construct a [`PatternBrush`](xref:SixLabors.ImageSharp.Drawing.Processing.PatternBrush) when you need a custom repeating matrix.

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

`StrokeOptions` controls the geometry produced before the pen's brush is applied. `LineCap` affects the ends of open paths and line segments. `LineJoin` affects corners where segments meet. `MiterLimit` limits how far sharp miter joins can extend before the join falls back to a bevel-style shape. `ArcDetailScale` controls the detail used when rounded joins and caps are converted into geometry.

Use stroke options when the outline itself is wrong: squared ends, overly sharp corners, clipped-looking miters, or rounded joins that need more detail. Use a different brush when the outline shape is correct but the stroke color, gradient, pattern, or image fill is wrong.

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

EllipsePolygon clip = new(210, 120, 300, 150);
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

## Practical Guidance

Brushes and pens answer different questions. A brush shades covered pixels. A pen describes how a stroke outline is generated and how that outline is filled. Keeping that distinction clear prevents a lot of awkward geometry code: cap, join, miter, dash, and stroke-width decisions belong on the pen, not in hand-built outline paths.

Create reusable pens and brushes when the same style appears across many commands. That keeps examples readable and production drawing code easier to audit. Use canvas clipping state when a style should be constrained to a region; clipping is part of drawing state, not something each brush or pen needs to know about.
