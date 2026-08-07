# Clipping, Regions, and Layers

Canvas state controls where later commands can draw and how grouped commands are composed. The three main tools are `Save(...)` with clip paths, `CreateRegion(...)`, and `SaveLayer(...)`.

These APIs solve different problems and should not be treated as interchangeable:

- Use a clip when later commands should be constrained by vector geometry while staying in the current coordinate system.
- Use a region when you want a rectangular child canvas where `(0, 0)` means the region origin.
- Use a layer when several commands should render together into an isolated target and then composite back as one result.

## Clip Later Commands

`Save(DrawingOptions, params IPath[])` pushes a new state with the supplied options and clip paths. The clip paths are combined with each later command by `ShapeOptions.BooleanOperation`; they are not applied retroactively to commands already recorded.

The default boolean operation is `Difference`, which subtracts the clip path. For ordinary "draw inside this shape" clipping, set `BooleanOperation.Intersection`.

Think of clipping as a state scope. Save the clipped state immediately before the work that needs it, then restore as soon as that work is complete. That keeps borders, labels, shadows, and diagnostics from being clipped accidentally.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 260, Color.White.ToPixel<Rgba32>());

EllipsePolygon spotlight = new(210, 130, 300, 160);
DrawingOptions clipInside = new()
{
    ShapeOptions = new()
    {
        BooleanOperation = BooleanOperation.Intersection
    }
};

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.MidnightBlue));

    _ = canvas.Save(clipInside, spotlight);

    // The rectangle is larger than the ellipse; the saved state keeps only the intersection.
    canvas.Fill(Brushes.Horizontal(Color.Gold, Color.OrangeRed), new Rectangle(20, 40, 380, 180));
    canvas.Restore();

    canvas.Draw(Pens.Solid(Color.White, 3), spotlight);
}));
```

Use `Restore()` to pop the latest state, or `RestoreTo(saveCount)` when nested states must be unwound together.

## Region Canvases

`CreateRegion(...)` creates a child canvas with local coordinates inside a rectangular area. It is useful for controls, panels, tiles, thumbnails, and other sub-layouts where `(0, 0)` should mean the region origin.

A region is a coordinate convenience, not an independent render target. The child canvas shares the parent replay timeline, and the root canvas still owns final replay. Disposing the child region closes that local drawing scope; it does not render the whole image immediately.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(360, 220, Color.White.ToPixel<Rgba32>());

image.Mutate(ctx => ctx.Paint(canvas =>
{
    using DrawingCanvas region = canvas.CreateRegion(new Rectangle(70, 48, 220, 124));

    region.Fill(Brushes.Solid(Color.LightSeaGreen.WithAlpha(0.8F)), new Rectangle(10, 10, 120, 68));

    // Region-local coordinates are relative to the region, not the parent canvas.
    region.Draw(Pens.Solid(Color.DarkBlue, 5), new Rectangle(0, 0, 220, 124));
    region.DrawLine(Pens.Solid(Color.OrangeRed, 4), new PointF(0, 123), new PointF(219, 0));
}));
```

Nested regions can also have their own saved state. Use them when nested layout is clearer than constantly adding offsets to parent-canvas coordinates.

## Layers

`SaveLayer(...)` starts an isolated compositing scope. Commands drawn inside the layer render into that layer, then `Restore()` composites the layer back to the parent with the supplied `GraphicsOptions`.

Layer bounds limit the isolated target and final composition area. They do not shift the coordinate system. Commands inside a bounded layer still use the same local coordinates as the parent canvas, so the layer bounds should describe the affected area, not a new origin.

Use a layer when group behavior matters. Group opacity, group blending, and grouped masking are different from applying the same `GraphicsOptions` to each command independently. Without a layer, two semi-transparent shapes can blend with each other and the background one command at a time; with a layer, they first form one isolated result and then that result blends back once.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(360, 220, Color.White.ToPixel<Rgba32>());

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.SteelBlue), new Rectangle(24, 24, 312, 172));

    _ = canvas.SaveLayer(new GraphicsOptions { BlendPercentage = 0.55F }, new Rectangle(70, 46, 220, 128));

    // Layer bounds constrain compositing; these coordinates are still parent coordinates.
    canvas.FillEllipse(Brushes.Solid(Color.OrangeRed), new(180, 110), new(170, 96));
    canvas.Draw(Pens.Solid(Color.White, 8), new Rectangle(96, 74, 168, 72));
    canvas.Restore();

    canvas.Draw(Pens.Solid(Color.Black, 2), new Rectangle(70, 46, 220, 128));
}));
```

Use layers when a group of commands should blend back as one result. Without a layer, each command blends into the parent independently.

## Layer Effects

`SaveLayer(...)` overloads accept a [`LayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.LayerEffect) that transforms the layer content when the layer is restored. The layer isolates the content, so the effect operates on exactly what was drawn between `SaveLayer(...)` and `Restore()`, against transparency, before the result composites onto the canvas.

The built-in content effects are:

- [`BlurLayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.BlurLayerEffect) blurs the layer content with a Gaussian sigma.
- [`DropShadowLayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.DropShadowLayerEffect) slots a blurred, offset shadow beneath the layer content.
- [`GlowLayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.GlowLayerEffect) surrounds the content with a colored glow.
- [`InnerShadowLayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.InnerShadowLayerEffect) shades the content inside its own edges.
- [`ColorMatrixLayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.ColorMatrixLayerEffect) transforms the content colors through a `ColorMatrix`.

The layer bounds are expanded internally by the effect's reach, so blurred or offset output is not cut off.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(360, 220, Color.White.ToPixel<Rgba32>());

image.Mutate(ctx => ctx.Paint(canvas =>
{
    _ = canvas.SaveLayer(
        new GraphicsOptions(),
        new Rectangle(60, 40, 240, 140),
        new DropShadowLayerEffect(new Point(6, 6), 4F, Color.Black.WithAlpha(0.5F)));

    canvas.FillEllipse(Brushes.Solid(Color.OrangeRed), new(180, 110), new(90, 50));
    canvas.Restore();
}));
```

An overload accepts an `IPath` region instead of a rectangle. The effect then processes only pixels covered by the path, and its output lands on the path translated by the effect's offset.

## Backdrop Effects

A [`BackdropLayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.BackdropLayerEffect) filters the pixels already on the canvas beneath the layer's region. The filter runs when the layer is opened, the filtered result is clipped to the region, and the layer's content then renders above it. This is the CSS `backdrop-filter` model.

The built-in backdrop effects are:

- [`BackdropBlurLayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.BackdropBlurLayerEffect) blurs the backdrop, the classic frosted-glass base.
- [`BackdropAcrylicLayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.BackdropAcrylicLayerEffect) combines a blur with a tint color for acrylic panels.
- [`BackdropDropShadowLayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.BackdropDropShadowLayerEffect) casts a shadow from the backdrop content.
- [`BackdropColorMatrixLayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.BackdropColorMatrixLayerEffect) transforms backdrop colors through a `ColorMatrix`. Prebuilt variants cover brightness, contrast, grayscale, hue rotation, inversion, opacity, sepia, and saturation.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = Image.Load<Rgba32>("photo.jpg");

image.Mutate(ctx => ctx.Paint(canvas =>
{
    Rectangle panel = new(70, 46, 220, 128);

    _ = canvas.SaveLayer(
        new GraphicsOptions(),
        panel,
        new BackdropAcrylicLayerEffect(10F, Color.White.WithAlpha(0.3F)));

    // The backdrop inside the panel is already blurred and tinted.
    // Content drawn here renders above the filtered backdrop.
    canvas.Draw(Pens.Solid(Color.White, 2), panel);
    canvas.Restore();
}));
```

Content effects and backdrop effects answer different questions. Use a content effect when the drawing inside the layer needs the treatment. Use a backdrop effect when the pixels behind a panel need the treatment and the panel content must stay sharp.

## Practical Guidance

- Use clips when geometry should constrain later commands in the current coordinate space.
- Use regions when a child layout should have its own local origin.
- Use layers when several commands should blend back as one grouped result.
- Use a `LayerEffect` when the layer content needs blur, shadow, glow, or color treatment as a group.
- Use a `BackdropLayerEffect` when the pixels behind a region need treatment while the content on top stays sharp.
- Remember that layer bounds constrain composition but do not move the coordinate system.
- Restore saved state as soon as the scoped work is complete.
