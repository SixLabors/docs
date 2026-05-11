# Primitive Drawing Helpers

Primitive helpers are convenience methods on [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas) for common geometry. Use them when the shape is simple and you do not need to keep an [`IPath`](xref:SixLabors.ImageSharp.Drawing.IPath) instance around.

The helpers still follow the same rules as path drawing: fills use brushes, strokes use pens, [`DrawingOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingOptions) controls antialiasing and transforms, and active canvas state applies to the recorded command.

Primitive calls record a drawing command immediately. They are a good fit for marks, guides, simple badges, outlines, and other geometry that is only used once. If the same geometry must be filled, stroked, clipped, transformed, measured, or shared between commands, create a path or polygon object instead.

## Rectangles, Ellipses, Lines, and Beziers

Rectangle helpers use a top-left coordinate plus width and height. Ellipse helpers use a center point plus size, matching [`EllipsePolygon`](xref:SixLabors.ImageSharp.Drawing.EllipsePolygon). Lines and Beziers use explicit points in canvas coordinates, so they are easy to combine with image-space measurements.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(360, 240, Color.White.ToPixel<Rgba32>());

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Draw(Pens.Solid(Color.DimGray, 3), new Rectangle(16, 16, 328, 208));
    canvas.DrawEllipse(Pens.Solid(Color.CornflowerBlue, 6), new PointF(180, 120), new SizeF(170, 100));

    // DrawLine accepts a polyline, so each point after the first extends the same stroke.
    canvas.DrawLine(
        Pens.Solid(Color.OrangeRed, 5),
        new PointF(28, 206),
        new PointF(110, 46),
        new PointF(248, 188),
        new PointF(332, 34));

    // DrawBezier is useful for one cubic curve; use PathBuilder for longer paths.
    canvas.DrawBezier(
        Pens.Solid(Color.MediumVioletRed, 4),
        new PointF(32, 126),
        new PointF(88, 30),
        new PointF(258, 210),
        new PointF(326, 118));
}));
```

Use the rectangle and ellipse helpers when the geometry exists only for that command. For example, `DrawEllipse(...)` is concise for a one-off ring, while `new EllipsePolygon(...)` is better when the same ellipse must be clipped, filled, and outlined.

## Arcs and Pies

Arc and pie helpers take a center point, a size, a rotation angle, a start angle, and a sweep angle. Positive and negative sweeps are both valid, which makes clockwise and counter-clockwise segments easy to express.

Arc helpers draw or fill the curved segment of an ellipse. Pie helpers close the segment back to the center, creating a wedge. Use [`PiePolygon`](xref:SixLabors.ImageSharp.Drawing.PiePolygon) when the wedge is part of reusable geometry.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(360, 240, Color.White.ToPixel<Rgba32>());

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.FillArc(
        Brushes.Solid(Color.CornflowerBlue),
        new PointF(112, 92),
        new SizeF(84, 58),
        rotation: 15,
        startAngle: -30,
        sweepAngle: 240);

    canvas.DrawArc(
        Pens.Solid(Color.ForestGreen, 4),
        new PointF(224, 92),
        new SizeF(116, 62),
        rotation: 15,
        startAngle: -25,
        sweepAngle: 220);

    // Pie helpers connect the arc back to the center, creating a wedge.
    canvas.FillPie(Brushes.Solid(Color.Goldenrod), new PointF(118, 172), new SizeF(58, 58), startAngle: 20, sweepAngle: 240);
    canvas.DrawPie(Pens.Solid(Color.DarkSlateBlue, 6), new PointF(236, 170), new SizeF(62, 48), startAngle: 35, sweepAngle: -210);
}));
```

## When to Use Paths Instead

Use [`PathBuilder`](xref:SixLabors.ImageSharp.Drawing.PathBuilder), [`Polygon`](xref:SixLabors.ImageSharp.Drawing.Polygon), [`ComplexPolygon`](xref:SixLabors.ImageSharp.Drawing.ComplexPolygon), or a built-in shape type when you need to:

- reuse or transform the same geometry;
- combine multiple figures into one shape;
- choose fill rules for overlapping contours;
- stroke the generated outline with `Pen.GeneratePath(...)`;
- measure bounds, length, or area before drawing.

The primitive helpers are best for direct one-off drawing. Paths are better when the geometry is part of the model.
