# WebGPU

ImageSharp.Drawing.WebGPU provides GPU-backed drawing targets for the same [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas) API used by the CPU image pipeline.

Use the WebGPU package when the destination is naturally GPU-owned: an interactive window, a native surface owned by another UI toolkit, or an offscreen GPU texture. Use regular ImageSharp.Drawing when the destination is an `Image<TPixel>` that you will process, inspect, encode, or save on the CPU.

## What WebGPU Is

WebGPU is a modern, explicit GPU API standardized for portable GPU acceleration. It gives applications access to adapters, devices, queues, textures, buffers, shaders, and presentation surfaces. It is conceptually similar to Vulkan, Metal, and Direct3D 12, but it exposes a portable WebGPU programming model. For the broader standard, implementation status, learning resources, and community material, see [webgpu.org](https://webgpu.org/).

In ImageSharp.Drawing, WebGPU is a native .NET rendering backend, not a browser-only feature. The `SixLabors.ImageSharp.Drawing.WebGPU` package creates or attaches to native WebGPU targets, records [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas) work, lowers that work into GPU scenes, and renders into WebGPU textures.

The important shift is the destination:

- CPU ImageSharp.Drawing draws into CPU image memory.
- ImageSharp.Drawing.WebGPU draws into GPU textures and presentation surfaces.

That affects application design. A CPU image pipeline is best when you need direct pixels after each step. A WebGPU pipeline is best when output should stay on the GPU, be redrawn repeatedly, or be presented directly to a surface.

## Public Type Map

The WebGPU API is organized around ownership:

| Type | Owns | Use it when |
|---|---|---|
| [`WebGPUEnvironment`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUEnvironment) | Process-level environment configuration and support probes | You need to check availability or configure the adapter preference before creating WebGPU objects |
| [`WebGPUWindow`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUWindow) | A native window, surface, frame loop, and presentation cycle | ImageSharp.Drawing should own the application window |
| [`WebGPUExternalSurface`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUExternalSurface) | A WebGPU surface attached to caller-owned native handles | Another toolkit or host application owns the window or drawable |
| [`WebGPURenderTarget`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPURenderTarget) | An offscreen GPU texture | You need GPU drawing without a visible window, or readback into ImageSharp |
| [`WebGPUSurfaceFrame`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUSurfaceFrame) | One acquired presentable frame | You are drawing one visible frame and must dispose it to render and present |

Start by choosing the output target. You normally do not create WebGPU devices, queues, command encoders, or shader modules yourself.

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

## How Rendering Works

The WebGPU backend keeps the public drawing model the same. You still draw with [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas), brushes, pens, paths, text, images, clips, layers, and retained backend scenes.

The replay target changes:

1. Canvas commands are recorded in order.
2. The canvas seals command ranges into the replay timeline.
3. The WebGPU backend prepares retained GPU scene data for those ranges.
4. Rendering creates frame-scoped resources and dispatches GPU work into the target texture.
5. Surface frames are presented when the frame is disposed.

Disposal is part of correctness. A manually-created WebGPU canvas must be disposed to replay its recorded work. A [`WebGPUSurfaceFrame`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUSurfaceFrame) must be disposed to render and present the frame.

## Choosing a Target

Use [`WebGPUWindow`](webgpuwindow.md) when ImageSharp.Drawing should own the window and event loop.

Use [`WebGPUExternalSurface`](webgpuexternalsurface.md) when another application, UI framework, game engine, or native toolkit owns the window and exposes native handles.

Use [`WebGPURenderTarget`](webgpurendertarget.md) when you want offscreen GPU drawing, render-to-texture workflows, tests, benchmarks, or readback into an `Image<TPixel>`.

Use [`WebGPUEnvironment`](webgpuenvironment.md) before any of those when you need predictable startup behavior, diagnostics, or fallback to CPU rendering.

## Shared Concepts

Texture format controls the GPU target and, for readback, the matching ImageSharp pixel type:

| WebGPU format | Natural ImageSharp pixel type |
|---|---|
| `Rgba8Unorm` | `Rgba32` |
| `Bgra8Unorm` | `Bgra32` |
| `Rgba8Snorm` | `NormalizedByte4` |
| `Rgba16Float` | `HalfVector4` |

Present mode controls how visible frames wait for the display:

- `Fifo` is v-synced and is the safest default.
- `Immediate` presents as soon as possible and can tear.
- `Mailbox` keeps newer frames over older queued frames when supported.

CPU/GPU synchronization is the expensive boundary. Reading a render target back into an `Image<TPixel>` copies GPU texture data into CPU memory. Running normal ImageSharp processors through `Apply(...)` on a GPU-backed canvas can require GPU readback, CPU processing, and upload before drawing continues.

## When Not to Use WebGPU

WebGPU is not automatically better for every drawing workload. Prefer the normal CPU path when:

- you are generating static images on a server
- you need direct CPU pixel access after most operations
- you immediately encode the result to PNG, JPEG, WebP, or another image format
- the deployment environment has unreliable GPU or native WebGPU support
- the drawing workload is small enough that GPU setup or readback costs dominate

Prefer WebGPU when:

- the target is already a GPU surface
- the scene is interactive or redrawn repeatedly
- the output can stay on the GPU
- you need a native window or host surface
- the drawing workload benefits from GPU-side batching and rasterization

## Related Topics

- [WebGPU Environment and Support](webgpuenvironment.md)
- [WebGPU Window Rendering](webgpuwindow.md)
- [WebGPU External Surfaces](webgpuexternalsurface.md)
- [WebGPU Offscreen Render Targets](webgpurendertarget.md)
- [Canvas Drawing](canvas.md)
- [Transforms and Composition](transformsandcomposition.md)

## Practical Guidance

Choose the target first, because the target owns the lifetime rules. Probe support before constructing production WebGPU targets. Dispose canvases and frames promptly so recorded drawing is submitted. Keep source images, image brushes, fonts, paths, and retained backend scenes alive until every canvas or frame that references them has been disposed.
