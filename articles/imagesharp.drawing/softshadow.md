# Create a Soft Shadow

Draw the shadow shape first, then apply a blur to the shadow region before drawing the foreground object. `Apply(...)` is a replay barrier, so only commands recorded before the barrier are processed.

The blur region should be larger than the original shadow shape. Gaussian blur spreads pixels outward, so using the exact shape bounds clips the soft edge. A good rule of thumb is to expand the processing rectangle by at least the blur radius on every side.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 240, Color.White.ToPixel<Rgba32>());

Rectangle shadowOffsetBounds = new(70, 72, 280, 110);
Rectangle blurBounds = new(60, 62, 300, 130);
Rectangle panelBounds = new(62, 58, 280, 110);

image.Mutate(ctx => ctx.Paint(canvas =>
{
    // The shadow is intentionally offset from the panel before the blur spreads it outward.
    canvas.Fill(Brushes.Solid(Color.Black.WithAlpha(0.35F)), shadowOffsetBounds);

    // Apply seals earlier drawing commands before the blur is replayed, and the expanded region preserves the feathered edge.
    canvas.Apply(blurBounds, region => region.GaussianBlur(10));

    canvas.Fill(Brushes.Solid(Color.White), panelBounds);
    canvas.Draw(Pens.Solid(Color.LightGray, 1), panelBounds);
}));

image.Save("shadow.png");
```

Keep the blur region tight. On CPU canvases this reduces the amount of image data processed, and on GPU-backed canvases it reduces readback and upload work.

Use `SaveLayer(...)` instead when the foreground and shadow need to be composed as one group over existing content. Use `Apply(...)` when you want a normal ImageSharp processor, such as blur, pixelation, or color adjustment, to affect only part of the drawing timeline.

## Related Topics

- [Canvas Drawing](canvas.md)
- [Images, Masks, and Processing](imagesandprocessing.md)
- [Transforms and Composition](transformsandcomposition.md)
