# Troubleshooting

This page collects common issues you can hit when moving from simple drawing samples to full ImageSharp.Drawing pipelines. Most problems come from three areas: deferred canvas replay, clipping and fill-rule choices, or text layout state.

If the issue is WebGPU-specific, start with the WebGPU section below and then check the dedicated [WebGPU](webgpu.md) page.

## Nothing Appears on the Image

If you are drawing through `image.Mutate(ctx => ctx.Paint(...))`, the processing pipeline owns the canvas lifetime and replays the recorded drawing commands for you.

If you create a canvas manually, make sure the canvas is disposed or flushed before you inspect the destination image. Canvas drawing is recorded and replayed in order, so pending commands are not visible until the canvas replays them.

```csharp
using Image<Rgba32> image = new(400, 240, Color.White.ToPixel<Rgba32>());

using (DrawingCanvas canvas = image.CreateCanvas())
{
    canvas.Fill(Color.CornflowerBlue, new Rectangle(40, 40, 180, 100));

    // Disposing the canvas replays the recorded drawing commands onto the image.
}

image.Save("output.png");
```

When you use images as drawing sources, keep those source images alive until the canvas has replayed. `DrawImage` and `ImageBrush<TPixel>` record the drawing operation; they do not make the source image safe to dispose before replay.

## Clipping Removes the Wrong Area

`ShapeOptions.BooleanOperation` controls how the clip shape combines with the current drawing region. The default value is `Difference`, which subtracts the supplied shape from the current region. For the usual "draw only inside this shape" behavior, set it to `BooleanOperation.Intersection`.

```csharp
DrawingOptions options = new()
{
    ShapeOptions = new()
    {
        // Intersect keeps the part of subsequent drawing inside the clip shape.
        BooleanOperation = BooleanOperation.Intersection
    }
};

PointF clipCenter = new(200, 120);
SizeF clipSize = new(260, 160);
EllipsePolygon clip = new(clipCenter, clipSize);

canvas.Save(options, clip);
canvas.Fill(Color.HotPink, new Rectangle(0, 0, 400, 240));
canvas.Restore();
```

Use `Save(...)` for scoped clipping and state changes. Call `Restore()` when the scoped operation is complete so later drawing returns to the previous state.

## Holes or Overlaps Fill Unexpectedly

The fill rule controls how overlapping contours inside a complex polygon are interpreted. ImageSharp.Drawing defaults to `IntersectionRule.NonZero`, which matches the default used by SVG and web canvas APIs. With `NonZero`, contour winding order is meaningful, so holes are normally expressed by reversing the winding of the inner contour.

Use `IntersectionRule.EvenOdd` when you want parity-based filling where each crossing toggles between inside and outside. This can be convenient for imported geometry that does not carry reliable winding direction.

```csharp
DrawingOptions options = new()
{
    ShapeOptions = new()
    {
        // EvenOdd treats alternating contours as filled and unfilled regions.
        IntersectionRule = IntersectionRule.EvenOdd
    }
};

canvas.Fill(options, Color.MediumSeaGreen, complexPolygon);
```

## Text Is Not Centered Where Expected

For region-based text layout, use the text alignment options instead of manually subtracting measured text sizes. The `Origin` is the layout anchor, `WrappingLength` defines the line width, and `HorizontalAlignment` / `VerticalAlignment` place the text block relative to that anchor.

`TextAlignment` controls how wrapped lines are aligned inside the paragraph. `HorizontalAlignment` controls how the resulting paragraph bounds are positioned relative to `Origin`.

## Styled Text Affects the Wrong Characters

Rich text runs use grapheme indices, not UTF-16 code unit indices. `Start` is inclusive and `End` is exclusive, so the affected range is `[Start, End)`.

This matters for emoji, combining marks, flags, and other user-perceived characters that can contain multiple Unicode scalar values. See the Fonts [Unicode](../fonts/unicode.md) page for the same indexing model.

## Processors Run Before Earlier Drawing

Canvas operations are ordered, but image processors operate at replay barriers. If you need a processor such as blur, opacity, or a mask operation to include drawing that has already been recorded, flush the canvas before applying the processor.

```csharp
canvas.Fill(Color.Black, shadowShape);

// Flush seals the shadow geometry before the blur processor is applied.
canvas.Flush();
canvas.Apply(x => x.GaussianBlur(8));
```

This is most useful when you mix vector drawing with ImageSharp processors in the same canvas sequence.

## Images, Brushes, or Masks Stop Working After Disposal

Drawing commands can be replayed later than the point where the command is recorded. Keep any source `Image<TPixel>` used by `DrawImage`, masks, or `ImageBrush<TPixel>` alive until the canvas has been disposed or flushed.

The canvas does not own images passed into it. Dispose those images after the drawing scope that uses them has completed.

## WebGPU Produces a Blank Frame

Probe WebGPU support before creating GPU-backed drawing resources. WebGPU depends on the runtime environment, adapter, device, texture format, and browser or native surface.

For window or surface rendering, acquire a frame, draw into its canvas, and dispose the frame. Disposing the frame completes the drawing scope and presents it to the surface.

```csharp
if (!surface.TryAcquireFrame(out WebGPUSurfaceFrame frame))
{
    return;
}

using (frame)
{
    DrawingCanvas canvas = frame.CreateCanvas();

    // Drawing commands are presented when the frame is disposed.
    canvas.Clear(Color.White);
    canvas.Fill(Color.SteelBlue, new Rectangle(40, 40, 180, 120));
}
```

Resize the `WebGPUExternalSurface` when the framebuffer size changes. If you need to read pixels back to the CPU, use a pixel type that matches the target texture format, for example `Rgba32` with an `Rgba8Unorm` target.

## A Good Debugging Order

1. Confirm the canvas scope is disposed or flushed before checking the output.
2. Check source image lifetimes when using image brushes, masks, or `DrawImage`.
3. Check `ShapeOptions.BooleanOperation` when clipping.
4. Check `ShapeOptions.IntersectionRule` and contour winding for complex polygons.
5. Check text layout options before doing manual measurement math.
6. Check grapheme-based `[Start, End)` indices for rich text runs.
7. Probe WebGPU availability and surface frame acquisition before drawing GPU content.

## Related Topics

- [Canvas Drawing](canvas.md)
- [Clipping, Regions, and Layers](clippingregionslayers.md)
- [Paths and Shapes](pathsandshapes.md)
- [Drawing Text](text.md)
- [WebGPU](webgpu.md)
