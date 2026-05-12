# Transforms and Composition

[`DrawingOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingOptions) carries the transform, graphics options, and shape options used by canvas commands. Use it when drawing state should change for a group of operations.

The safest way to think about transforms and composition is as scoped canvas state. Save the options that should affect a group, draw the affected commands, then restore the previous state before drawing labels, guides, or other unaffected output.

`DrawingOptions` is not a styling object like a brush or pen. It describes how later drawing commands are interpreted by the canvas: where their geometry lands, how their coverage is rasterized, how their pixels combine with existing pixels, and how fill or clip geometry is interpreted. That is why the same options object can affect fills, strokes, text, images, clips, layers, and image-processing barriers.

## Transform Drawing

`DrawingOptions.Transform` is applied to vector output before rasterization. Paths, shapes, text glyph geometry, generated stroke outlines, and clip paths are prepared with the active transform before the backend receives the command. The source geometry still starts in the local coordinate system you wrote in the code; the transform is part of the saved canvas state that converts that local geometry into final drawing space.

For strokes, the pen first generates an outline from the source path in local geometry space, then the active transform is applied to that generated outline. That means a scaled drawing state affects the visible stroke as well as the path it follows. If you need a shape to move or rotate while keeping a screen-constant outline width, draw the fill inside transformed state, restore, then draw the outline separately in parent coordinates.

## Why Matrix4x4?

ImageSharp.Drawing is a 2D drawing library, but it uses `Matrix4x4` for transforms so the same drawing state can represent both ordinary 2D affine transforms and projective transforms.

For normal drawing, construct the value from `Matrix3x2`. That keeps rotation, scale, skew, and translation code familiar:

```csharp
Matrix4x4 transform = new(Matrix3x2.CreateRotation(angle, center));
```

When more than one 2D operation is needed, compose the `Matrix3x2` expression first and wrap the final result in `Matrix4x4`. Keeping the 2D operations together makes order explicit and avoids hand-written matrix values for ordinary scale, rotate, skew, and translate cases.

Use the full `Matrix4x4` form when you need transforms that cannot be expressed by `Matrix3x2`, such as perspective-style projection. The canvas, path, text, brush, image, and WebGPU paths all carry the same transform type, so code can move between CPU drawing, retained backend scenes, and GPU rendering without changing the public drawing model.

```csharp
using System.Numerics;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 260, Color.White.ToPixel<Rgba32>());

DrawingOptions rotated = new()
{
    Transform = new(Matrix3x2.CreateRotation(0.32F, new Vector2(210, 130)))
};

Rectangle panel = new(92, 70, 236, 120);

image.Mutate(ctx => ctx.Paint(canvas =>
{
    _ = canvas.Save(rotated);

    // Both the fill and stroke use the saved transform.
    canvas.Fill(Brushes.Solid(Color.LightSkyBlue), panel);
    canvas.Draw(Pens.Solid(Color.MidnightBlue, 5), panel);
    canvas.Restore();

    canvas.Draw(Pens.Dot(Color.Gray, 2), panel);
}));
```

Transforms also apply to clipped drawing. When you save transformed options with clip paths, the command geometry and clip geometry are prepared so the backend receives consistent clipped output.

## Blend and Composite

`GraphicsOptions` answers four separate questions for each command:

- `Antialias` controls coverage at geometry edges. When enabled, edge pixels can receive fractional coverage for smoother vector output. When disabled, coverage is thresholded to fully covered or not covered using `AntialiasThreshold`.
- `BlendPercentage` scales the strength of the drawing operation. `1F` applies the command at full strength, `0F` makes it invisible, and values in between behave like operation opacity.
- `ColorBlendingMode` controls how source and destination color channels are combined where the command draws. `Normal` uses ordinary alpha blending. Modes such as `Multiply`, `Screen`, `Overlay`, `Darken`, and `Lighten` are useful for tinting, shadows, highlights, and visual effects.
- `AlphaCompositionMode` controls how source and destination alpha are combined using Porter-Duff composition rules. The default `SrcOver` draws the new source over existing pixels. Modes such as `Src`, `Clear`, `DestIn`, and `DestOut` are useful for replacement, erasing, masks, and cutouts.

Those settings are per-command canvas state when you use `Save(...)`. If two shapes are drawn under a saved `GraphicsOptions`, each one blends independently with the destination. Use `SaveLayer(...)` when several commands should first render together into an isolated layer and then blend back as one group.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(360, 240, Color.White.ToPixel<Rgba32>());

DrawingOptions multiply = new()
{
    GraphicsOptions = new()
    {
        ColorBlendingMode = PixelColorBlendingMode.Multiply,
        AlphaCompositionMode = PixelAlphaCompositionMode.SrcOver,
        BlendPercentage = 0.85F
    }
};

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.DarkBlue), new Rectangle(24, 88, 312, 60));

    _ = canvas.Save(multiply);

    // The saved GraphicsOptions affect commands recorded until Restore.
    canvas.Fill(Brushes.Solid(Color.HotPink), new Rectangle(100, 32, 110, 176));
    canvas.FillEllipse(Brushes.Solid(Color.Red.WithAlpha(0.5F)), new(194, 120), new(124, 92));
    canvas.Restore();
}));
```

The example uses `Multiply` to darken overlapping colors while leaving alpha composition as `SrcOver`, so the new shapes still draw over the existing background. `BlendPercentage` reduces the strength of the whole operation without changing the source color values in the code.

Use `SaveLayer(...)` when the blend should apply to a group as a single composited result. Use plain `Save(...)` when each command should blend independently. This distinction is important for group opacity: two semi-transparent shapes drawn independently will overlap each other; the same shapes drawn inside a layer can be composited once as a single group.

## Antialiasing

Antialiasing is about edge coverage, not color choice. With antialiasing enabled, partially covered edge pixels receive partial coverage so diagonal and curved edges look smooth. With antialiasing disabled, those fractional coverage values are compared with `AntialiasThreshold`; pixels above the threshold are kept, and pixels below it are discarded.

Turn antialiasing off when exact binary coverage matters, such as low-resolution masks, hit-test masks, generated sprite masks, or pixel-art-style output. Leave it on for normal vector graphics, text, badges, diagrams, and annotations. Lowering `AntialiasThreshold` can preserve thin features when antialiasing is disabled, while raising it makes binary output more conservative.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(80, 80, Color.Black.ToPixel<Rgba32>());
DrawingOptions aliased = new()
{
    GraphicsOptions = new()
    {
        Antialias = false
    }
};

image.Mutate(ctx => ctx.Paint(aliased, canvas =>
{
    // With antialiasing disabled, integer rectangle corners render as full covered pixels.
    canvas.Fill(Brushes.Solid(Color.White), new Rectangle(10, 10, 44, 28));
}));
```

## Practical Guidance

- Treat transforms and graphics options as scoped canvas state.
- Compose ordinary 2D transforms with `Matrix3x2`, then wrap the final value in `Matrix4x4`.
- Draw diagnostic bounds outside transformed state when you need parent-coordinate references.
- Use `SaveLayer(...)` for group opacity or group blending; use `Save(...)` for per-command state.
- Leave antialiasing enabled for normal vector graphics and disable it only for exact pixel coverage.
