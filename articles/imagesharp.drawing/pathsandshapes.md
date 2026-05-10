# Paths and Shapes

ImageSharp.Drawing separates geometry from painting. Shapes and paths describe where drawing happens; brushes and pens describe how pixels are shaded.

The core geometry types are:

- `IPath` for any path-like shape that can be filled or stroked.
- `Path` for an open path made from line segments, arcs, and curves.
- `Polygon` for a closed path.
- `ComplexPolygon` for a shape made from multiple paths, such as an outer contour with holes.
- `Polygon`, `RectangularPolygon`, `EllipsePolygon`, `RegularPolygon`, `Star`, and `Pie` for common shapes.
- `PathBuilder` when you want to construct a custom path from line and curve commands.
- `PathCollection` when one operation should cover several paths.

`IPath.PathType` tells you whether a path is open, closed, or mixed. A mixed path is a composite path containing both open and closed figures.

## Built-In Shapes

Built-in shape types are closed paths. They can be filled directly and stroked with a pen.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 260, Color.White.ToPixel<Rgba32>());

EllipsePolygon ellipse = new(new PointF(120, 110), new SizeF(160, 96));
Star star = new(x: 292, y: 128, prongs: 7, innerRadii: 34, outerRadii: 72);
Pie pie = new(new PointF(120, 202), new SizeF(120, 86), startAngle: -30, sweepAngle: 245);

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.SkyBlue), ellipse);
    canvas.Draw(Pens.Solid(Color.Navy, 3), ellipse);

    canvas.Fill(Brushes.Solid(Color.Orange), star);
    canvas.Draw(Pens.Solid(Color.DarkRed, 3), star);

    canvas.Fill(Brushes.Solid(Color.MediumSeaGreen), pie);
    canvas.Draw(Pens.Solid(Color.DarkGreen, 3), pie);
}));
```

## Open and Closed Paths

Open paths are useful for strokes, polylines, and curved baselines. Closed paths enclose an area and are the normal input for fills.

`Path` is open by default. `Polygon` is closed. `PathBuilder.CloseFigure()` closes the current figure before starting the next one.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(440, 220, Color.White.ToPixel<Rgba32>());

PathBuilder openBuilder = new();
openBuilder.AddCubicBezier(
    new(36, 152),
    new(116, 34),
    new(252, 38),
    new(396, 154));

IPath openPath = openBuilder.Build();

PathBuilder closedBuilder = new();
closedBuilder.AddLines(new(64, 174), new(154, 54), new(244, 174));
closedBuilder.CloseFigure();

IPath closedPath = closedBuilder.Build();

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Draw(Pens.Solid(Color.MidnightBlue, 8), openPath);

    // Closed figures can be filled because they define an inside area.
    canvas.Fill(Brushes.Solid(Color.Gold.WithAlpha(0.6F)), closedPath);
    canvas.Draw(Pens.Solid(Color.DarkGoldenrod, 4), closedPath);
}));
```

When you fill an open path, ImageSharp.Drawing closes it for fill processing. Prefer building the figure as closed when the intended geometry is a filled area; that keeps the model clear and also gives stroke joins closed-contour behavior.

## Custom Paths and Figures

Use `PathBuilder` for custom geometry. Build the path once, then reuse it for fill and stroke operations.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 220, Color.White.ToPixel<Rgba32>());

PathBuilder builder = new();
builder.AddLines(new(42, 176), new(112, 36), new(210, 154));
builder.AddCubicBezier(
    new(210, 154),
    new(268, 46),
    new(336, 50),
    new(376, 164));

IPath path = builder.Build();

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Draw(Pens.Solid(Color.MidnightBlue, 8), path);
    canvas.Draw(Pens.Dot(Color.White, 3), path);
}));
```

`PathBuilder` supports multiple figures. If the builder contains more than one figure, `Build()` returns a `ComplexPolygon`. Each figure keeps its own open or closed state.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 240, Color.White.ToPixel<Rgba32>());

PathBuilder builder = new();
builder.AddLines(new(52, 190), new(122, 54), new(196, 190));
builder.CloseFigure();

builder.AddCubicBezier(
    new(236, 178),
    new(268, 38),
    new(336, 48),
    new(374, 178));

IPath mixedPath = builder.Build();

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.LightSkyBlue), mixedPath);
    canvas.Draw(Pens.Solid(Color.Navy, 5), mixedPath);
}));
```

Use `PathBuilder.StartFigure()` when you want to begin a new figure without closing the previous one. Use `CloseAllFigures()` when every current figure should be closed.

## Complex Polygons and Holes

`ComplexPolygon` represents multiple paths as one path. It is useful when a shape has multiple contours, or when you want to model an outer contour and one or more holes.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 240, Color.White.ToPixel<Rgba32>());

Polygon outer = new(
[
    new PointF(60, 36),
    new PointF(360, 36),
    new PointF(360, 204),
    new PointF(60, 204)
]);

EllipsePolygon hole = new(new PointF(210, 120), new SizeF(178, 96));
ComplexPolygon complex = new(outer, hole);

DrawingOptions options = new()
{
    ShapeOptions = new()
    {
        IntersectionRule = IntersectionRule.EvenOdd
    }
};

image.Mutate(ctx => ctx.Paint(options, canvas =>
{
    canvas.Fill(Brushes.Solid(Color.MediumPurple), complex);
    canvas.Draw(Pens.Solid(Color.Black, 3), complex);
}));
```

The fill rule decides how overlapping contours inside a complex polygon are interpreted. `NonZero` is the default and matches the usual SVG and web canvas behavior: contour winding is meaningful, so holes are normally expressed by winding the inner contour in the opposite direction to its parent. Use `EvenOdd` when you want parity-based holes where contour direction is not significant.

## Path Collections

`PathCollection` groups paths so one draw or fill call can apply the same brush, pen, and drawing state to all of them.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 220, Color.White.ToPixel<Rgba32>());

PathCollection bubbles = new(
    new EllipsePolygon(new PointF(104, 112), new SizeF(96, 72)),
    new EllipsePolygon(new PointF(210, 92), new SizeF(126, 86)),
    new EllipsePolygon(new PointF(316, 126), new SizeF(104, 78)));

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.LightCyan), bubbles);
    canvas.Draw(Pens.Solid(Color.DarkSlateBlue, 3), bubbles);
}));
```

Use a `PathCollection` when paths remain independent. Use `ComplexPolygon` or `Clip(...)` when the contours need to be interpreted together as one shape.

## Clipping and Boolean Operations

`Clip(...)` creates a new path from a subject path and one or more clipping paths. The operation comes from `ShapeOptions.BooleanOperation`. The default boolean operation is `Difference`, which subtracts the clipping paths from the subject.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 240, Color.White.ToPixel<Rgba32>());

EllipsePolygon subject = new(new PointF(190, 120), new SizeF(260, 154));
Star cutout = new(x: 226, y: 120, prongs: 6, innerRadii: 38, outerRadii: 82);

ShapeOptions clipOptions = new()
{
    BooleanOperation = BooleanOperation.Difference
};

IPath clipped = subject.Clip(clipOptions, cutout);

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.Orange), clipped);
    canvas.Draw(Pens.Solid(Color.DarkRed, 3), clipped);
}));
```

Use `BooleanOperation.Intersection` when you want only the overlap, `Union` when you want to merge shapes, and `Xor` when you want areas covered by exactly one side.

## Inspecting and Reusing Geometry

Paths are reusable geometry objects. You can measure them, transform them, convert open paths to closed paths, and use the same geometry for fills, strokes, clipping, and text paths.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 240, Color.White.ToPixel<Rgba32>());

PathBuilder builder = new();
builder.AddLines(new(70, 178), new(132, 54), new(226, 172), new(318, 66), new(368, 178));

IPath openPath = builder.Build();
IPath closedPath = openPath.AsClosedPath();
IPath shiftedPath = closedPath.Translate(0, 24);

float length = openPath.ComputeLength();
float area = closedPath.ComputeArea();
RectangleF bounds = shiftedPath.Bounds;
RectangularPolygon boundsPath = new(bounds.X, bounds.Y, bounds.Width, bounds.Height);

image.Mutate(ctx => ctx.Paint(canvas =>
{

    // Use measurements to draw simple diagnostics around the transformed geometry.
    canvas.Fill(Brushes.Solid(Color.LightGoldenrodYellow), shiftedPath);
    canvas.Draw(Pens.Solid(Color.DarkGoldenrod, 4), shiftedPath);
    canvas.Draw(Pens.Dash(Color.Gray, 2), boundsPath);
}));
```

`ComputeLength()` follows open and closed contours. `ComputeArea()` is meaningful for closed shapes. `Transform(...)` applies an arbitrary matrix, while helpers such as `Translate(...)`, `Scale(...)`, and `RotateDegree(...)` cover common transforms.

## Fill Rules

`ShapeOptions.IntersectionRule` controls how overlapping contours are interpreted during fill operations. `NonZero` is the default, matching the normal SVG and web canvas fill-rule default. Use `EvenOdd` when you explicitly want alternating inside/outside behavior for nested or overlapping contours.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(360, 220, Color.White.ToPixel<Rgba32>());

EllipsePolygon outer = new(new PointF(180, 110), new SizeF(260, 150));
EllipsePolygon inner = new(new PointF(180, 110), new SizeF(126, 76));
PathCollection shape = new(outer, inner);

DrawingOptions options = new()
{
    ShapeOptions = new()
    {
        IntersectionRule = IntersectionRule.EvenOdd
    }
};

image.Mutate(ctx => ctx.Paint(options, canvas =>
{
    canvas.Fill(Brushes.Solid(Color.HotPink), shape);
    canvas.Draw(Pens.Solid(Color.Black, 3), shape);
}));
```

For lower-level polygon boolean operations, see [PolygonClipper](../polygonclipper/index.md).
