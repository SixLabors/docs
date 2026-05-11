# Migrating from System.Drawing

If you are coming from `System.Drawing`, the biggest adjustment is moving from a `Graphics` object over a `Bitmap` to an ImageSharp image pipeline with [`Paint(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.PaintExtensions) and [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas).

The drawing concepts still map cleanly. `Graphics` becomes [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas), `Brush` and `Pen` become ImageSharp.Drawing brushes and pens, `GraphicsPath` becomes [`PathBuilder`](xref:SixLabors.ImageSharp.Drawing.PathBuilder) or [`IPath`](xref:SixLabors.ImageSharp.Drawing.IPath), and text moves to the Fonts-powered [`DrawText(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.DrawText*) APIs.

For core image loading, saving, pixel formats, and raw pixel access, see the ImageSharp [Migrating from System.Drawing](../imagesharp/migratingfromsystemdrawing.md) guide. This page focuses on drawing code.

## Core Type Mapping

| `System.Drawing` concept | ImageSharp.Drawing equivalent |
|---|---|
| `Bitmap` | `Image<TPixel>` |
| `Graphics` | [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas) inside [`Paint(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.PaintExtensions), or a canvas created from an image frame |
| `System.Drawing.Color` | `SixLabors.ImageSharp.Color`, or a concrete pixel type such as `Rgba32` |
| `SolidBrush` / `TextureBrush` | `Brushes.Solid(...)`, image brushes, pattern brushes, gradient brushes |
| `Pen` | [`SixLabors.ImageSharp.Drawing.Processing.Pen`](xref:SixLabors.ImageSharp.Drawing.Processing.Pen), usually through [`Pens.Solid(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.Pens.Solid*) |
| `Rectangle` / `RectangleF` | `Rectangle` / `RectangleF` |
| `GraphicsPath` | [`PathBuilder`](xref:SixLabors.ImageSharp.Drawing.PathBuilder), [`Path`](xref:SixLabors.ImageSharp.Drawing.Path), [`IPath`](xref:SixLabors.ImageSharp.Drawing.IPath), and built-in shape types |
| `Matrix` | `Matrix4x4`, commonly constructed from `Matrix3x2` |
| `Graphics.DrawImage(...)` | `DrawingCanvas.DrawImage(...)` |
| `Graphics.DrawString(...)` | [`DrawingCanvas.DrawText(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.DrawText*) with [`RichTextOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.RichTextOptions) |

## Graphics vs Paint Pipelines

In `System.Drawing`, drawing usually starts by creating a `Graphics` object from a `Bitmap`:

System.Drawing:

```csharp
using System.Drawing;

using Bitmap bitmap = new(420, 240);
using Graphics graphics = Graphics.FromImage(bitmap);
using SolidBrush brush = new(Color.CornflowerBlue);

graphics.Clear(Color.White);
graphics.FillRectangle(brush, new Rectangle(40, 40, 260, 110));
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

Use `Mutate(...)` when you want to update an image in place. Use `Clone(...)` when the old code created a separate output bitmap while keeping the source unchanged.

## Brushes and Pens

`System.Drawing` separates filled shapes and stroked outlines through `Brush` and `Pen`. ImageSharp.Drawing keeps the same mental model, but uses its own brush and pen types.

System.Drawing:

```csharp
using System.Drawing;

using SolidBrush fill = new(Color.FromArgb(255, 47, 128, 237));
using Pen stroke = new(Color.FromArgb(255, 27, 63, 114), 4);

graphics.FillRectangle(fill, new RectangleF(48, 42, 280, 126));
graphics.DrawRectangle(stroke, 48, 42, 280, 126);
```

ImageSharp.Drawing:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

image.Mutate(context => context.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.FromPixel(new Rgba32(47, 128, 237, 255))), new RectangleF(48, 42, 280, 126));
    canvas.Draw(Pens.Solid(Color.FromPixel(new Rgba32(27, 63, 114, 255)), 4), new RectangleF(48, 42, 280, 126));
}));
```

## Paths and Shapes

`GraphicsPath` maps to [`PathBuilder`](xref:SixLabors.ImageSharp.Drawing.PathBuilder) when you are constructing custom geometry. For simple rectangles, ellipses, arcs, and lines, prefer the built-in Drawing helpers and shape types.

System.Drawing:

```csharp
using System.Drawing;
using System.Drawing.Drawing2D;

using GraphicsPath triangle = new();
triangle.StartFigure();
triangle.AddLine(80, 180, 160, 48);
triangle.AddLine(160, 48, 240, 180);
triangle.CloseFigure();

using SolidBrush fill = new(Color.Gold);
using Pen stroke = new(Color.DarkGoldenrod, 4);

graphics.FillPath(fill, triangle);
graphics.DrawPath(stroke, triangle);
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

For common geometry, use shape types directly:

System.Drawing:

```csharp
using System.Drawing;

using SolidBrush fill = new(Color.MediumSeaGreen);

graphics.FillEllipse(fill, new RectangleF(70, 72, 220, 96));
```

ImageSharp.Drawing:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Processing;

image.Mutate(context => context.Paint(canvas =>
{
    // EllipsePolygon takes center and size; this matches the System.Drawing bounds above.
    canvas.Fill(Brushes.Solid(Color.MediumSeaGreen), new EllipsePolygon(180, 120, 220, 96));
}));
```

## Transforms and Canvas State

`System.Drawing.Graphics` stores transform state on the `Graphics` object. ImageSharp.Drawing stores transform state in [`DrawingOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingOptions), which can be saved onto the canvas state stack.

System.Drawing:

```csharp
using System.Drawing;
using System.Drawing.Drawing2D;

using SolidBrush fill = new(Color.HotPink);
using Pen stroke = new(Color.White, 3);
using Matrix transform = new(1.2F, 0, 0, 0.8F, 210, 120);

GraphicsState state = graphics.Save();
graphics.Transform = transform;
graphics.FillRectangle(fill, new RectangleF(-70, -24, 140, 48));
graphics.DrawRectangle(stroke, -70, -24, 140, 48);
graphics.Restore(state);
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

ImageSharp.Drawing uses `Matrix4x4` for canvas transforms so the same drawing state can represent normal 2D affine transforms and projective transforms. For normal 2D drawing, construct it from `Matrix3x2`.

## Image Composition

If your `System.Drawing` code uses `Graphics.DrawImage(...)`, use `DrawImage(...)` inside `Paint(...)` when the image placement belongs with the rest of the drawing commands.

System.Drawing:

```csharp
using System.Drawing;

using Bitmap source = new("photo.jpg");
using Bitmap output = new(640, 360);
using Graphics graphics = Graphics.FromImage(output);

using Pen stroke = new(Color.White, 4);

graphics.Clear(Color.White);
graphics.DrawImage(source, new RectangleF(32, 32, 320, 220));
graphics.DrawRectangle(stroke, 32, 32, 320, 220);
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

## Clipping

`Graphics.SetClip(...)` maps to saving canvas state with clip paths. Restore the state when the clipped drawing is complete.

System.Drawing:

```csharp
using System.Drawing;
using System.Drawing.Drawing2D;

using GraphicsPath clip = new();
clip.AddEllipse(60, 40, 260, 160);

GraphicsState state = graphics.Save();
graphics.SetClip(clip);
graphics.FillRectangle(Brushes.CornflowerBlue, new Rectangle(20, 20, 360, 200));
graphics.Restore(state);
```

ImageSharp.Drawing:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Processing;

image.Mutate(context => context.Paint(canvas =>
{
    _ = canvas.Save(new DrawingOptions(), new EllipsePolygon(190, 120, 260, 160));
    canvas.Fill(Brushes.Solid(Color.CornflowerBlue), new Rectangle(20, 20, 360, 200));

    canvas.Restore();
}));
```

## Text

`Graphics.DrawString(...)` handles simple text drawing. ImageSharp.Drawing uses SixLabors.Fonts through `DrawText(...)`, so wrapping, alignment, shaping, fallback, and rich text options are part of the normal text pipeline.

System.Drawing:

```csharp
using System.Drawing;
using System.Drawing.Text;

using PrivateFontCollection collection = new();
collection.AddFontFile("Inter.ttf");

using Font font = new(collection.Families[0], 32);
using StringFormat format = new()
{
    Alignment = StringAlignment.Center
};

graphics.DrawString(
    "Fast text layout for generated graphics",
    font,
    Brushes.Black,
    new RectangleF(48, 48, 320, 120),
    format);

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
        Origin = new PointF(48, 48),
        WrappingLength = 320,
        HorizontalAlignment = HorizontalAlignment.Center
    };

    canvas.DrawText(options, "Fast text layout for generated graphics", Brushes.Solid(Color.Black), pen: null);
}));
```

## Practical Migration Strategy

For most `System.Drawing` drawing migrations:

1. Move bitmap load/save work to ImageSharp.
2. Replace `Graphics.FromImage(...)` blocks with `image.Mutate(context => context.Paint(canvas => ...))`.
3. Replace `SolidBrush`, `TextureBrush`, and gradient brushes with ImageSharp.Drawing brushes.
4. Replace `System.Drawing.Pen` with `Pens.Solid(...)` or a custom ImageSharp.Drawing pen.
5. Replace `GraphicsPath` with [`PathBuilder`](xref:SixLabors.ImageSharp.Drawing.PathBuilder), [`Path`](xref:SixLabors.ImageSharp.Drawing.Path), or built-in shape types.
6. Replace `Graphics` transform state with saved canvas state and `Matrix4x4` values constructed from `Matrix3x2`.
7. Replace `SetClip(...)` with `Save(options, clipPaths)` and `Restore()`.
8. Replace `DrawString(...)` with [`DrawText(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.DrawText*), [`RichTextOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.RichTextOptions), and the Fonts layout APIs when wrapping or shaping matters.

You do not have to migrate all drawing code at once. Start with one rendering workflow, match the output, then simplify the code once the ImageSharp.Drawing model is in place.
