# Create a Soft Shadow

Draw the shadow shape first, then apply a blur to the shadow region before drawing the foreground object. `Apply(...)` is a replay barrier, so only commands recorded before the barrier are processed.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 240, Color.White.ToPixel<Rgba32>());

Rectangle shadowBounds = new(70, 72, 280, 110);
Rectangle panelBounds = new(62, 58, 280, 110);

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.Black.WithAlpha(0.35F)), shadowBounds);

    // Apply seals earlier drawing commands before the blur is replayed.
    canvas.Apply(shadowBounds, region => region.GaussianBlur(10));

    canvas.Fill(Brushes.Solid(Color.White), panelBounds);
    canvas.Draw(Pens.Solid(Color.LightGray, 1), panelBounds);
}));

image.Save("shadow.png");
```

Keep the blur region tight. On CPU canvases this reduces the amount of image data processed, and on GPU-backed canvases it reduces readback and upload work.

## Related Topics

- [Canvas Drawing](canvas.md)
- [Images, Masks, and Processing](imagesandprocessing.md)
- [Transforms and Composition](transformsandcomposition.md)
