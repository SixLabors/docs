# WebGPU Window Rendering

[`WebGPUWindow`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUWindow) is the highest-level WebGPU target. It owns the native window, WebGPU surface, device resources, frame acquisition, and presentation cycle.

Use it when ImageSharp.Drawing should own the application window. If another UI framework, game engine, or host application owns the window, use [`WebGPUExternalSurface`](webgpuexternalsurface.md) instead.

## Window Ownership

A `WebGPUWindow` wraps a real native window and exposes a [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas) for each acquired frame. You draw into that frame canvas, and the frame is presented when the frame scope is disposed.

The window owns:

- the platform window
- the WebGPU presentation surface
- the frame acquisition loop
- resize-driven surface reconfiguration
- the drawing backend bound to the window target

That ownership makes it a good fit for demos, tools, visualizers, preview windows, and applications where ImageSharp.Drawing is the main renderer.

## Create a Window

[`WebGPUWindowOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUWindowOptions) controls the initial title, size, position, visibility, scheduling hints, state, border, present mode, and texture format.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Drawing.Processing.Backends;

WebGPUWindowOptions options = new()
{
    Title = "ImageSharp.Drawing WebGPU",
    Size = new(960, 540),
    PresentMode = WebGPUPresentMode.Fifo,
    Format = WebGPUTextureFormat.Rgba8Unorm
};

using WebGPUWindow window = new(options);
```

`Size` is the initial client-area size in window coordinates. `FramebufferSize` is the pixel size of the drawable WebGPU surface. On high-DPI displays those can differ; use `RenderScale`, `PointToFramebuffer(...)`, or framebuffer resize events when mapping input to pixels.

## Render With Run

The simplest model is [`Run(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUWindow.Run*). The window owns the loop, acquires one frame per render callback, and disposes the frame after your callback returns.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Drawing.Processing.Backends;

using WebGPUWindow window = new(new WebGPUWindowOptions { Title = "WebGPU Demo" });

window.Run((WebGPUSurfaceFrame frame) =>
{
    DrawingCanvas canvas = frame.Canvas;
    Rectangle panel = new(64, 72, 320, 180);

    // The frame is presented after Run disposes it at the end of the callback.
    canvas.Clear(Brushes.Solid(Color.White));
    canvas.Fill(Brushes.Solid(Color.CornflowerBlue), panel);
    canvas.FillEllipse(Brushes.Solid(Color.Gold), new(224, 162), new(120, 82));
    canvas.Draw(Pens.Solid(Color.Black, 3), panel);
});
```

Use the elapsed-time overload when animation needs frame timing:

```csharp
window.Run((frame, elapsed) =>
{
    DrawingCanvas canvas = frame.Canvas;
    float radius = 40 + (MathF.Sin((float)elapsed.TotalSeconds) * 12);

    // The radius is converted to an ellipse size because FillEllipse takes width and height.
    canvas.Clear(Brushes.Solid(Color.White));
    canvas.FillEllipse(Brushes.Solid(Color.MediumSeaGreen), new(120, 120), new(radius * 2, radius * 2));
});
```

## Drive the Loop Manually

Use [`TryAcquireFrame(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUWindow.TryAcquireFrame*) when the application owns the loop.

```csharp
using SixLabors.ImageSharp;
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
        canvas.Fill(Brushes.Solid(Color.CornflowerBlue), new Rectangle(40, 40, 180, 120));
    }
}
```

`TryAcquireFrame(...)` can return `false` when no drawable frame is available right now. That can happen for transient surface states such as timeout, outdated surface, lost surface, zero-sized framebuffer, or device recovery. Treat `false` as "skip this render attempt and try again later."

## Window Events and State

`WebGPUWindow` exposes events for update, resize, framebuffer resize, closing, focus, move, state change, and file drop. Use `FramebufferResized` when WebGPU pixel dimensions matter. Use `Resized` when UI layout in client coordinates matters.

Useful properties include:

- `Title`, `ClientSize`, `FramebufferSize`, and `RenderScale`
- `Position`, `IsVisible`, `WindowState`, and `WindowBorder`
- `FramesPerSecond`, `UpdatesPerSecond`, and `IsEventDriven`
- `PresentMode` and `Format`
- `PointToClient(...)`, `PointToScreen(...)`, and `PointToFramebuffer(...)`

Changing `PresentMode` reconfigures the surface. Changing `Format` is an initial creation choice; choose the target format in `WebGPUWindowOptions`.

## Frame Lifetime

A frame owns one acquired presentable texture. Drawing commands are recorded through `frame.Canvas`. Disposing the frame disposes that canvas, replays the drawing timeline, submits GPU work, presents the surface texture, and releases per-frame resources.

If `Run(...)` owns the loop, it disposes the frame for you. If you call `TryAcquireFrame(...)`, dispose every frame you acquire.

## Related Topics

- [WebGPU](webgpu.md)
- [WebGPU Environment and Support](webgpuenvironment.md)
- [WebGPU External Surfaces](webgpuexternalsurface.md)
- [WebGPU Offscreen Render Targets](webgpurendertarget.md)

## Practical Guidance

Use `WebGPUWindow` when ImageSharp.Drawing owns the render loop. Start with `Run(...)`; move to `TryAcquireFrame(...)` only when you need explicit event, update, and render scheduling. Keep frame drawing short, dispose frames promptly, and use framebuffer coordinates when mapping input or layout to actual GPU pixels.
