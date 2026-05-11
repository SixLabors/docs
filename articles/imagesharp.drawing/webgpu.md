# WebGPU

ImageSharp.Drawing.WebGPU provides a GPU-backed drawing target for the same [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas) API used by the CPU image pipeline.

Use the WebGPU package when you want ImageSharp.Drawing to render into a native WebGPU surface or an offscreen GPU texture. Use the regular ImageSharp.Drawing package when you want to draw directly into an `Image<TPixel>` on the CPU.

## What WebGPU Is

WebGPU is a modern, explicit GPU API. It gives an application access to a graphics adapter, a device, command queues, textures, buffers, shaders, and presentation surfaces. It is conceptually similar to modern native graphics APIs such as Vulkan, Metal, and Direct3D 12, but it exposes a portable WebGPU programming model.

In ImageSharp.Drawing, WebGPU is not a browser feature. It is a native rendering backend used by .NET applications through the `SixLabors.ImageSharp.Drawing.WebGPU` package. The package creates or attaches to native WebGPU surfaces, records [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas) commands, lowers those commands into GPU work, and renders them into a WebGPU texture.

The most important difference from normal ImageSharp drawing is the destination:

- normal ImageSharp.Drawing draws into CPU image memory
- ImageSharp.Drawing.WebGPU draws into GPU textures and surfaces

Use WebGPU when the destination is interactive, GPU-owned, or repeatedly redrawn. Use the CPU path when you need simple image generation, server-side processing, format encoding, or direct pixel access after every operation.

## How ImageSharp.Drawing Uses WebGPU

The WebGPU backend keeps the public drawing model the same. You still draw with [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas), [`Brush`](xref:SixLabors.ImageSharp.Drawing.Processing.Brush), [`Pen`](xref:SixLabors.ImageSharp.Drawing.Processing.Pen), [`IPath`](xref:SixLabors.ImageSharp.Drawing.IPath), [`RichTextOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.RichTextOptions), layers, clips, and retained scenes.

The difference is what happens when the canvas flushes or is disposed:

1. The canvas prepares the recorded drawing commands.
2. The WebGPU backend creates a retained GPU scene from those commands.
3. The backend creates render-scoped WebGPU resources.
4. GPU compute/render work rasterizes the scene into the target texture.
5. Window and external-surface frames are presented when the frame is disposed.

That means WebGPU drawing is still deferred like the rest of the canvas API. The canvas callback is where you record work. Canvas or frame disposal is where the recorded work is submitted to the target.

## Public WebGPU Types

The public WebGPU API is target-first.

- [`WebGPUEnvironment`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUEnvironment) probes support and configures the library-managed WebGPU environment before first use.
- [`WebGPUWindow`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUWindow) owns a native window, WebGPU surface, device resources, and render loop.
- [`WebGPUExternalSurface`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUExternalSurface) attaches to a native drawable owned by another toolkit or host application.
- [`WebGPURenderTarget`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPURenderTarget) owns an offscreen GPU texture and can read it back into an ImageSharp image.
- [`WebGPUSurfaceFrame`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUSurfaceFrame) represents one acquired presentable frame. Dispose it to render and present the frame.

Most application code should start by choosing the target type. You do not normally create devices, queues, or command encoders yourself.

## Installation

Install the WebGPU package alongside ImageSharp.Drawing.

The package restores the managed WebGPU interop and native WebGPU runtime dependencies it needs. Applications still need a machine and driver stack capable of creating a WebGPU adapter, device, queue, and compute pipeline.

# [Package Manager](#tab/tabid-1)

```bash
PM > Install-Package SixLabors.ImageSharp.Drawing.WebGPU -Version VERSION_NUMBER
```

# [.NET CLI](#tab/tabid-2)

```bash
dotnet add package SixLabors.ImageSharp.Drawing.WebGPU --version VERSION_NUMBER
```

# [PackageReference](#tab/tabid-3)

```xml
<PackageReference Include="SixLabors.ImageSharp.Drawing.WebGPU" Version="VERSION_NUMBER" />
```

# [Paket CLI](#tab/tabid-4)

```bash
paket add SixLabors.ImageSharp.Drawing.WebGPU --version VERSION_NUMBER
```

***

## Check WebGPU Support

Use [`WebGPUEnvironment`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUEnvironment) when an application needs to check support before constructing a WebGPU window, external surface, or render target.

```csharp
using SixLabors.ImageSharp.Drawing.Processing.Backends;

WebGPUEnvironment.Options = new()
{
    PowerPreference = WebGPUPowerPreference.HighPerformance
};

WebGPUEnvironmentError availability = WebGPUEnvironment.ProbeAvailability();
if (availability != WebGPUEnvironmentError.Success)
{
    return;
}

WebGPUEnvironmentError compute = WebGPUEnvironment.ProbeComputePipelineSupport();
if (compute != WebGPUEnvironmentError.Success)
{
    return;
}
```

Assign [`WebGPUEnvironment.Options`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUEnvironment.Options) before any other WebGPU object is created. The library-managed WebGPU environment is initialized on first use.

`ProbeAvailability()` checks whether the package can initialize the WebGPU API, create an instance, acquire an adapter, acquire a device, and get the default queue. `ProbeComputePipelineSupport()` checks whether the acquired device can create a trivial compute pipeline. The compute-pipeline probe is useful because the drawing backend depends on compute work for the staged raster pipeline.

The result is a [`WebGPUEnvironmentError`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUEnvironmentError). `Success` is the only successful value. Other values tell you which step failed, such as API initialization, adapter acquisition, device acquisition, queue acquisition, or compute-pipeline creation.

```csharp
using SixLabors.ImageSharp.Drawing.Processing.Backends;

static bool TryUseWebGPU()
{
    WebGPUEnvironmentError availability = WebGPUEnvironment.ProbeAvailability();
    if (availability != WebGPUEnvironmentError.Success)
    {
        Console.WriteLine($"WebGPU unavailable: {availability}");
        return false;
    }

    WebGPUEnvironmentError compute = WebGPUEnvironment.ProbeComputePipelineSupport();
    if (compute != WebGPUEnvironmentError.Success)
    {
        Console.WriteLine($"WebGPU compute unavailable: {compute}");
        return false;
    }

    return true;
}
```

Configure `WebGPUEnvironment.UncapturedError` if you want to log native WebGPU validation or device errors. The callback may be invoked from a native WebGPU callback thread, so keep it short and non-blocking.

```csharp
using SixLabors.ImageSharp.Drawing.Processing.Backends;

WebGPUEnvironment.UncapturedError = (errorType, message) =>
{
    Console.Error.WriteLine($"{errorType}: {message}");
};
```

## Texture Formats

WebGPU targets have a concrete texture format. The supported formats are:

- `Rgba8Unorm`, mapped to `Rgba32`
- `Bgra8Unorm`, mapped to `Bgra32`
- `Rgba8Snorm`, mapped to `NormalizedByte4`
- `Rgba16Float`, mapped to `HalfVector4`

Use the default `Rgba8Unorm` unless you have a reason to match another host surface format or readback pixel type.

```csharp
using SixLabors.ImageSharp.Drawing.Processing.Backends;

WebGPUWindowOptions options = new()
{
    Format = WebGPUTextureFormat.Rgba8Unorm
};
```

For readback, the ImageSharp pixel type must match the render target format. For example, `Rgba8Unorm` reads back naturally as `Image<Rgba32>`, and `Bgra8Unorm` reads back naturally as `Image<Bgra32>`.

## Present Modes

Window and external-surface targets present completed frames to a display. `WebGPUPresentMode` controls how frames wait for that display.

- `Fifo` is the safest default. It is v-synced and avoids tearing.
- `Immediate` presents as soon as possible and can tear.
- `Mailbox` keeps newer frames over older queued frames when supported by the backend and platform.

Use `Fifo` for most applications. Use `Immediate` or `Mailbox` only when latency matters more than presentation stability and you have tested the target platform.

## Draw to a Window

[`WebGPUWindow`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUWindow) owns the platform window, WebGPU device resources, and frame acquisition. The render callback receives a [`WebGPUSurfaceFrame`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUSurfaceFrame), and the frame exposes the [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas) for that render.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Drawing.Processing.Backends;

WebGPUWindowOptions options = new()
{
    Title = "ImageSharp.Drawing WebGPU",
    Size = new(960, 540),
    PresentMode = WebGPUPresentMode.Fifo
};

using WebGPUWindow window = new(options);

window.Run((WebGPUSurfaceFrame frame) =>
{
    DrawingCanvas canvas = frame.Canvas;
    RectangularPolygon panel = new(64, 72, 320, 180);
    EllipsePolygon marker = new(new PointF(224, 162), new SizeF(120, 82));

    // Run supplies a frame canvas and presents it after the callback completes.
    canvas.Clear(Brushes.Solid(Color.White));
    canvas.Fill(Brushes.Solid(Color.CornflowerBlue), panel);
    canvas.Fill(Brushes.Solid(Color.Gold), marker);
    canvas.Draw(Pens.Solid(Color.Black, 3), panel);
});
```

`Run(Action<WebGPUSurfaceFrame>)` is the simplest model. The window acquires a frame, gives you the frame and its canvas, disposes the frame after the callback, and presents the result.

Use the [`WebGPUSurfaceFrame`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUSurfaceFrame) overload when you need frame lifetime control or the elapsed render time.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Drawing.Processing.Backends;

using WebGPUWindow window = new();

window.Run((frame, elapsed) =>
{
    DrawingCanvas canvas = frame.Canvas;
    float radius = 40 + (MathF.Sin((float)elapsed.TotalSeconds) * 12);
    EllipsePolygon pulse = new(new PointF(120, 120), radius);

    // Disposing the frame after this callback presents the rendered canvas.
    canvas.Clear(Brushes.Solid(Color.White));
    canvas.Fill(Brushes.Solid(Color.MediumSeaGreen), pulse);
});
```

[`WebGPUWindow`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUWindow) also exposes window events and properties such as title, size, framebuffer size, render scale, position, visibility, focus, state, border, frame rate limits, and present mode. `FramebufferSize` is the size that matters for the WebGPU surface. `ClientSize` is the window coordinate size.

## Manual Frame Acquisition

Use `TryAcquireFrame(...)` when you own the loop and want to decide when events, updates, and rendering happen.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Drawing.Processing.Backends;

using WebGPUWindow window = new();

while (!window.IsClosing)
{
    window.DoEvents();

    if (!window.TryAcquireFrame(out WebGPUSurfaceFrame? frame))
    {
        continue;
    }

    using (frame)
    {
        DrawingCanvas canvas = frame.Canvas;
        canvas.Clear(Brushes.Solid(Color.White));
        canvas.Fill(Brushes.Solid(Color.CornflowerBlue), new RectangularPolygon(40, 40, 180, 120));
    }
}
```

`TryAcquireFrame(...)` can return `false` when the surface cannot provide a drawable frame right now. That can happen for transient surface states such as timeout, outdated surface, lost surface, zero-sized framebuffer, or device recovery. Treat `false` as "skip this render attempt and try again later."

## Draw to an Existing Surface

Use [`WebGPUExternalSurface`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUExternalSurface) when another toolkit owns the window or native drawable. Create a [`WebGPUSurfaceHost`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUSurfaceHost) for the platform handle, notify the surface when the drawable framebuffer changes size, and acquire one [`WebGPUSurfaceFrame`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUSurfaceFrame) for each render.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Drawing.Processing.Backends;

void RunWin32Surface(nint hwnd, nint hinstance)
{
    WebGPUSurfaceHost host = WebGPUSurfaceHost.Win32(hwnd, hinstance);
    using WebGPUExternalSurface surface = new(host, new(1280, 720));

    void Resize(Size framebufferSize) => surface.Resize(framebufferSize);

    void Render()
    {
        if (!surface.TryAcquireFrame(out WebGPUSurfaceFrame? frame))
        {
            return;
        }

        using (frame)
        {
            RectangularPolygon content = new(48, 48, 320, 160);

            // The external UI loop owns when Render is called; the frame owns presentation.
            frame.Canvas.Clear(Brushes.Solid(Color.White));
            frame.Canvas.Fill(Brushes.Solid(Color.Orange), content);
        }
    }
}
```

[`WebGPUSurfaceHost`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUSurfaceHost) includes factory methods for GLFW, SDL, Win32, X11, Cocoa, UIKit, Wayland, WinRT, Android, Vivante, and EGL hosts.

The host application remains responsible for:

- creating and owning the native window or drawable
- providing the correct native handles to [`WebGPUSurfaceHost`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUSurfaceHost)
- calling `Resize(...)` when the drawable framebuffer size changes
- calling `TryAcquireFrame(...)` from its render loop
- disposing each acquired [`WebGPUSurfaceFrame`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUSurfaceFrame)
- keeping native handles valid for the lifetime of the external surface

Use [`WebGPUExternalSurface`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUExternalSurface) when ImageSharp.Drawing should render into an existing UI framework or native application instead of creating its own window.

## Draw Offscreen

[`WebGPURenderTarget`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPURenderTarget) renders into an offscreen GPU texture. Create a canvas, draw into it, dispose the canvas to flush the drawing work, then read the result back when CPU image access is needed.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Drawing.Processing.Backends;
using SixLabors.ImageSharp.PixelFormats;

using WebGPURenderTarget target = new(640, 360);

using (DrawingCanvas canvas = target.CreateCanvas())
{
    RectangularPolygon background = new(0, 0, target.Width, target.Height);
    EllipsePolygon highlight = new(new PointF(320, 180), new SizeF(260, 140));

    // Disposing the canvas flushes the recorded drawing commands to the GPU target.
    canvas.Fill(Brushes.Solid(Color.White), background);
    canvas.Fill(Brushes.Solid(Color.LightSkyBlue), highlight);
    canvas.Draw(Pens.Solid(Color.DarkSlateBlue, 4), highlight);
}

using Image<Rgba32> image = target.ReadbackImage<Rgba32>();
image.Save("webgpu-output.png");
```

Offscreen render targets are useful for GPU-generated images, render-to-texture workflows, tests, benchmarks, and any workflow that wants GPU drawing without a visible window.

Readback copies GPU texture data into CPU memory. It is useful when you need an `Image<TPixel>`, but it is also a synchronization point. Avoid reading back every frame in an interactive render loop unless you actually need CPU pixels.

## Choosing a Target

Use [`WebGPUWindow`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUWindow) when ImageSharp.Drawing should own the application window and render loop.

Use [`WebGPUExternalSurface`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUExternalSurface) when an existing application, UI framework, or native toolkit owns the window and event loop.

Use [`WebGPURenderTarget`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPURenderTarget) when you want GPU rendering without a visible window, or when the output needs to be read back into an ImageSharp image.

## When Not to Use WebGPU

WebGPU is not automatically the best target for every drawing workload. Prefer normal ImageSharp.Drawing when:

- you are generating static images on the server
- you need direct CPU pixel access after most operations
- you are encoding the result immediately to PNG, JPEG, WebP, or another image format
- your deployment environment has no reliable GPU, native WebGPU runtime, or compute-pipeline support
- the drawing workload is small enough that GPU setup and readback costs dominate

Prefer WebGPU when:

- the target is already a GPU surface
- the scene is interactive or redrawn repeatedly
- you can keep the result on the GPU
- you want a native window or external host surface
- the drawing workload benefits from GPU-side batching and rasterization

## Frame Lifetime Rules

The important lifetime rules are:

- Dispose a [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas) created from [`WebGPURenderTarget.CreateCanvas()`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPURenderTarget.CreateCanvas*) to submit its recorded work.
- Dispose a [`WebGPUSurfaceFrame`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUSurfaceFrame) to submit and present the frame.
- Keep retained scenes alive until every canvas or frame that recorded them has been disposed.
- Keep source images used by image brushes alive until the WebGPU canvas has replayed.
- Call `Resize(...)` on external surfaces before acquiring the next frame after a framebuffer resize.

The window `Run(...)` helpers handle frame disposal for you. Manual loops and external surfaces require you to dispose the frame yourself.

## Troubleshooting

If WebGPU cannot start, call `ProbeAvailability()` and log the returned `WebGPUEnvironmentError`.

If support probing succeeds but drawing fails, also call `ProbeComputePipelineSupport()` and configure `WebGPUEnvironment.UncapturedError` before creating WebGPU targets.

If a window or external surface stops rendering after resize or display changes, make sure the framebuffer size is positive and, for external surfaces, call `Resize(...)` with the new framebuffer size before acquiring frames.

If readback fails or produces an unexpected pixel type, check that the render target format and requested `Image<TPixel>` type match.
