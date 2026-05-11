# Draw a Badge or Label

Small generated badges usually combine a filled shape, an outline, and centered text. Build the shape once, then use the same path for fill and stroke so the border exactly follows the filled area.

```csharp
using SixLabors.Fonts;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 180, Color.Transparent.ToPixel<Rgba32>());

RectangularPolygon badge = new(24, 36, 372, 108);
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

Use a path type that matches the badge geometry you want. [`RectangularPolygon`](xref:SixLabors.ImageSharp.Drawing.RectangularPolygon), [`EllipsePolygon`](xref:SixLabors.ImageSharp.Drawing.EllipsePolygon), [`RegularPolygon`](xref:SixLabors.ImageSharp.Drawing.RegularPolygon), [`Star`](xref:SixLabors.ImageSharp.Drawing.Star), and custom [`PathBuilder`](xref:SixLabors.ImageSharp.Drawing.PathBuilder) paths can all be filled and stroked through the same canvas calls.

## Related Topics

- [Primitive Drawing Helpers](primitives.md)
- [Brushes and Pens](brushesandpens.md)
- [Drawing Text](text.md)
