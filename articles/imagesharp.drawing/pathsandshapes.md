# Paths and Shapes

ImageSharp.Drawing separates geometry from painting. Shapes and paths describe where drawing happens; brushes and pens describe how pixels are shaded. Keeping that split clear makes drawing code easier to reuse: the same path can be filled, stroked, clipped, measured, transformed, used as a text baseline, or combined with other paths without duplicating the styling code.

The core geometry types are:

- [`IPath`](xref:SixLabors.ImageSharp.Drawing.IPath) for any path-like shape that can be filled or stroked.
- [`Path`](xref:SixLabors.ImageSharp.Drawing.Path) for an open path made from line segments, arcs, and curves.
- [`Polygon`](xref:SixLabors.ImageSharp.Drawing.Polygon) for a closed path.
- [`ComplexPolygon`](xref:SixLabors.ImageSharp.Drawing.ComplexPolygon) for a shape made from multiple paths, such as an outer contour with holes.
- [`Polygon`](xref:SixLabors.ImageSharp.Drawing.Polygon), [`RectanglePolygon`](xref:SixLabors.ImageSharp.Drawing.RectanglePolygon), [`EllipsePolygon`](xref:SixLabors.ImageSharp.Drawing.EllipsePolygon), [`RegularPolygon`](xref:SixLabors.ImageSharp.Drawing.RegularPolygon), [`StarPolygon`](xref:SixLabors.ImageSharp.Drawing.StarPolygon), and [`PiePolygon`](xref:SixLabors.ImageSharp.Drawing.PiePolygon) for common shapes.
- [`PathBuilder`](xref:SixLabors.ImageSharp.Drawing.PathBuilder) when you want to construct a custom path from line and curve commands.
- [`PathCollection`](xref:SixLabors.ImageSharp.Drawing.PathCollection) when one operation should cover several paths.

[`IPath.PathType`](xref:SixLabors.ImageSharp.Drawing.IPath.PathType) tells you whether a path is open, closed, or mixed. A mixed path is a composite path containing both open and closed figures.

## Built-In Shapes

Built-in shape types are closed paths with a clear geometric meaning. Use them when the shape is part of the drawing model, not just a one-off primitive call. For example, an ellipse object can be reused for fill, stroke, clipping, hit testing, and layout bounds, while a primitive `DrawEllipse(...)` call only records that one drawing command.

The shape constructors use the coordinate model of the shape itself. Rectangle-like shapes use a position and size. Ellipses, regular polygons, stars, and pies are normally expressed from a center point plus radii or size. If a translated example looks offset, check whether the source API used top-left bounds while the ImageSharp.Drawing shape expects a center.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 260, Color.White.ToPixel<Rgba32>());

EllipsePolygon ellipse = new(120, 110, 160, 96);
StarPolygon star = new(x: 292, y: 128, prongs: 7, innerRadii: 34, outerRadii: 72);
PiePolygon pie = new(120, 202, radiusX: 120, radiusY: 86, startAngle: -30, sweepAngle: 245);

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

Open paths are useful for strokes, polylines, and curved baselines. Closed paths enclose an area and are the normal input for fills. The distinction affects both fill behavior and stroke joins: a closed figure has a final join between the last and first segment, while an open figure has start and end caps.

[`Path`](xref:SixLabors.ImageSharp.Drawing.Path) is open by default. [`Polygon`](xref:SixLabors.ImageSharp.Drawing.Polygon) is closed. [`PathBuilder.CloseFigure()`](xref:SixLabors.ImageSharp.Drawing.PathBuilder.CloseFigure) closes the current figure before starting the next one.

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

Use [`PathBuilder`](xref:SixLabors.ImageSharp.Drawing.PathBuilder) for custom geometry. Build the path once, then reuse it for fill and stroke operations.

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

[`PathBuilder`](xref:SixLabors.ImageSharp.Drawing.PathBuilder) supports multiple figures. If the builder contains more than one figure, [`Build()`](xref:SixLabors.ImageSharp.Drawing.PathBuilder.Build*) returns a [`ComplexPolygon`](xref:SixLabors.ImageSharp.Drawing.ComplexPolygon). Each figure keeps its own open or closed state.

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

Use [`PathBuilder.StartFigure()`](xref:SixLabors.ImageSharp.Drawing.PathBuilder.StartFigure) when you want to begin a new figure without closing the previous one. Use [`CloseAllFigures()`](xref:SixLabors.ImageSharp.Drawing.PathBuilder.CloseAllFigures) when every current figure should be closed.

## Complex Polygons and Holes

[`ComplexPolygon`](xref:SixLabors.ImageSharp.Drawing.ComplexPolygon) represents multiple paths as one path. It is useful when a shape has multiple contours, or when you want to model an outer contour and one or more holes.

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

EllipsePolygon hole = new(210, 120, 178, 96);
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

[`PathCollection`](xref:SixLabors.ImageSharp.Drawing.PathCollection) groups paths so one draw or fill call can apply the same brush, pen, and drawing state to all of them.

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

Use a [`PathCollection`](xref:SixLabors.ImageSharp.Drawing.PathCollection) when paths remain independent. Use [`ComplexPolygon`](xref:SixLabors.ImageSharp.Drawing.ComplexPolygon) or [`Clip(...)`](xref:SixLabors.ImageSharp.Drawing.ClipPathExtensions.Clip*) when the contours need to be interpreted together as one shape.

## Clipping and Boolean Operations

[`Clip(...)`](xref:SixLabors.ImageSharp.Drawing.ClipPathExtensions.Clip*) creates a new path from a subject path and one or more clipping paths. The operation comes from [`ShapeOptions.BooleanOperation`](xref:SixLabors.ImageSharp.Drawing.Processing.ShapeOptions.BooleanOperation). The default boolean operation is [`Difference`](xref:SixLabors.ImageSharp.Drawing.BooleanOperation.Difference), which subtracts the clipping paths from the subject.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 240, Color.White.ToPixel<Rgba32>());

EllipsePolygon subject = new(190, 120, 260, 154);
StarPolygon cutout = new(x: 226, y: 120, prongs: 6, innerRadii: 38, outerRadii: 82);

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
RectanglePolygon boundsPath = new(bounds.X, bounds.Y, bounds.Width, bounds.Height);

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

EllipsePolygon outer = new(180, 110, 260, 150);
EllipsePolygon inner = new(180, 110, 126, 76);
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

## Practical Guidance

Use primitive helpers when geometry exists only for one command. Move to path and polygon objects when geometry becomes part of the model: the same shape is filled, stroked, clipped, transformed, measured, or shared between commands. That makes the relationship between layout and painting explicit.

Build closed paths deliberately when the shape represents an area. Filling an open path can work because the path is closed for fill processing, but a deliberately closed figure communicates intent and gives stroke joins closed-contour behavior. Use `ComplexPolygon` when multiple contours should be interpreted together as one region, especially when holes are involved.

The fill rule is part of the geometry contract. `NonZero` is the default and matches normal SVG and web canvas expectations, where winding direction is meaningful. Use `EvenOdd` when contour direction should not matter and nested contours should alternate inside/outside status.
