# Draw a Badge or Label

Small generated badges usually combine a filled shape, an outline, and centered text. Define the badge bounds once, then use the same geometry for fill and stroke so the border exactly follows the filled area.

This pattern works well for status chips, Open Graph badges, generated labels, and small UI assets. Keep the badge geometry, gradient, and text layout separate: the same rectangle controls fill and stroke, while `RichTextOptions` controls how the label sits inside the shape.

Generated badges tend to be consumed by other layout systems, so stable output dimensions matter. Decide the canvas size and badge bounds first, then fit text inside that region with wrapping and centered alignment. If labels can vary by localization, tenant name, or status text, leave more horizontal padding than the ideal English sample appears to need.

The same geometry should usually drive the fill and the stroke. That avoids one-pixel mismatches where a border no longer follows the filled shape. For more complex badge shapes, build a custom path once and reuse it for the gradient fill, outline, clipping, and any hit-test or layout calculations.

```csharp
using SixLabors.Fonts;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 180, Color.Transparent.ToPixel<Rgba32>());

Rectangle badge = new(24, 36, 372, 108);
Font font = SystemFonts.CreateFont("Arial", 38, FontStyle.Bold);
PointF gradientStart = new(24, 36);
PointF gradientEnd = new(396, 144);
RichTextOptions textOptions = new(font)
{
    Origin = new(210, 90),
    WrappingLength = 320,
    HorizontalAlignment = HorizontalAlignment.Center,
    VerticalAlignment = VerticalAlignment.Center,
    TextAlignment = TextAlignment.Center
};

LinearGradientBrush fill = new(
    gradientStart,
    gradientEnd,
    GradientRepetitionMode.None,
    new ColorStop(0F, Color.DeepSkyBlue),
    new ColorStop(1F, Color.MediumBlue));

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(fill, badge);
    canvas.Draw(Pens.Solid(Color.White.WithAlpha(0.9F), 4), badge);

    // The text anchor is the badge center, and wrapping keeps long labels inside the shape.
    canvas.DrawText(textOptions, "ACTIVE", Brushes.Solid(Color.White), pen: null);
}));

image.Save("badge.png");
```

Use a path type that matches the badge geometry you want. [`RectanglePolygon`](xref:SixLabors.ImageSharp.Drawing.RectanglePolygon), [`EllipsePolygon`](xref:SixLabors.ImageSharp.Drawing.EllipsePolygon), [`RegularPolygon`](xref:SixLabors.ImageSharp.Drawing.RegularPolygon), [`StarPolygon`](xref:SixLabors.ImageSharp.Drawing.StarPolygon), and custom [`PathBuilder`](xref:SixLabors.ImageSharp.Drawing.PathBuilder) paths can all be filled and stroked through the same canvas calls.

If the label can vary, set `WrappingLength` smaller than the badge width and use centered alignment. That gives long values room to wrap instead of spilling into the border.

## Related Topics

- [Primitive Drawing Helpers](primitives.md)
- [Brushes and Pens](brushesandpens.md)
- [Drawing Text](text.md)

## Practical Guidance

Build badge geometry once and reuse it for fill and stroke. Keep source dimensions stable when generated badges are consumed by layout systems. Set text wrapping shorter than the badge width when labels can vary, and use centered alignment instead of manual text offsets.
