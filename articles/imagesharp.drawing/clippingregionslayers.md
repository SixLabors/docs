# Clipping, Regions, and Layers

Canvas state controls where later commands can draw and how grouped commands are composed. The three main tools are `Save(...)` with clip paths, `CreateRegion(...)`, and `SaveLayer(...)`.

## Clip Later Commands

`Save(DrawingOptions, params IPath[])` pushes a new state with the supplied options and clip paths. The clip paths are combined with each command by `ShapeOptions.BooleanOperation`.

The default boolean operation is `Difference`, which subtracts the clip path. For ordinary "draw inside this shape" clipping, set `BooleanOperation.Intersection`.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 260, Color.White.ToPixel<Rgba32>());

EllipsePolygon spotlight = new(new PointF(210, 130), new SizeF(300, 160));
DrawingOptions clipInside = new()
{
    ShapeOptions = new()
    {
        BooleanOperation = BooleanOperation.Intersection
    }
};

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.MidnightBlue));

    _ = canvas.Save(clipInside, spotlight);

    // The rectangle is larger than the ellipse; the saved state keeps only the intersection.
    canvas.Fill(Brushes.Horizontal(Color.Gold, Color.OrangeRed), new Rectangle(20, 40, 380, 180));
    canvas.Restore();

    canvas.Draw(Pens.Solid(Color.White, 3), spotlight);
}));
```

Use `Restore()` to pop the latest state, or `RestoreTo(saveCount)` when nested states must be unwound together.

## Region Canvases

`CreateRegion(...)` creates a child canvas with local coordinates inside a rectangular area. It is useful for controls, panels, tiles, thumbnails, and other sub-layouts where `(0, 0)` should mean the region origin.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(360, 220, Color.White.ToPixel<Rgba32>());

image.Mutate(ctx => ctx.Paint(canvas =>
{
    using DrawingCanvas region = canvas.CreateRegion(new Rectangle(70, 48, 220, 124));

    region.Fill(Brushes.Solid(Color.LightSeaGreen.WithAlpha(0.8F)), new Rectangle(10, 10, 120, 68));

    // Region-local coordinates are relative to the region, not the parent canvas.
    region.Draw(Pens.Solid(Color.DarkBlue, 5), new Rectangle(0, 0, 220, 124));
    region.DrawLine(Pens.Solid(Color.OrangeRed, 4), new PointF(0, 123), new PointF(219, 0));
}));
```

Nested regions can also have their own saved state. The root canvas still owns final replay, so disposing a child region does not render the whole image immediately.

## Layers

`SaveLayer(...)` starts an isolated compositing scope. Commands drawn inside the layer render into that layer, then `Restore()` composites the layer back to the parent with the supplied `GraphicsOptions`.

Layer bounds limit the isolated target and final composition area. They do not shift the coordinate system.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(360, 220, Color.White.ToPixel<Rgba32>());

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.SteelBlue), new Rectangle(24, 24, 312, 172));

    _ = canvas.SaveLayer(new GraphicsOptions { BlendPercentage = 0.55F }, new Rectangle(70, 46, 220, 128));

    // Layer bounds constrain compositing; these coordinates are still parent coordinates.
    canvas.Fill(Brushes.Solid(Color.OrangeRed), new EllipsePolygon(new PointF(180, 110), new SizeF(170, 96)));
    canvas.Draw(Pens.Solid(Color.White, 8), new Rectangle(96, 74, 168, 72));
    canvas.Restore();

    canvas.Draw(Pens.Solid(Color.Black, 2), new Rectangle(70, 46, 220, 128));
}));
```

Use layers when a group of commands should blend back as one result. Without a layer, each command blends into the parent independently.
