# Getting Started

The fastest way to get comfortable with PolygonClipper is to think in terms of three building blocks:

- a [`Vertex`](xref:SixLabors.PolygonClipper.Vertex) is one 2D point;
- a [`Contour`](xref:SixLabors.PolygonClipper.Contour) is one ring of vertices;
- a [`Polygon`](xref:SixLabors.PolygonClipper.Polygon) is a collection of contours.

From there, most applications either run a boolean operation with [`PolygonClipper`](xref:SixLabors.PolygonClipper.PolygonClipper) or generate stroke-outline geometry with [`PolygonStroker`](xref:SixLabors.PolygonClipper.PolygonStroker).

## Build Two Input Polygons

This example creates two rectangles, then intersects them:

```csharp
using System;
using SixLabors.PolygonClipper;

static Contour Rectangle(double x, double y, double width, double height)
{
    Contour contour = new(4);
    contour.Add(new Vertex(x, y));
    contour.Add(new Vertex(x + width, y));
    contour.Add(new Vertex(x + width, y + height));
    contour.Add(new Vertex(x, y + height));
    return contour;
}

Polygon subject = new();
subject.Add(Rectangle(0, 0, 80, 60));

Polygon clip = new();
clip.Add(Rectangle(40, 20, 80, 60));

Polygon result = PolygonClipper.Intersection(subject, clip);

Console.WriteLine($"Contours: {result.Count}");
Console.WriteLine($"Vertices: {result.VertexCount}");
```

You do not need to repeat the first vertex at the end of a contour for normal polygon operations. Contours are treated as implicitly closed.

## Prefer the Static Entry Points

Most applications should call the static methods:

- [`PolygonClipper.Intersection(...)`](xref:SixLabors.PolygonClipper.PolygonClipper.Intersection*)
- [`PolygonClipper.Union(...)`](xref:SixLabors.PolygonClipper.PolygonClipper.Union*)
- [`PolygonClipper.Difference(...)`](xref:SixLabors.PolygonClipper.PolygonClipper.Difference*)
- [`PolygonClipper.Xor(...)`](xref:SixLabors.PolygonClipper.PolygonClipper.Xor*)
- [`PolygonClipper.Normalize(...)`](xref:SixLabors.PolygonClipper.PolygonClipper.Normalize*)
- [`PolygonStroker.Stroke(...)`](xref:SixLabors.PolygonClipper.PolygonStroker.Stroke*)

Those are the recommended entry points in the source and route work through internal reusable instances. The instance constructors are there for advanced manual flows, but they are not the usual starting point.

## Inspect the Result

Returned polygons can contain multiple contours, including holes:

```csharp
for (int i = 0; i < result.Count; i++)
{
    Contour contour = result[i];

    Console.WriteLine(
        $"Contour {i}: Count={contour.Count}, Parent={contour.ParentIndex}, Depth={contour.Depth}, Holes={contour.HoleCount}");
}
```

That contour hierarchy is one of the main things PolygonClipper preserves for you. If you want to understand how parent contours, holes, and winding fit together, the next page to read is [Polygons, Contours, and Holes](polygonsandcontours.md).
