# Normalization and Winding

Boolean operations combine two polygons. Normalization is different: it cleans up one polygon by resolving self-intersections and overlaps into a canonical positive-winding result.

That makes [`PolygonClipper.Normalize(...)`](xref:SixLabors.PolygonClipper.PolygonClipper.Normalize*) the right tool when your input geometry is already yours, but its contours are messy enough that you want a cleaner region description before export, rendering, or further processing.

## When to Use [`Normalize(...)`](xref:SixLabors.PolygonClipper.PolygonClipper.Normalize*)

Normalization is useful when:

- a contour self-intersects;
- multiple contours overlap and you want one clean regional result;
- you want positive-winding output for a downstream system that depends on winding semantics;
- you want hierarchy and overlap resolution without performing a two-input boolean operation.

## Normalize a Self-Intersecting Input

```csharp
using SixLabors.PolygonClipper;

Contour contour = new(4);
contour.Add(new Vertex(0, 0));
contour.Add(new Vertex(80, 80));
contour.Add(new Vertex(0, 80));
contour.Add(new Vertex(80, 0));

Polygon input = new();
input.Add(contour);

Polygon normalized = PolygonClipper.Normalize(input);
```

The output may have a different contour count and different contour hierarchy than the input. That is expected. Normalization is free to split or reorganize the input region as needed to produce clean positive-winding output.

## Positive Winding Matters

The source describes normalization in terms of positive fill semantics. In practice, that means the result is intended for consumers that care about winding-consistent filled regions rather than raw overlapping edges.

This is especially useful when you are moving polygon data into a renderer, exporter, or geometry pipeline that expects contours to describe filled regions cleanly.

## Implementation Note

Normalization is a separate pipeline from the two-input boolean operations. In PolygonClipper it follows a Vatti/Clipper2-inspired approach focused on turning overlapping or self-intersecting contour input into a canonical positive-winding result.

## Normalization Is Not Required for Every Workflow

You do not need to call [`Normalize(...)`](xref:SixLabors.PolygonClipper.PolygonClipper.Normalize*) before every boolean operation. The boolean APIs already process complex polygon inputs.

Reach for normalization when your goal is specifically:

- cleaning up one polygon rather than combining two;
- resolving self-overlap into a canonical result;
- preparing output for systems that rely on positive-winding contour semantics.
