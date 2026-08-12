# Layer and Backdrop Effects

`SaveLayer(...)` isolates a group of drawing commands into a compositing layer. An effect transforms that layer as part of the same operation: blur it, shadow it, recolor it, or filter the pixels behind it. This page covers the built-in effects, the GPU shader implementations, and how to build your own. For the layer model itself, see [Clipping, Regions, and Layers](clippingregionslayers.md).

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

## Custom Effects

Both effect families are open for extension. Pass the [`LayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.LayerEffect) base constructor an operation that implements your effect through image processing, then override the members that describe its behavior:

- Override [`Reach`](xref:SixLabors.ImageSharp.Drawing.Processing.LayerEffect.Reach) when the effect pushes content beyond its source region. Layer and processing bounds expand by this distance, so the output is not cut off.
- Override [`WriteBackOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.LayerEffect.WriteBackOptions) and [`WriteBackOffset`](xref:SixLabors.ImageSharp.Drawing.Processing.LayerEffect.WriteBackOffset) when the result must composite back with specific graphics options or at an offset, as a drop shadow does.
- Override [`IsPassThrough`](xref:SixLabors.ImageSharp.Drawing.Processing.LayerEffect.IsPassThrough) so a no-op configuration skips processing entirely.

Derive from [`BackdropLayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.BackdropLayerEffect) in the same way to filter the pixels behind a region. Backdrop effects clip to their region, so their reach is always zero.

The operation can implement any per-pixel logic. `ProcessPixelRowsAsVector4(...)` overloads that take a `PixelRowOperation<Point>` supply each row's start coordinate, so position-dependent effects such as vignettes and scanlines are possible too.

This posterize effect quantizes each color channel with its own per-pixel logic. ImageSharp has no such processor, so the operation implements the math directly:

```csharp
using System.Numerics;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Processing;

// Quantizes each color channel to a fixed number of levels.
public sealed class PosterizeLayerEffect : LayerEffect
{
    private readonly int levels;

    public PosterizeLayerEffect(int levels)
        : base(ctx => ctx.ProcessPixelRowsAsVector4(row =>
        {
            float steps = levels - 1;
            for (int i = 0; i < row.Length; i++)
            {
                Vector4 pixel = row[i];
                Vector3 quantized = new Vector3(
                    MathF.Round(pixel.X * steps),
                    MathF.Round(pixel.Y * steps),
                    MathF.Round(pixel.Z * steps)) / steps;
                row[i] = new Vector4(quantized, pixel.W);
            }
        }))
        => this.levels = levels;

    // Quantizing to 256 or more levels leaves 8-bit content unchanged.
    public override bool IsPassThrough => this.levels >= 256;
}
```

An effect authored this way runs its operation on every backend. On a WebGPU canvas, that means a CPU round trip for the effect step. The next section removes that cost.

## GPU Shader Effects

The WebGPU package ships shader-backed versions of the built-in set: [`WebGPUGaussianBlurLayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUGaussianBlurLayerEffect), [`WebGPUDropShadowLayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUDropShadowLayerEffect), [`WebGPUGlowLayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUGlowLayerEffect), [`WebGPUInnerShadowLayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUInnerShadowLayerEffect), and [`WebGPUColorMatrixLayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUColorMatrixLayerEffect), with matching backdrop variants. These execute as WGSL shader passes, so the effect stays on the GPU. Each carries the equivalent CPU effect as a built-in fallback, so one instance renders correctly on both backends.

Custom GPU effects follow the same pattern. Derive from [`WebGPUShaderLayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUShaderLayerEffect) for layer content, or [`WebGPUBackdropShaderLayerEffect`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUBackdropShaderLayerEffect) for backdrops. The base constructor takes complete WGSL source, a [`WebGPUShaderUniformLayout`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUShaderUniformLayout) describing the named uniform values, and the CPU fallback: either an ImageSharp processing operation or an equivalent `LayerEffect`.

### The Shader Contract

The source must define the entry point `fn layer_effect(position: vec2<f32>) -> vec4<f32>`. The position uses effect-local pixel-center coordinates. The return value is associated-alpha RGBA in `[0, 1]`.

ImageSharp generates a prelude around your source. It provides these functions for reading the effect input:

| Function | Behavior |
|---|---|
| `layer_load(position: vec2<i32>) -> vec4<f32>` | Loads one texel with associated alpha. Positions outside the valid input region return transparent black. |
| `layer_load_unassociated(position: vec2<i32>) -> vec4<f32>` | Loads one texel with the alpha unassociated, for math on straight color values. |
| `layer_sample(position: vec2<f32>) -> vec4<f32>` | Samples with bilinear filtering at a pixel-center position, honoring the pass's border wrapping modes. |

The prelude also declares two uniform structures:

- `imagesharp_framework` carries the geometry of the input: `imagesharp_input_size`, `imagesharp_valid_min`, and `imagesharp_valid_max`, all `vec2<i32>`.
- `imagesharp_uniforms` carries the fields you declare through [`WebGPUShaderUniformLayout`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUShaderUniformLayout). Each [`WebGPUShaderUniform`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUShaderUniform) declares a name, a type (`Float32`, `Int32`, `UInt32`, `Vector2`, `Vector3`, `Vector4`, or `Matrix4x4`), and an element count for arrays. The layout is capped at 64 KiB.

### Passes

Each source defines one complete shader pass. The protected `AddShaderPass(...)` method adds an ordered invocation and assigns its uniform values through a [`WebGPUShaderUniformBuilder`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUShaderUniformBuilder), with typed setters such as `SetFloat32(...)`, `SetVector2(...)`, and `SetMatrix4x4(...)`. An overload sets the horizontal and vertical `BorderWrappingMode` for the pass's filtered samples. Each pass receives the preceding pass's output as its input. The built-in Gaussian blur runs as two separable passes this way.

### A Complete Dual-Backend Effect

This GPU version of the posterize effect implements the same math in WGSL and reuses the CPU class as its fallback. One type renders on both backends:

```csharp
using SixLabors.ImageSharp.Drawing.Processing.Backends;

// Posterizes on the GPU, falling back to PosterizeLayerEffect on the CPU.
public sealed class WebGPUPosterizeLayerEffect : WebGPUShaderLayerEffect
{
    private const string ShaderSource = """
        fn layer_effect(position: vec2<f32>) -> vec4<f32> {
            let source = layer_load_unassociated(vec2<i32>(position));
            let steps = imagesharp_uniforms.levels - 1.0;
            let quantized = round(source.rgb * steps) / steps;

            // Return associated-alpha RGBA.
            return vec4<f32>(quantized * source.a, source.a);
        }
        """;

    public WebGPUPosterizeLayerEffect(int levels)
        : base(
            new PosterizeLayerEffect(levels),
            ShaderSource,
            new WebGPUShaderUniformLayout([new WebGPUShaderUniform("levels", WebGPUShaderUniformType.Float32, 1)]))
        => this.AddShaderPass(uniforms => uniforms.SetFloat32("levels", levels));
}
```

Shader pipelines compile on first use. Call [`WebGPUDeviceContext.Precompile(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUDeviceContext.Precompile*) during startup when the first frame must not pay that cost.

## Practical Guidance

- Use a content effect when the drawing inside the layer needs the treatment.
- Use a backdrop effect when the pixels behind a region need the treatment while the content on top stays sharp.
- Derive from the shader base classes for effects that render on GPU canvases, and supply the CPU fallback for everything else.
- Declare an accurate `Reach` for spreading effects, so nothing is clipped.
- Precompile custom shader effects when startup can absorb the cost and the first frame cannot.

## Related Topics

- [Clipping, Regions, and Layers](clippingregionslayers.md)
- [Canvas Drawing](canvas.md)
- [WebGPU](webgpu.md)
