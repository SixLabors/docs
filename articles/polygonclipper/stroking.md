# Stroking

Stroking in PolygonClipper means turning a path-like input into filled outline geometry. Instead of drawing centerlines directly, [`PolygonStroker`](xref:SixLabors.PolygonClipper.PolygonStroker) emits a polygon that represents the area the stroke would cover.

That makes it useful both for standalone geometry workflows and for renderers that want stroke outlines as polygons.

## Use the Static Entry Point

Most callers should use the static [`PolygonStroker.Stroke(...)`](xref:SixLabors.PolygonClipper.PolygonStroker.Stroke*) method:

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
    MiterLimit = 4,
    ArcDetailScale = 1,
    NormalizeOutput = true
};

Polygon outline = PolygonStroker.Stroke(source, 12, options);
```

The main knobs are:

- [`LineJoin`](xref:SixLabors.PolygonClipper.StrokeOptions.LineJoin) for outer corners;
- [`LineCap`](xref:SixLabors.PolygonClipper.StrokeOptions.LineCap) for open-path ends;
- [`MiterLimit`](xref:SixLabors.PolygonClipper.StrokeOptions.MiterLimit) for clamping long outer miters;
- [`ArcDetailScale`](xref:SixLabors.PolygonClipper.StrokeOptions.ArcDetailScale) for the smoothness-versus-vertex-count tradeoff on round joins and caps;
- [`NormalizeOutput`](xref:SixLabors.PolygonClipper.StrokeOptions.NormalizeOutput) when you want overlaps and self-intersections in the emitted stroke geometry resolved before returning.

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

ImageSharp.Drawing also uses PolygonClipper for stroke geometry generation. Its higher-level stroke options are mapped down to PolygonClipper's `LineJoin`, `LineCap`, miter, and normalization settings before outline polygons are generated.

## Practical Guidance

Use stroking when a path or polyline needs to become filled outline geometry. The result is a polygon region, not a rendering command, so it can be inspected, clipped, exported, or rendered by another system.

Decide whether the input is open or closed before choosing caps. Open inputs emit end caps; closed inputs do not. Stroke width is expressed in the same coordinate units as the source geometry, so scaling source coordinates without scaling stroke width changes the visual result.

Join, cap, miter, and cleanup options should match the renderer or exporter that will consume the outline. Inspect the returned polygon as geometry: complex strokes can produce multiple contours and holes, especially around self-overlap, sharp joins, or closed paths.
