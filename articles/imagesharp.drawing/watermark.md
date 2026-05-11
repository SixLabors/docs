# Add a Text Watermark

Use `DrawText(...)` with alignment options when a watermark should stay anchored to an image edge. The text layout options keep the placement declarative, so you do not need to measure the string manually.

Anchor the watermark by choosing an origin near the desired edge, then set horizontal and vertical alignment relative to that origin. This keeps the code stable when the watermark text changes length or the image size changes.

Watermark placement should normally happen after the image has reached its final export size and orientation. If you resize after drawing the watermark, the text will be resampled with the image and may become soft. If you draw before `AutoOrient()`, the anchor can land in the wrong visual corner.

Readability is usually the hard part. A watermark that looks fine on one photo can disappear over another. Combining a semitransparent fill with a subtle contrasting stroke gives the text a chance to remain readable over both light and dark regions without making it dominate the image.

Think of watermark styling as an accessibility problem, not only a branding problem. The fill alpha controls how strongly the watermark competes with the photo. The outline pen protects glyph edges against local contrast changes. The font size and wrapping length should be chosen for the final export dimensions, not for the original camera image size.

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

Use a subtle fill alpha and a darker outline when the watermark must remain readable over mixed image content. If the watermark can contain user-supplied text, set `WrappingLength` and use alignment rather than assuming a fixed string width.

For repeated export workflows, create the font and text options once per image size, then draw inside the `Paint(...)` callback. Use wrapping when the watermark can contain user or tenant names that may be longer than expected.

## Related Topics

- [Drawing Text](text.md)
- [Images, Masks, and Processing](imagesandprocessing.md)

## Practical Guidance

Use alignment options to anchor watermarks instead of manual text-size guesses. Normalize orientation and resize before positioning watermarks for export, then recreate text options when the image size, font size, wrapping, or origin changes. Use a fill alpha and outline that remain readable on both light and dark image regions.
