# Images, Masks, and Processing

ImageSharp.Drawing can draw images through the canvas, use images as brushes, and run ImageSharp processors inside drawing regions. These features look similar because they all produce pixels from images, but they model different intent.

Use `DrawImage(...)` when you want to place a rectangular source image into a rectangular destination. Use an image brush when the image should behave like a fill for arbitrary geometry. Use `Apply(...)` when you need normal ImageSharp processors to affect the pixels visible at a specific point in the canvas timeline.

## Draw an Image

`DrawImage(...)` samples a source rectangle from an image and places it into a destination rectangle on the canvas. The source rectangle is expressed in source-image coordinates. The destination rectangle is expressed in canvas coordinates and is affected by the current transform and clip state.

The optional resampler is used when the selected source pixels have to be scaled into the destination. Bicubic is the default, so pass a sampler only when your output needs a different tradeoff such as sharper edges, smoother downsampling, or a specific product policy.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> source = Image.Load<Rgba32>("photo.jpg");
using Image<Rgba32> image = new(480, 300, Color.White.ToPixel<Rgba32>());

DrawingOptions clipInside = new()
{
    ShapeOptions = new()
    {
        BooleanOperation = BooleanOperation.Intersection
    }
};

EllipsePolygon clip = new(240, 150, 340, 190);

image.Mutate(ctx => ctx.Paint(canvas =>
{
    _ = canvas.Save(clipInside, clip);

    // The selected source pixels are scaled into the destination rectangle.
    canvas.DrawImage(source, new Rectangle(20, 10, 280, 180), new RectangleF(70, 54, 340, 190), KnownResamplers.Bicubic);
    canvas.Restore();

    canvas.Draw(Pens.Solid(Color.Black, 3), clip);
}));
```

Keep the source image alive until the canvas has replayed the command. With `Paint(...)`, that means the source must remain alive until `Mutate(...)` completes.

Choose the source rectangle in source-image coordinates and the destination rectangle in canvas coordinates. That separation is useful when you want to crop from a large source image while placing the selected pixels into a fixed layout region.

## Use an Image as a Brush

Use `ImageBrush<TPixel>` when an image should fill any path as a texture. This is different from `DrawImage(...)`: the brush supplies sampled image pixels, while the supplied path controls coverage. That makes image brushes useful for clipped portraits, textured text, patterned fills, masks, thumbnails inside arbitrary shapes, and repeated decorative elements.

An image brush references its source image. Keep the source alive until canvas replay has completed. If the same image is reused by several brushes or commands, own that lifetime outside the `Paint(...)` callback rather than disposing it in the middle of drawing.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> source = Image.Load<Rgba32>("photo.jpg");
using Image<Rgba32> image = new(420, 260, Color.White.ToPixel<Rgba32>());

StarPolygon star = new(x: 210, y: 130, prongs: 5, innerRadii: 62, outerRadii: 118);
RectangleF sourceRegion = new(0, 0, source.Width, source.Height);
ImageBrush<Rgba32> brush = new(source, sourceRegion, new Point(-120, -70));

image.Mutate(ctx => ctx.Paint(canvas =>
{
    // The star path controls coverage; the brush supplies the sampled image pixels.
    canvas.Fill(brush, star);
    canvas.Draw(Pens.Solid(Color.DarkSlateGray, 3), star);
}));
```

An image brush is best when the same texture should fill a shape, text path, or repeated decorative element. For one-off rectangular placement, `DrawImage(...)` is usually easier to reason about.

## Apply Processors Inside a Shape

`Apply(...)` runs normal ImageSharp processors inside a rectangle, path, or path builder. It is a replay barrier: commands before it affect the pixels being processed, and commands after it do not.

That makes `Apply(...)` a timeline tool, not just a clipping tool. Put it immediately after the pixels that should be processed. Draw crisp outlines, labels, or foreground objects after the barrier so they are not blurred, pixelated, color-adjusted, or otherwise processed with the background.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> source = Image.Load<Rgba32>("photo.jpg");
using Image<Rgba32> image = new(520, 320, Color.White.ToPixel<Rgba32>());

RectangleF destination = new(40, 38, 440, 244);
EllipsePolygon redaction = new(300, 168, 150, 96);

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.DrawImage(source, source.Bounds, destination, KnownResamplers.Bicubic);

    // Apply scopes the processor to the path; pixels outside the ellipse stay unchanged.
    canvas.Apply(redaction, region => region.Pixelate(10));
    canvas.Draw(Pens.Solid(Color.OrangeRed, 3), redaction);
}));
```

On GPU-backed canvases, `Apply(...)` requires the affected pixels to be read back, processed by the CPU pipeline, and written back before presentation. Keep regions as small as the effect allows.

The placement of `Apply(...)` matters. Commands recorded before it contribute pixels to the processor input; commands recorded after it are drawn over the processed result. This makes it possible to blur or pixelate an image region, then draw a crisp outline or label on top.

## Practical Guidance

Use `DrawImage(...)` when an image should be sampled from a source rectangle and placed into a destination rectangle. Use an image brush when the image should behave like a fill pattern inside arbitrary geometry. Those two APIs can produce similar-looking results, but they model different intent: placement versus shading.

The source image must remain alive until the canvas has replayed the command. In `Paint(...)`, that means through the end of the mutation pipeline. With manually-created canvases, it means until the canvas is disposed. Source rectangles are expressed in source-image coordinates; destination rectangles are expressed in canvas coordinates, so cropping and placement can be reasoned about independently.

`Apply(...)` is a timeline decision. Put it exactly where the processor should observe the image: commands before it contribute pixels to the processor input, and commands after it draw over the processed result. Keep processor regions tight, especially on GPU-backed canvases where readback may be required.
