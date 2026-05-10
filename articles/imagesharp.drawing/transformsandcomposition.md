# Transforms and Composition

`DrawingOptions` carries the transform, graphics options, and shape options used by canvas commands. Use it when drawing state should change for a group of operations.

## Transform Drawing

`DrawingOptions.Transform` is applied to vector output before rasterization. For strokes, the path is stroked in local geometry space and the generated outline is transformed for drawing.

## Why Matrix4x4?

ImageSharp.Drawing is a 2D drawing library, but it uses `Matrix4x4` for transforms so the same drawing state can represent both ordinary 2D affine transforms and projective transforms.

For normal drawing, construct the value from `Matrix3x2`. That keeps rotation, scale, skew, and translation code familiar:

```csharp
Matrix4x4 transform = new(Matrix3x2.CreateRotation(angle, center));
```

Use the full `Matrix4x4` form when you need transforms that cannot be expressed by `Matrix3x2`, such as perspective-style projection. The canvas, path, text, brush, image, and WebGPU paths all carry the same transform type, so code can move between CPU drawing, retained scenes, and GPU rendering without changing the public drawing model.

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
    Transform = new Matrix4x4(Matrix3x2.CreateRotation(0.32F, new Vector2(210, 130)))
};

RectangularPolygon panel = new(92, 70, 236, 120);

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

`GraphicsOptions` controls antialiasing, color blending, alpha composition, and blend percentage.

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
    canvas.Fill(Brushes.Solid(Color.Red.WithAlpha(0.5F)), new EllipsePolygon(194, 120, 124, 92));
    canvas.Restore();
}));
```

Use `SaveLayer(...)` when the blend should apply to a group as a single composited result. Use plain `Save(...)` when each command should blend independently.

## Antialiasing

Turn antialiasing off when exact integer coverage matters, such as low-resolution masks or pixel-art-style output. Leave it on for normal vector graphics.

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
