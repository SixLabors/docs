# WebGPU External Surfaces

[`WebGPUExternalSurface`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUExternalSurface) attaches ImageSharp.Drawing.WebGPU to a native drawable owned by another application or UI toolkit.

Use it when you already have a window, view, swapchain host, or platform drawable and ImageSharp.Drawing should render into that existing surface. Unlike [`WebGPUWindow`](webgpuwindow.md), this type does not own the native window or event loop.

## Ownership Model

The host application owns:

- the native window or drawable
- the native handles passed to [`WebGPUSurfaceHost`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUSurfaceHost)
- resize notifications
- event processing
- render scheduling
- the lifetime of the underlying UI object

`WebGPUExternalSurface` owns the WebGPU surface resources attached to those handles. It can acquire frames, create frame canvases, and present rendered output, but it never releases the native handles you supplied.

## Create a Surface Host

Create a [`WebGPUSurfaceHost`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUSurfaceHost) with the factory method matching the host platform or toolkit:

- `Glfw(...)`
- `Sdl(...)`
- `Win32(...)`
- `X11(...)`
- `Cocoa(...)`
- `UIKit(...)`
- `Wayland(...)`
- `WinRT(...)`
- `Android(...)`
- `Vivante(...)`
- `EGL(...)`

For Win32:

```csharp
using SixLabors.ImageSharp.Drawing.Processing.Backends;

WebGPUSurfaceHost host = WebGPUSurfaceHost.Win32(hwnd, hinstance);
```

Pass valid native handles for the lifetime of the external surface. The exact handles depend on the platform. For example, X11 needs a display pointer and window id, Wayland needs display and surface pointers, and UIKit needs the window plus framebuffer objects.

## Create the External Surface

The framebuffer size is the drawable size in pixels, not necessarily the logical UI size.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing.Backends;

WebGPUExternalSurfaceOptions options = new()
{
    PresentMode = WebGPUPresentMode.Fifo,
    Format = WebGPUTextureFormat.Rgba8Unorm
};

using WebGPUExternalSurface surface = new(host, new Size(1280, 720), options);
```

Use a custom `Configuration` overload when the drawing backend should be bound to a specific ImageSharp configuration.

## Handle Resizes

The host application must notify the external surface when the drawable framebuffer changes size:

```csharp
void OnFramebufferResized(int width, int height)
{
    surface.Resize(new Size(width, height));
}
```

Zero-sized framebuffers are ignored. This matters for minimized windows, hidden views, and platform states where the drawable temporarily has no size.

## Render a Frame

Call [`TryAcquireFrame(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUExternalSurface.TryAcquireFrame*) from the host render loop. Dispose each acquired frame to submit and present.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Drawing.Processing.Backends;

void Render()
{
    if (!surface.TryAcquireFrame(out WebGPUSurfaceFrame? frame))
    {
        return;
    }

    using (frame)
    {
        DrawingCanvas canvas = frame.Canvas;

        // The host owns when Render is called; the frame owns presentation.
        canvas.Clear(Brushes.Solid(Color.White));
        canvas.Fill(Brushes.Solid(Color.Orange), new Rectangle(48, 48, 320, 160));
    }
}
```

Use the overload that accepts `DrawingOptions` when the whole frame should start with a specific transform, graphics options, or shape options.

## External Surface Failure Modes

`TryAcquireFrame(...)` can return `false` when a drawable frame is not available. Common causes include a zero-sized framebuffer, an outdated or lost surface, timeout, or device recovery.

The correct response is usually to skip that render attempt, keep processing host events, and try again on the next render tick. Recreate the external surface only when the host application has replaced the native drawable or invalidated the handles.

## Related Topics

- [WebGPU](webgpu.md)
- [WebGPU Environment and Support](webgpuenvironment.md)
- [WebGPU Window Rendering](webgpuwindow.md)
- [WebGPU Offscreen Render Targets](webgpurendertarget.md)

## Practical Guidance

Use `WebGPUExternalSurface` when ImageSharp.Drawing is a renderer inside somebody else's windowing model. Keep native handles valid, forward framebuffer resize events, acquire at most one frame per render, dispose every acquired frame, and treat a failed frame acquisition as a normal transient condition.
