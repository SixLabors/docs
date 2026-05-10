# Add a Text Watermark

Use `DrawText(...)` with alignment options when a watermark should stay anchored to an image edge. The text layout options keep the placement declarative, so you do not need to measure the string manually.

```csharp
using SixLabors.Fonts;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = Image.Load<Rgba32>("photo.jpg");

Font font = SystemFonts.CreateFont("Arial", 36, FontStyle.Bold);
RichTextOptions options = new(font)
{
    Origin = new(image.Width - 64, image.Height - 64),
    HorizontalAlignment = HorizontalAlignment.Right,
    VerticalAlignment = VerticalAlignment.Bottom
};

image.Mutate(ctx => ctx.Paint(canvas =>
{
    // Alignment anchors the watermark to the bottom-right corner without measuring the text first.
    canvas.DrawText(
        options,
        "© Six Labors",
        Brushes.Solid(Color.White.WithAlpha(0.72F)),
        Pens.Solid(Color.Black.WithAlpha(0.45F), 2));
}));

image.Save("watermarked.jpg");
```

Use a subtle fill alpha and a darker outline when the watermark must remain readable over mixed image content.

## Related Topics

- [Drawing Text](text.md)
- [Images, Masks, and Processing](imagesandprocessing.md)
