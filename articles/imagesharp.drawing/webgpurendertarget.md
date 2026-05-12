# WebGPU Offscreen Render Targets

[`WebGPURenderTarget`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPURenderTarget) owns an offscreen WebGPU texture. Use it when you want GPU drawing without a visible window, or when a GPU-rendered result must later be read back into an ImageSharp image.

Offscreen render targets are useful for render-to-texture workflows, GPU-generated assets, tests, benchmarks, previews, and pipelines that draw on the GPU before handing the final result back to CPU code.

## Create a Render Target

The simplest constructor uses the default `Rgba8Unorm` format:

```csharp
using SixLabors.ImageSharp.Drawing.Processing.Backends;

using WebGPURenderTarget target = new(640, 360);
```

Specify a format when the target must match another GPU workflow or readback pixel type:

```csharp
using SixLabors.ImageSharp.Drawing.Processing.Backends;

using WebGPURenderTarget target = new(WebGPUTextureFormat.Bgra8Unorm, 640, 360);
```

The target exposes `Width`, `Height`, `Bounds`, and `Format`. The bounds are always rooted at `(0, 0)` in target pixel coordinates.

## Draw Offscreen

Create a canvas, draw into it, and dispose the canvas to replay and submit the recorded work to the offscreen texture.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Drawing.Processing.Backends;

using WebGPURenderTarget target = new(640, 360);

using (DrawingCanvas canvas = target.CreateCanvas())
{
    // Canvas disposal replays the recorded drawing work into the GPU texture.
    canvas.Fill(Brushes.Solid(Color.White));
    canvas.FillEllipse(Brushes.Solid(Color.LightSkyBlue), new(320, 180), new(260, 140));
    canvas.DrawEllipse(Pens.Solid(Color.DarkSlateBlue, 4), new(320, 180), new(260, 140));
}
```

Use `CreateCanvas(DrawingOptions)` when the whole render pass should start with non-default drawing state.

## Read Back to ImageSharp

[`ReadbackImage()`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPURenderTarget.ReadbackImage*) creates a new CPU image from the current GPU texture contents.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing.Backends;
using SixLabors.ImageSharp.PixelFormats;

using Image<Rgba32> image = target.ReadbackImage<Rgba32>();
image.Save("webgpu-output.png");
```

The typed readback pixel type must match the target format:

| Target format | Typed readback |
|---|---|
| `Rgba8Unorm` | `ReadbackImage<Rgba32>()` |
| `Bgra8Unorm` | `ReadbackImage<Bgra32>()` |
| `Rgba8Snorm` | `ReadbackImage<NormalizedByte4>()` |
| `Rgba16Float` | `ReadbackImage<HalfVector4>()` |

The non-generic `ReadbackImage()` chooses the natural ImageSharp pixel type from the render target format.

## Read Back Into an Existing Buffer

Use [`ReadbackInto(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPURenderTarget.ReadbackInto*) when you already own the destination pixel buffer:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing.Backends;
using SixLabors.ImageSharp.PixelFormats;

using Image<Rgba32> destination = new(target.Width, target.Height);
target.ReadbackInto(destination.Frames.RootFrame.PixelBuffer.GetRegion());
```

If the destination region is smaller than the render target, the matching top-left portion is read back. This lets callers read into bounded regions without forcing an intermediate full-size image.

## Readback Cost

Readback is a synchronization point. The GPU work must be visible to the CPU, and the texture data must be copied into CPU memory. That cost is fine for final export, tests, snapshots, or occasional thumbnails. It is usually the wrong thing to do every frame in an interactive GPU render loop.

If the next stage is also GPU-owned, keep the result in a WebGPU render target or surface instead of reading it back to ImageSharp immediately.

## Related Topics

- [WebGPU](webgpu.md)
- [WebGPU Environment and Support](webgpuenvironment.md)
- [WebGPU Window Rendering](webgpuwindow.md)
- [WebGPU External Surfaces](webgpuexternalsurface.md)

## Practical Guidance

Use `WebGPURenderTarget` when the output should be GPU-rendered but not immediately presented to a window. Dispose the canvas before readback. Pick the texture format from the final consumer, and avoid readback in tight frame loops unless CPU pixels are genuinely required.
