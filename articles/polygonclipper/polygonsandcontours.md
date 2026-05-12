# Polygons, Contours, and Holes

PolygonClipper's public model is intentionally small. Most of the time you only need to understand three types:

- [`Vertex`](xref:SixLabors.PolygonClipper.Vertex) for 2D coordinates and basic vector math;
- [`Contour`](xref:SixLabors.PolygonClipper.Contour) for one ring of vertices;
- [`Polygon`](xref:SixLabors.PolygonClipper.Polygon) for a collection of contours.

That small model is enough to describe simple shapes, complex multi-contour shapes, and polygons with holes.

The important mental model is that contours are topology, not styling. PolygonClipper does not know about brushes, pens, fill colors, or pixels. It returns geometry that another layer can render, serialize, hit-test, or combine with more geometry.

## Regions, Not Drawing Commands

PolygonClipper treats polygons as filled regions bounded by contours. It is not a path recorder and it does not preserve the original drawing commands that produced the contour data. After normalization, clipping, or boolean operations, the output may contain different contours because the library is describing the resulting region, not the editing history.

This is the same distinction that matters in rendering systems: a path is a set of geometric edges, while a filled region is the area those edges enclose under a fill rule. PolygonClipper operates on the region model.

## A `Contour` Is One Ring

A [`Contour`](xref:SixLabors.PolygonClipper.Contour) is a sequence of vertices. For clipping and normalization, it is treated as implicitly closed, so the library always considers an edge between the last vertex and the first vertex.

That means this is a complete rectangle contour:

```csharp
using SixLabors.PolygonClipper;

Contour contour = new(4);
contour.Add(new Vertex(0, 0));
contour.Add(new Vertex(80, 0));
contour.Add(new Vertex(80, 60));
contour.Add(new Vertex(0, 60));
```

There is no need to append `(0, 0)` again at the end unless you are deliberately feeding the stroker a contour you want treated as explicitly closed.

Avoid duplicate closing vertices in boolean inputs unless your data source naturally includes them and you have chosen to preserve them. Repeating the first vertex usually adds no information for region operations.

## A `Polygon` Is a Collection of Contours

A [`Polygon`](xref:SixLabors.PolygonClipper.Polygon) is simply a list of contours:

```csharp
using SixLabors.PolygonClipper;

Polygon polygon = new();
polygon.Add(contour);
```

That is enough for a single simple region. As soon as you need holes or multiple disjoint regions, you add more contours.

## Hole Hierarchy Is Represented Explicitly

Contours can participate in a parent-child hierarchy:

- [`ParentIndex`](xref:SixLabors.PolygonClipper.Contour.ParentIndex) points to the owning contour when a contour is a hole or nested child;
- [`HoleCount`](xref:SixLabors.PolygonClipper.Contour.HoleCount) and [`GetHoleIndex(...)`](xref:SixLabors.PolygonClipper.Contour.GetHoleIndex*) let an outer contour enumerate its direct holes;
- [`Depth`](xref:SixLabors.PolygonClipper.Contour.Depth) records how deeply nested the contour is;
- [`IsExternal`](xref:SixLabors.PolygonClipper.Contour.IsExternal) is `true` when `ParentIndex` is `null`.

If you already know the hierarchy of your input data, you can represent it directly:

```csharp
using SixLabors.PolygonClipper;

Polygon polygon = new(2);

Contour outer = new(4);
outer.Add(new Vertex(0, 0));
outer.Add(new Vertex(100, 0));
outer.Add(new Vertex(100, 100));
outer.Add(new Vertex(0, 100));

Contour hole = new(4);
hole.Add(new Vertex(25, 25));
hole.Add(new Vertex(75, 25));
hole.Add(new Vertex(75, 75));
hole.Add(new Vertex(25, 75));

polygon.Add(outer);
polygon.Add(hole);

hole.ParentIndex = 0;
hole.Depth = 1;
outer.AddHoleIndex(1);
```

When you do not already know the hierarchy, boolean operations and normalization will compute it for the returned polygon.

If you construct hierarchy yourself, keep `ParentIndex`, `Depth`, and hole indexes consistent. Those values are part of how consumers understand which contours are exterior regions and which contours subtract from a parent region.

## Orientation Helpers

[`Contour`](xref:SixLabors.PolygonClipper.Contour) also exposes orientation helpers:

- [`IsCounterClockwise()`](xref:SixLabors.PolygonClipper.Contour.IsCounterClockwise*)
- [`IsClockwise()`](xref:SixLabors.PolygonClipper.Contour.IsClockwise*)
- [`Reverse()`](xref:SixLabors.PolygonClipper.Contour.Reverse*)
- [`SetClockwise()`](xref:SixLabors.PolygonClipper.Contour.SetClockwise*)
- [`SetCounterClockwise()`](xref:SixLabors.PolygonClipper.Contour.SetCounterClockwise*)

Those are useful when you are inspecting or preparing contours, but you do not need to normalize orientation by hand for every workflow. If your real goal is to resolve messy self-overlapping input into canonical positive-winding output, use [`PolygonClipper.Normalize(...)`](xref:SixLabors.PolygonClipper.PolygonClipper.Normalize*).

## Bounding Boxes and Translation

Both polygons and contours can answer a few practical geometry questions without running a boolean operation:

- [`GetBoundingBox()`](xref:SixLabors.PolygonClipper.Polygon.GetBoundingBox*) returns a [`Box2`](xref:SixLabors.PolygonClipper.Box2)
- [`Translate(x, y)`](xref:SixLabors.PolygonClipper.Polygon.Translate*) offsets the geometry in place

```csharp
using SixLabors.PolygonClipper;

Box2 bounds = polygon.GetBoundingBox();
polygon.Translate(10, 20);
```

Those helpers are especially useful when you are staging input, culling broad regions, or preparing geometry for a later clip or stroke pass.

## Practical Guidance

- Store source geometry in one consistent coordinate space before clipping.
- Treat returned polygons as region results, not as a promise to preserve input contour order.
- Inspect `Depth` and `ParentIndex` when exporting to formats that need exterior and hole rings separately.
- Use bounding boxes for broad-phase rejection before expensive geometry work when you have many polygons.
