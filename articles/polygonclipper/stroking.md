# Stroking

Stroking in PolygonClipper means turning a path-like input into filled outline geometry. Instead of drawing centerlines directly, [`PolygonStroker`](xref:SixLabors.PolygonClipper.PolygonStroker) emits a polygon that represents the area the stroke would cover.

That makes it useful both for standalone geometry workflows and for renderers that want stroke outlines as polygons.

## Use the Static Entry Point

Most callers should use the static method:

```csharp
using SixLabors.PolygonClipper;

Polygon outline = PolygonStroker.Stroke(input, width: 12);
```

Like the boolean-operation APIs, this is the recommended entry point in the source and uses internal reusable instances.

## Stroke an Open Polyline

```csharp
using SixLabors.PolygonClipper;

Contour polyline = new();
polyline.Add(new Vertex(0, 0));
polyline.Add(new Vertex(60, 20));
polyline.Add(new Vertex(120, 0));

Polygon source = new();
source.Add(polyline);

Polygon outline = PolygonStroker.Stroke(source, 12);
```

In this case the contour is treated as open, so the emitted geometry includes end caps.

## Control Joins, Caps, and Output Cleanup

[`StrokeOptions`](xref:SixLabors.PolygonClipper.StrokeOptions) lets you control the shape of the generated outline:

```csharp
using SixLabors.PolygonClipper;

StrokeOptions options = new()
{
    LineJoin = LineJoin.Round,
    LineCap = LineCap.Round,
    InnerJoin = InnerJoin.Round,
    MiterLimit = 4,
    InnerMiterLimit = 1.01,
    ArcDetailScale = 1,
    NormalizeOutput = true
};

Polygon outline = PolygonStroker.Stroke(source, 12, options);
```

The main knobs are:

- `LineJoin` for outer corners;
- `LineCap` for open-path ends;
- `InnerJoin` for sharp interior turns;
- `MiterLimit` and `InnerMiterLimit` for clamping long miters;
- `ArcDetailScale` for the smoothness-versus-vertex-count tradeoff on round joins and caps;
- `NormalizeOutput` when you want overlaps and self-intersections in the emitted stroke geometry resolved before returning.

`NormalizeOutput` defaults to `false` for throughput. When you leave it off, render the returned geometry with a non-zero winding fill rule.

## Open Versus Closed Stroke Input

For stroking, PolygonClipper distinguishes between contours that should behave like open polylines and contours that should behave like closed loops.

If the last vertex returns to the first vertex, or is extremely close to it, the stroker treats the contour as closed and does not emit end caps. Otherwise it treats the contour as open and emits caps.

That means these two inputs are interpreted differently:

- a contour whose endpoints are clearly different behaves like an open path;
- a contour whose last vertex returns to its first behaves like a closed path.

## Width Semantics

Most callers use a positive width:

```csharp
Polygon outline = PolygonStroker.Stroke(source, 8);
```

Negative widths are supported for advanced scenarios. They flip the emitted side orientation while preserving the width magnitude.

## Used by ImageSharp.Drawing

ImageSharp.Drawing also uses PolygonClipper for stroke geometry generation. Its higher-level stroke options are mapped down to PolygonClipper's `LineJoin`, `LineCap`, `InnerJoin`, miter, and normalization settings before outline polygons are generated.
