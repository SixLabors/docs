# Boolean Operations

Boolean operations are the center of PolygonClipper. They let you combine or subtract polygon regions without dropping down into segment-level geometry code.

The public entry points are the static methods on [`PolygonClipper`](xref:SixLabors.PolygonClipper.PolygonClipper):

- [`Intersection(subject, clip)`](xref:SixLabors.PolygonClipper.PolygonClipper.Intersection*)
- [`Union(subject, clip)`](xref:SixLabors.PolygonClipper.PolygonClipper.Union*)
- [`Difference(subject, clip)`](xref:SixLabors.PolygonClipper.PolygonClipper.Difference*)
- [`Xor(subject, clip)`](xref:SixLabors.PolygonClipper.PolygonClipper.Xor*)

These are also the recommended entry points in the source, because they route work through internal reusable instances.

## Choose the Right Operation

The four operations have different semantics:

- `Intersection` keeps only the area shared by both inputs.
- `Union` keeps the area covered by either input.
- `Difference` subtracts the clip polygon from the subject polygon.
- `Xor` keeps the non-overlapping parts of both inputs and removes the shared overlap.

If `Xor` is not a familiar term, it helps to think of it as "union, but with the overlapping middle cut away."

A few quick cases make the behavior easier to picture:

- if the two polygons do not touch, `Xor` gives the same result as `Union`;
- if the two polygons are identical, `Xor` returns an empty result;
- if one polygon sits inside the other, `Xor` keeps the outer region and removes the shared inner region.

[`Difference`](xref:SixLabors.PolygonClipper.PolygonClipper.Difference*) is the one where argument order matters most. `Difference(a, b)` is not the same as `Difference(b, a)`.

## Run a Boolean Operation

```csharp
using SixLabors.PolygonClipper;

Polygon result = PolygonClipper.Union(subject, clip);
Polygon overlap = PolygonClipper.Intersection(subject, clip);
Polygon remaining = PolygonClipper.Difference(subject, clip);
Polygon exclusive = PolygonClipper.Xor(subject, clip);
```

The returned [`Polygon`](xref:SixLabors.PolygonClipper.Polygon) may contain:

- more than one contour;
- hole relationships;
- different contour counts than either input.

That is normal. Boolean operations work with regions, not one-contour-in one-contour-out assumptions.

## Subject and Clip Inputs

Both input polygons can contain:

- multiple contours;
- holes;
- disjoint islands;
- non-convex shapes.

That is one of the main reasons to use PolygonClipper instead of writing one-off rectangle or convex-shape code.

## Implementation Note

PolygonClipper's boolean operations are built on a Martinez-Rueda sweep-line pipeline. For most users, the practical takeaway is simply that the library is designed for complex polygon inputs rather than only simple convex cases.

## Inspect Returned Hierarchy

The result can include parent-child contour relationships:

```csharp
for (int i = 0; i < result.Count; i++)
{
    Contour contour = result[i];

    Console.WriteLine(
        $"Contour {i}: Parent={contour.ParentIndex}, Depth={contour.Depth}, Holes={contour.HoleCount}");
}
```

If you care about preserving hole structure or exporting contours to another renderer, inspect that hierarchy instead of assuming every returned contour is a top-level exterior ring.

## Used by ImageSharp.Drawing

If you use [ImageSharp.Drawing](../imagesharp.drawing/index.md), this part of PolygonClipper may already be in your rendering pipeline. ImageSharp.Drawing converts path geometry into PolygonClipper polygons and uses these boolean operations internally when combining clipped path regions.

That makes PolygonClipper a good fit both as a standalone geometry library and as the lower-level model behind higher-level drawing systems.
