# Migrating from System.Drawing

If you are coming from `System.Drawing`, the biggest adjustment is moving from a `Graphics` object over a `Bitmap` to an ImageSharp image pipeline with [`Paint(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.PaintExtensions) and [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas).

The drawing concepts still map cleanly. `Graphics` becomes [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas), `Brush` and `Pen` become ImageSharp.Drawing brushes and pens, `GraphicsPath` becomes [`PathBuilder`](xref:SixLabors.ImageSharp.Drawing.PathBuilder) or [`IPath`](xref:SixLabors.ImageSharp.Drawing.IPath), and text moves to the Fonts-powered [`DrawText(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.DrawText*) APIs.

Treat migration as a behavior-matching exercise first. Keep the same image size, geometry, colors, alpha, transform order, clipping behavior, and font choice while translating the API shape. Once the output is equivalent, simplify the ImageSharp.Drawing code to use higher-level shapes, text layout, and image processing where they make the intent clearer.

For core image loading, saving, pixel formats, and raw pixel access, see the ImageSharp [Migrating from System.Drawing](../imagesharp/migratingfromsystemdrawing.md) guide. This page focuses on drawing code.

## Core Type Mapping

| `System.Drawing` concept | ImageSharp.Drawing equivalent |
|---|---|
| `Bitmap` | `Image<TPixel>` |
| `Graphics` | [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas) inside [`Paint(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.PaintExtensions), or a canvas created from an image frame |
| `System.Drawing.Color` | `SixLabors.ImageSharp.Color`, or a concrete pixel type such as `Rgba32` |
| `SolidBrush` / `TextureBrush` | `Brushes.Solid(...)`, image brushes, pattern brushes, gradient brushes |
| `Pen` | [`SixLabors.ImageSharp.Drawing.Processing.Pen`](xref:SixLabors.ImageSharp.Drawing.Processing.Pen), usually through [`Pens.Solid(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.Pens.Solid*) |
| `Rectangle` / `RectangleF` | `Rectangle` for rectangle fill, stroke, and clear helpers; `RectangleF` for APIs that explicitly accept floating-point bounds such as image destination rectangles |
| `GraphicsPath` | [`PathBuilder`](xref:SixLabors.ImageSharp.Drawing.PathBuilder), [`Path`](xref:SixLabors.ImageSharp.Drawing.Path), [`IPath`](xref:SixLabors.ImageSharp.Drawing.IPath), and built-in shape types when geometry must be reused |
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

Use `Mutate(...)` when you want to update an image in place. Use `Clone(...)` when the old code created a separate output bitmap while keeping the source unchanged. The `Paint(...)` processor owns the canvas lifetime for this common case: commands recorded inside the callback are replayed into the image at the correct point in the ImageSharp processing pipeline.

## Brushes and Pens

`System.Drawing` separates filled shapes and stroked outlines through `Brush` and `Pen`. ImageSharp.Drawing keeps the same drawing vocabulary, but the objects belong to the ImageSharp.Drawing pipeline rather than the GDI+ object model.

A brush supplies color, gradient, pattern, or image samples for covered pixels. A pen describes how to turn a source line, path, or shape into stroke geometry: width, dash pattern, joins, caps, and miter behavior all affect that generated outline. The generated outline is then filled by the pen brush. That distinction matters when migrating dashed strokes, image-filled outlines, or paths where cap and join behavior changes the visible shape.

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
    canvas.Fill(Brushes.Solid(Color.FromPixel(new Rgba32(47, 128, 237, 255))), new Rectangle(48, 42, 280, 126));
    canvas.Draw(Pens.Solid(Color.FromPixel(new Rgba32(27, 63, 114, 255)), 4), new Rectangle(48, 42, 280, 126));
}));
```

## Paths and Shapes

`GraphicsPath` maps to [`PathBuilder`](xref:SixLabors.ImageSharp.Drawing.PathBuilder) when you are constructing custom geometry. Build the path in the same coordinate space as the original `GraphicsPath`, then fill or stroke it with ImageSharp.Drawing brushes and pens.

Keep open and closed figures deliberate. A closed figure represents an area boundary, so fill rules, joins, and holes are part of the shape contract. An open figure is usually a stroke path, where caps and joins define the visible ends and corners. For direct migrations of simple rectangles, ellipses, arcs, pies, lines, and Beziers, prefer the canvas helpers. Rectangles use `Fill(brush, Rectangle)` and `Draw(pen, Rectangle)` overloads; ellipses, arcs, pies, lines, and Beziers have named helpers. Use shape objects such as `EllipsePolygon`, `RectanglePolygon`, or custom paths when the geometry is reused for fill, stroke, clipping, measurement, or composition.

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

For common one-off geometry, use the canvas helpers that match the `Graphics` method you are replacing:

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
    // ImageSharp.Drawing ellipse helpers take center and size, not top-left bounds.
    canvas.FillEllipse(Brushes.Solid(Color.MediumSeaGreen), new(180, 120), new(220, 96));
}));
```

Use an explicit polygon when the ellipse is part of the drawing model rather than a one-off command. For example, clipping needs an `IPath`, so `new EllipsePolygon(...)` is the right shape for the clipping example below.

## Transforms and Canvas State

`System.Drawing.Graphics` stores transform state on the `Graphics` object. ImageSharp.Drawing stores transform state in [`DrawingOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingOptions), which can be saved onto the canvas state stack.

Translate transform code by preserving operation order. The transformed coordinate system affects subsequent fills, strokes, text, clips, and image placement until the saved state is restored. ImageSharp.Drawing uses `Matrix4x4` for canvas state so the same model can represent 2D affine and projective transforms across CPU and GPU backends; for normal migration work, build the value from `Matrix3x2` so the six affine numbers stay familiar.

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
    canvas.Fill(Brushes.Solid(Color.HotPink), new Rectangle(-70, -24, 140, 48));
    canvas.Draw(Pens.Solid(Color.White, 3), new Rectangle(-70, -24, 140, 48));

    canvas.Restore();
}));
```

ImageSharp.Drawing uses `Matrix4x4` for canvas transforms so the same drawing state can represent normal 2D affine transforms and projective transforms. For normal 2D drawing, construct it from `Matrix3x2`.

## Image Composition

If your `System.Drawing` code uses `Graphics.DrawImage(...)`, use `DrawImage(...)` inside `Paint(...)` when the image placement belongs with the rest of the drawing commands.

Keep source and destination rectangles explicit. The source rectangle selects pixels from the input image; the destination rectangle defines where those pixels land on the canvas. If you do not pass a resampler, ImageSharp.Drawing uses the drawing API default, which is the right choice for ordinary image placement. Choose a specific resampler only when the migration requires a known sampling policy.

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
    canvas.Draw(Pens.Solid(Color.White, 4), new Rectangle(32, 32, 320, 220));
}));
```

Keep source images alive until the canvas has replayed. Inside `Paint(...)`, replay is owned by the processing operation. If you create and manage a canvas yourself, dispose it before disposing source images used by drawing commands.

## Clipping

`Graphics.SetClip(...)` maps to saving canvas state with clip paths. Restore the state when the clipped drawing is complete.

For equivalent `SetClip(...)` behavior, use `BooleanOperation.Intersection`. ImageSharp.Drawing clip paths are combined through [`ShapeOptions.BooleanOperation`](xref:SixLabors.ImageSharp.Drawing.Processing.ShapeOptions.BooleanOperation), and the default operation is not the same as intersecting the current drawing area with the supplied clip.

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
    DrawingOptions clipInside = new()
    {
        ShapeOptions = new()
        {
            BooleanOperation = BooleanOperation.Intersection
        }
    };

    // SetClip-style behavior keeps only the intersection with the ellipse.
    _ = canvas.Save(clipInside, new EllipsePolygon(190, 120, 260, 160));
    canvas.Fill(Brushes.Solid(Color.CornflowerBlue), new Rectangle(20, 20, 360, 200));

    canvas.Restore();
}));
```

## Text

`Graphics.DrawString(...)` handles simple text drawing. ImageSharp.Drawing uses SixLabors.Fonts through `DrawText(...)`, so wrapping, alignment, shaping, fallback, and rich text options are part of the normal text pipeline.

Use the same font file and layout rectangle when checking output parity. `RichTextOptions.Origin` is the anchor used by the layout options, `WrappingLength` defines the available line width, `TextAlignment` aligns lines within that wrapping width, and `HorizontalAlignment` / `VerticalAlignment` place the laid-out block relative to the origin. This keeps text positioning declarative instead of relying on manual string measurement.

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

## Practical Guidance

- Keep source and destination geometry equivalent while translating examples.
- Replace `Graphics` state with explicit canvas `Save(...)` and `Restore()` scopes.
- Use ImageSharp.Drawing brushes and pens instead of carrying `System.Drawing` object lifetimes across.
- Move text layout decisions into `RichTextOptions` and Fonts APIs rather than manually positioning strings.
- Validate output on non-Windows environments if the migration goal is cross-platform rendering.
