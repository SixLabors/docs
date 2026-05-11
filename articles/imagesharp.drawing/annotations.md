# Add Callouts and Annotations

Annotations are overlays that explain or identify parts of an existing image. In ImageSharp.Drawing they are built from the same primitives as any other drawing: fills, strokes, text, lines, clips, and regions. The useful part is not the style; it is the workflow for keeping annotation geometry tied to the pixels it describes.

An annotation usually has three pieces:

- a target region in image coordinates;
- a visual marker such as a fill, outline, arrow, or leader line;
- a label laid out in a predictable rectangle.

Compute those pieces after the image has the size and orientation that will be exported. If you resize, crop, or auto-orient after drawing annotations, the overlay will be transformed with the pixels and may no longer point at the intended feature.

## Coordinate Workflow

Keep annotation geometry in final image coordinates. If the target was detected in source-image coordinates, map it after any crop, resize, or orientation step before drawing.

```csharp
using SixLabors.ImageSharp;

static Rectangle ScaleRectangle(Rectangle source, Size sourceSize, Size destinationSize)
{
    float scaleX = (float)destinationSize.Width / sourceSize.Width;
    float scaleY = (float)destinationSize.Height / sourceSize.Height;

    return new Rectangle(
        (int)MathF.Round(source.X * scaleX),
        (int)MathF.Round(source.Y * scaleY),
        (int)MathF.Round(source.Width * scaleX),
        (int)MathF.Round(source.Height * scaleY));
}
```

Use the same mapping for every point that belongs to the annotation: highlight bounds, leader start, leader end, label origin, and panel bounds. That keeps the annotation coherent when the output size changes.

## Highlight a Region

A rectangular highlight is the simplest annotation. Fill the target with a translucent brush, then stroke the same rectangle so the boundary is clear.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = Image.Load<Rgba32>("photo.jpg");

Rectangle regionOfInterest = new(92, 64, 220, 140);

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.Gold.WithAlpha(0.22F)), regionOfInterest);
    canvas.Draw(Pens.Dash(Color.Gold, 5), regionOfInterest);
}));

image.Save("highlighted.jpg");
```

Use a rectangle overload when the marker is just a one-off rectangular highlight. Use a reusable path or polygon when the same geometry must be filled, stroked, clipped, measured, or passed through a geometry operation.

## Add a Leader and Label

Labels are normal text drawing. Use [`RichTextOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.RichTextOptions) so wrapping and placement are explicit. Use a text stroke when the label must remain readable over arbitrary image content.

```csharp
using SixLabors.Fonts;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = Image.Load<Rgba32>("photo.jpg");

Rectangle target = new(92, 64, 220, 140);
PointF targetEdge = new(target.Right, target.Top + (target.Height / 2F));
PointF labelOrigin = new(target.Right + 28, target.Top + 12);
Font font = SystemFonts.CreateFont("Arial", 24, FontStyle.Bold);
RichTextOptions labelOptions = new(font)
{
    Origin = labelOrigin,
    WrappingLength = 220
};

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.Gold.WithAlpha(0.22F)), target);
    canvas.Draw(Pens.Dash(Color.Gold, 5), target);

    // The leader line connects the label to the target in the same image coordinate system.
    canvas.DrawLine(
        Pens.Solid(Color.Gold, 3),
        new PointF(labelOrigin.X - 12, labelOrigin.Y + 12),
        targetEdge);

    // The outline pen makes the text readable over mixed light and dark pixels.
    canvas.DrawText(
        labelOptions,
        "Region of interest",
        Brushes.Solid(Color.White),
        Pens.Solid(Color.Black, 1.5F));
}));

image.Save("annotated.jpg");
```

Draw the leader before the label so the label remains crisp and unobstructed. When a label can contain user-supplied text, set `WrappingLength` and choose an origin that leaves room for multiple lines.

## Use a Local Panel Region

When a callout contains several items, use [`CreateRegion(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.CreateRegion*) so the panel has local coordinates. The parent canvas still uses image coordinates; the child region uses `(0, 0)` at the panel origin.

```csharp
using SixLabors.Fonts;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = Image.Load<Rgba32>("photo.jpg");

Rectangle target = new(92, 64, 220, 140);
Rectangle panelBounds = new(348, 52, 260, 116);
Font titleFont = SystemFonts.CreateFont("Arial", 22, FontStyle.Bold);
Font bodyFont = SystemFonts.CreateFont("Arial", 16);

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Draw(Pens.Solid(Color.Gold, 4), target);
    canvas.DrawLine(
        Pens.Solid(Color.Gold, 3),
        new PointF(target.Right, target.Top + (target.Height / 2F)),
        new PointF(panelBounds.Left, panelBounds.Top + 34));

    using DrawingCanvas panel = canvas.CreateRegion(panelBounds);

    panel.Fill(Brushes.Solid(Color.Black.WithAlpha(0.72F)));
    panel.Draw(Pens.Solid(Color.Gold, 2), new Rectangle(0, 0, panelBounds.Width, panelBounds.Height));

    // Text inside the region is positioned relative to the panel, not the source image.
    panel.DrawText(
        new RichTextOptions(titleFont) { Origin = new(14, 12), WrappingLength = panelBounds.Width - 28 },
        "Inspection note",
        Brushes.Solid(Color.White),
        pen: null);

    panel.DrawText(
        new RichTextOptions(bodyFont) { Origin = new(14, 48), WrappingLength = panelBounds.Width - 28 },
        "The highlighted area is drawn in parent coordinates; this panel uses local coordinates.",
        Brushes.Solid(Color.WhiteSmoke),
        pen: null);
}));

image.Save("annotation-panel.jpg");
```

Region canvases are useful for labels, inset panels, badges, and legends because the panel layout can be written once without repeatedly adding the parent offset.

## Clip an Annotation to a Shape

Use `Save(DrawingOptions, params IPath[])` when a marker should be constrained to a non-rectangular target. The clip uses `ShapeOptions.BooleanOperation`, so set `Intersection` for "draw only inside this shape" behavior.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;

DrawingOptions insideShape = new()
{
    ShapeOptions = new()
    {
        BooleanOperation = BooleanOperation.Intersection
    }
};

EllipsePolygon target = new(220, 140, 180, 96);

canvas.Save(insideShape, target);
canvas.Fill(Brushes.ForwardDiagonal(Color.Gold.WithAlpha(0.5F), Color.Transparent), new Rectangle(120, 82, 200, 116));
canvas.Restore();

canvas.Draw(Pens.Solid(Color.Gold, 4), target);
```

The fill and outline are separate on purpose: the hatch is clipped to the target, then the outline is drawn after `Restore()` so it remains crisp.

## Practical Guidance

- Normalize orientation, crop, and resize before computing annotation geometry.
- Keep target geometry in image coordinates, and use regions only for local panel layout.
- Use primitive rectangle, line, and text APIs for one-off callouts.
- Use paths or polygons when annotation geometry must be reused for clipping, fill, stroke, or measurement.
- Draw translucent markers before crisp outlines and labels.
- Set text wrapping instead of assuming label text will fit on one line.

## Related Topics

- [Canvas Drawing](canvas.md)
- [Primitive Drawing Helpers](primitives.md)
- [Brushes and Pens](brushesandpens.md)
- [Clipping, Regions, and Layers](clippingregionslayers.md)
- [Drawing Text](text.md)
