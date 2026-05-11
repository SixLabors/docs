# Migrating from SkiaSharp

If you are coming from SkiaSharp, the biggest adjustment is the rendering model. SkiaSharp code is usually centered on an `SKCanvas` supplied by the destination you are drawing to: a bitmap, raster surface, GPU surface, document, or picture recorder. ImageSharp.Drawing works inside the ImageSharp processing pipeline and records drawing commands through [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas) before replaying them to the active backend.

That difference is useful. The same drawing code can target normal CPU-backed images, retained scenes, and WebGPU-backed surfaces while keeping the same shape, brush, pen, text, and image composition model.

## Core Type Mapping

| SkiaSharp concept | ImageSharp.Drawing equivalent |
|---|---|
| `SKBitmap` / `SKImage` / `SKSurface` | `Image<TPixel>` for CPU images, or a WebGPU surface/render target for GPU output |
| `SKCanvas` | [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas) inside [`Paint(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.PaintExtensions), or a canvas created from an image frame or backend |
| `SKPaint` fill | [`Brush`](xref:SixLabors.ImageSharp.Drawing.Processing.Brush), usually [`Brushes.Solid(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.Brushes.Solid*), gradient brushes, image brushes, or pattern brushes |
| `SKPaint` stroke | [`Pen`](xref:SixLabors.ImageSharp.Drawing.Processing.Pen), usually [`Pens.Solid(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.Pens.Solid*) or a custom `Pen` with stroke options |
| `SKColor` | `Color`, or a concrete pixel type such as `Rgba32` when working directly with pixels |
| `SKRect` / `SKRoundRect` | `Rectangle`, `RectangleF`, and shape types such as [`RectangularPolygon`](xref:SixLabors.ImageSharp.Drawing.RectangularPolygon) |
| `SKPath` | [`PathBuilder`](xref:SixLabors.ImageSharp.Drawing.PathBuilder), [`Path`](xref:SixLabors.ImageSharp.Drawing.Path), [`IPath`](xref:SixLabors.ImageSharp.Drawing.IPath), and built-in shapes such as [`EllipsePolygon`](xref:SixLabors.ImageSharp.Drawing.EllipsePolygon) |
| `SKMatrix` | `Matrix4x4` transforms, commonly constructed from `Matrix3x2` |
| `SKImageFilter` / `SKMaskFilter` | `Apply(...)` with ImageSharp processors for region-scoped effects |
| `SKTextBlob` / text drawing | [`RichTextOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.RichTextOptions), [`TextBlock`](xref:SixLabors.Fonts.TextBlock), Fonts shaping, and [`DrawText(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.DrawText*) |

## Drawing Targets and Paint Pipelines

In SkiaSharp, you draw through the `SKCanvas` provided by the current destination. A canvas backed by a raster bitmap or raster surface writes to pixels visible to the CPU. A GPU-surface canvas targets GPU work that is flushed or submitted later. A document or picture-recorder canvas records drawing commands instead of exposing writable pixels.

For simple bitmap code, that often looks like this:

SkiaSharp:

SkiaSharp positions text by baseline. Offset by ascent when you want to match a top-left drawing origin.

```csharp
using SkiaSharp;

using SKBitmap bitmap = new(420, 240);
using SKCanvas canvas = new(bitmap);
using SKPaint paint = new()
{
    Color = SKColors.CornflowerBlue,
    IsAntialias = true
};

canvas.Clear(SKColors.White);
canvas.DrawRect(SKRect.Create(40, 40, 260, 110), paint);
```

In ImageSharp.Drawing, draw inside an ImageSharp mutation pipeline:

ImageSharp.Drawing:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 240, Color.White.ToPixel<Rgba32>());

image.Mutate(context => context.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.CornflowerBlue), new Rectangle(40, 40, 260, 110));
}));
```

Use `Image.Mutate(...)` when you want to modify an existing image. Use `Image.Clone(...)` when your old SkiaSharp code created a new output from an existing source while leaving the source unchanged.

## Paint Becomes Brush and Pen

SkiaSharp uses `SKPaint` as a general drawing state object. The same type can represent fill, stroke, antialiasing, shaders, blend modes, filters, text settings, and more.

ImageSharp.Drawing splits those concepts into smaller objects:

- [`Brush`](xref:SixLabors.ImageSharp.Drawing.Processing.Brush) describes how an area is filled.
- [`Pen`](xref:SixLabors.ImageSharp.Drawing.Processing.Pen) describes how outlines are stroked.
- [`DrawingOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingOptions) controls antialiasing, transforms, blending, and shape behavior.
- [`RichTextOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.RichTextOptions) controls text layout and shaping.

SkiaSharp:

```csharp
using SkiaSharp;

using SKPaint fill = new()
{
    Color = SKColor.Parse("#2f80ed"),
    IsAntialias = true,
    Style = SKPaintStyle.Fill
};

using SKPaint stroke = new()
{
    Color = SKColor.Parse("#1b3f72"),
    IsAntialias = true,
    StrokeWidth = 4,
    Style = SKPaintStyle.Stroke
};

canvas.DrawRect(SKRect.Create(48, 42, 280, 126), fill);
canvas.DrawRect(SKRect.Create(48, 42, 280, 126), stroke);
```

ImageSharp.Drawing:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Processing;

image.Mutate(context => context.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.ParseHex("#2f80ed")), new RectangleF(48, 42, 280, 126));
    canvas.Draw(Pens.Solid(Color.ParseHex("#1b3f72"), 4), new RectangleF(48, 42, 280, 126));
}));
```

This is usually the cleanest migration path: create brushes and pens where SkiaSharp code previously configured fill and stroke paints.

## Paths and Shapes

SkiaSharp path code usually builds an `SKPath`, then fills or strokes it. ImageSharp.Drawing uses [`PathBuilder`](xref:SixLabors.ImageSharp.Drawing.PathBuilder) for incremental construction and [`IPath`](xref:SixLabors.ImageSharp.Drawing.IPath) for the finished geometry.

SkiaSharp:

```csharp
using SkiaSharp;

using SKPath triangle = new();
triangle.MoveTo(80, 180);
triangle.LineTo(160, 48);
triangle.LineTo(240, 180);
triangle.Close();

using SKPaint fill = new()
{
    Color = SKColors.Gold,
    IsAntialias = true,
    Style = SKPaintStyle.Fill
};

using SKPaint stroke = new()
{
    Color = SKColors.DarkGoldenrod,
    IsAntialias = true,
    StrokeWidth = 4,
    Style = SKPaintStyle.Stroke
};

canvas.DrawPath(triangle, fill);
canvas.DrawPath(triangle, stroke);
```

ImageSharp.Drawing:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Processing;

image.Mutate(context => context.Paint(canvas =>
{
    PathBuilder builder = new();
    builder.MoveTo(new PointF(80, 180));
    builder.LineTo(new PointF(160, 48));
    builder.LineTo(new PointF(240, 180));
    builder.CloseFigure();

    IPath triangle = builder.Build();

    canvas.Fill(Brushes.Solid(Color.Gold), triangle);
    canvas.Draw(Pens.Solid(Color.DarkGoldenrod, 4), triangle);
}));
```

For common geometry, prefer the built-in shapes instead of manually building paths:

SkiaSharp:

```csharp
using SkiaSharp;

using SKPaint fill = new()
{
    Color = SKColors.MediumSeaGreen,
    IsAntialias = true,
    Style = SKPaintStyle.Fill
};

canvas.DrawOval(SKRect.Create(70, 72, 220, 96), fill);
```

ImageSharp.Drawing:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Processing;

image.Mutate(context => context.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.MediumSeaGreen), new EllipsePolygon(180, 120, 220, 96));
}));
```

## Transforms and Canvas State

SkiaSharp commonly uses `Save()`, `Restore()`, `Translate()`, `Scale()`, and `RotateDegrees()` on the canvas. ImageSharp.Drawing exposes the same idea through canvas state and `Matrix4x4` transforms.

SkiaSharp:

```csharp
using SkiaSharp;

using SKPaint fillPaint = new()
{
    Color = SKColors.HotPink,
    IsAntialias = true,
    Style = SKPaintStyle.Fill
};

using SKPaint strokePaint = new()
{
    Color = SKColors.White,
    IsAntialias = true,
    StrokeWidth = 3,
    Style = SKPaintStyle.Stroke
};

canvas.Save();
canvas.Translate(210, 120);
canvas.Scale(1.2F, 0.8F);
canvas.DrawRect(SKRect.Create(-70, -24, 140, 48), fillPaint);
canvas.DrawRect(SKRect.Create(-70, -24, 140, 48), strokePaint);
canvas.Restore();
```

ImageSharp.Drawing:

```csharp
using System.Numerics;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Processing;

image.Mutate(context => context.Paint(canvas =>
{
    DrawingOptions options = new()
    {
        Transform = new(
            Matrix3x2.CreateScale(1.2F, 0.8F) *
            Matrix3x2.CreateTranslation(210, 120))
    };

    _ = canvas.Save(options);
    canvas.Fill(Brushes.Solid(Color.HotPink), new RectangleF(-70, -24, 140, 48));
    canvas.Draw(Pens.Solid(Color.White, 3), new RectangleF(-70, -24, 140, 48));

    canvas.Restore();
}));
```

ImageSharp.Drawing uses `Matrix4x4` because the same transform model works across CPU rendering, retained scenes, and WebGPU output. For normal 2D drawing, construct it from `Matrix3x2` so the affine values stay familiar.

## Image Composition

SkiaSharp image composition often uses `DrawImage(...)` or `DrawBitmap(...)`. In ImageSharp.Drawing, use [`DrawImage(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.DrawImage*) inside [`Paint(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.PaintExtensions) when the operation belongs with the rest of the drawing commands.

SkiaSharp:

```csharp
using SkiaSharp;

using SKBitmap source = SKBitmap.Decode("photo.jpg");
using SKBitmap output = new(640, 360);
using SKCanvas canvas = new(output);

using SKPaint strokePaint = new()
{
    Color = SKColors.White,
    IsAntialias = true,
    StrokeWidth = 4,
    Style = SKPaintStyle.Stroke
};

canvas.Clear(SKColors.White);
canvas.DrawBitmap(source, SKRect.Create(32, 32, 320, 220));
canvas.DrawRect(SKRect.Create(32, 32, 320, 220), strokePaint);
```

ImageSharp.Drawing:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> source = Image.Load<Rgba32>("photo.jpg");
using Image<Rgba32> output = new(640, 360, Color.White.ToPixel<Rgba32>());

output.Mutate(context => context.Paint(canvas =>
{
    canvas.DrawImage(source, source.Bounds, new RectangleF(32, 32, 320, 220));
    canvas.Draw(Pens.Solid(Color.White, 4), new RectangleF(32, 32, 320, 220));
}));
```

Keep source images alive until the canvas has replayed. Inside `Paint(...)`, replay is owned by the processing operation. If you create and manage a canvas yourself, dispose or flush it before disposing source images used by drawing commands.

## Region Effects

SkiaSharp often applies blur, masking, or filters through paint filters or image filters. ImageSharp.Drawing uses [`Apply(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Apply*) to run normal ImageSharp processors inside a rectangle or path.

SkiaSharp:

```csharp
using SkiaSharp;

using SKPaint shadowPaint = new()
{
    Color = SKColors.Black.WithAlpha(89),
    ImageFilter = SKImageFilter.CreateBlur(10, 10),
    IsAntialias = true,
    Style = SKPaintStyle.Fill
};

using SKPaint panelFillPaint = new()
{
    Color = SKColors.White,
    IsAntialias = true,
    Style = SKPaintStyle.Fill
};

using SKPaint panelStrokePaint = new()
{
    Color = SKColors.LightGray,
    IsAntialias = true,
    StrokeWidth = 1,
    Style = SKPaintStyle.Stroke
};

canvas.DrawRect(SKRect.Create(70, 72, 280, 110), shadowPaint);
canvas.DrawRect(SKRect.Create(62, 58, 280, 110), panelFillPaint);
canvas.DrawRect(SKRect.Create(62, 58, 280, 110), panelStrokePaint);
```

ImageSharp.Drawing:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Processing;

image.Mutate(context => context.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.Black.WithAlpha(0.35F)), new Rectangle(70, 72, 280, 110));

    // Blur a larger region so the softened shadow can spread beyond the source rectangle.
    canvas.Apply(new Rectangle(60, 62, 300, 130), region => region.GaussianBlur(10));

    canvas.Fill(Brushes.Solid(Color.White), new Rectangle(62, 58, 280, 110));
    canvas.Draw(Pens.Solid(Color.LightGray, 1), new Rectangle(62, 58, 280, 110));
}));
```

On GPU-backed canvases, `Apply(...)` may require readback into the CPU ImageSharp pipeline. Keep the affected region tight, just as you would keep Skia image filters scoped to the area that actually needs the effect.

## Text

SkiaSharp text drawing can start simple, but richer layout usually involves `SKTextBlob`, font managers, shaping, and manual measurement. ImageSharp.Drawing uses SixLabors.Fonts directly, so advanced text layout is part of the normal drawing API.

SkiaSharp:

```csharp
using SkiaSharp;

using SKTypeface typeface = SKTypeface.FromFile("Inter.ttf");
using SKFont font = new(typeface, 32);
using SKPaint paint = new()
{
    Color = SKColors.Black,
    IsAntialias = true
};

SKFontMetrics metrics;
font.GetFontMetrics(out metrics);

canvas.DrawText("Fast text layout for generated graphics", 48, 48 - metrics.Ascent, font, paint);
```

ImageSharp.Drawing:

```csharp
using SixLabors.Fonts;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Processing;

image.Mutate(context => context.Paint(canvas =>
{
    FontCollection collection = new();
    FontFamily family = collection.Add("Inter.ttf");
    Font font = family.CreateFont(32);

    RichTextOptions options = new(font)
    {
        Origin = new PointF(48, 48)
    };

    canvas.DrawText(options, "Fast text layout for generated graphics", Brushes.Solid(Color.Black), pen: null);
}));
```

For manual line flow, measurement, caret movement, or rich spans, use the Fonts docs alongside the Drawing text guide.

## Practical Migration Strategy

For most SkiaSharp migrations:

1. Move bitmap load/save work to ImageSharp.
2. Replace `SKCanvas` drawing blocks with `image.Mutate(context => context.Paint(canvas => ...))`.
3. Replace fill `SKPaint` objects with [`Brush`](xref:SixLabors.ImageSharp.Drawing.Processing.Brush) instances.
4. Replace stroke `SKPaint` objects with [`Pen`](xref:SixLabors.ImageSharp.Drawing.Processing.Pen) instances.
5. Replace `SKPath` construction with [`PathBuilder`](xref:SixLabors.ImageSharp.Drawing.PathBuilder), [`Path`](xref:SixLabors.ImageSharp.Drawing.Path), or built-in shape types.
6. Replace canvas transform calls with saved canvas state and `Matrix4x4` values constructed from `Matrix3x2`.
7. Replace image filters with `Apply(...)` where a normal ImageSharp processor gives the same effect.
8. Move text code to [`RichTextOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.RichTextOptions), [`TextBlock`](xref:SixLabors.Fonts.TextBlock), and the Fonts layout APIs when measurement or wrapping matters.

You do not need to migrate everything at once. ImageSharp.Drawing is usually easiest to adopt by moving one rendering workflow at a time: generate the same output image, replace the paint/path/text concepts with the closest Drawing equivalents, then simplify once the new model is in place.
