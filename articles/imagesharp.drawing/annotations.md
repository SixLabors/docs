# Add Callouts and Annotations

Annotations are just normal drawing commands layered over an existing image. Use pens for outlines and guides, transparent fills for highlights, and text layout options for labels.

Treat annotation geometry as part of the image coordinate system. That makes the overlay deterministic: the highlight rectangle, guide line, and label origin all describe exact positions on the final image. If you resize the image first, compute the annotation positions after resizing so the callouts still point at the right pixels.

```csharp
using SixLabors.Fonts;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = Image.Load<Rgba32>("photo.jpg");

Rectangle highlight = new(92, 64, 220, 140);
PointF labelOrigin = new(highlight.Right + 28, highlight.Top + 12);
Font font = SystemFonts.CreateFont("Arial", 24, FontStyle.Bold);
RichTextOptions labelOptions = new(font)
{
    Origin = labelOrigin,
    WrappingLength = 220
};

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.Gold.WithAlpha(0.22F)), highlight);
    canvas.Draw(Pens.Dash(Color.Gold, 5), highlight);

    // The guide line connects the label to the highlighted region without changing the image pixels underneath.
    canvas.DrawLine(
        Pens.Solid(Color.Gold, 3),
        new PointF(labelOrigin.X - 12, labelOrigin.Y + 12),
        new PointF(highlight.Right, highlight.Top + (highlight.Height / 2F)));

    canvas.DrawText(labelOptions, "Region of interest", Brushes.Solid(Color.White), Pens.Solid(Color.Black, 1.5F));
}));

image.Save("annotated.jpg");
```

Keep annotation geometry in image coordinates. If you need a local coordinate system for a panel or inset, use `CreateRegion(...)` or a saved transform.

Prefer translucent fills for highlighting because they preserve the source image context. Use an outline pen or text stroke when the annotation must remain readable over both light and dark image regions.

## Related Topics

- [Canvas Drawing](canvas.md)
- [Brushes and Pens](brushesandpens.md)
- [Transforms and Composition](transformsandcomposition.md)
