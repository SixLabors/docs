# Introduction

### What is ImageSharp.Drawing?
ImageSharp.Drawing is the high-performance 2D drawing layer for ImageSharp. It adds vector geometry, strokes, fills, text rendering, image composition, clipping, layers, and optional WebGPU-backed rendering while keeping the same cross-platform, managed-code deployment model as ImageSharp.

The core model is deliberately small: geometry describes coverage, brushes and pens describe how pixels are produced, drawing options describe state, and [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas) records ordered drawing work into a replay timeline. That makes the same drawing code useful for one-off image generation, templated graphics, server-side rendering, retained backend scenes, and GPU-backed output.

Read the articles as a progression. Start with the canvas workflow because replay, state, and lifetime explain the rest of the API. Then learn geometry, brushes, pens, clipping, text, image composition, transforms, and WebGPU as separate pieces that combine into one drawing pipeline.

### Start Here

- [Getting Started](gettingstarted.md) introduces the [`Paint(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.PaintExtensions) and [`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas) workflow.
- [Canvas Drawing](canvas.md) covers canvas state, clipping, regions, and applying ImageSharp processors to drawn regions.
- [Primitive Drawing Helpers](primitives.md) covers rectangles, ellipses, arcs, pies, lines, and Bezier helpers.
- [Paths and Shapes](pathsandshapes.md) covers built-in shapes, custom paths, and fill rules.
- [Brushes and Pens](brushesandpens.md) covers solid, pattern, and gradient fills plus stroke options.
- [Clipping, Regions, and Layers](clippingregionslayers.md) covers clip paths, region canvases, save/restore state, and isolated layer composition.
- [Images, Masks, and Processing](imagesandprocessing.md) covers [`DrawImage(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.DrawImage*), image brushes, clipping masks, and [`Apply(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Apply*).
- [Transforms and Composition](transformsandcomposition.md) covers transforms, blending, alpha composition, and antialiasing.
- [Drawing Text](text.md) covers [`RichTextOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.RichTextOptions), measuring, and text along paths.
- [WebGPU](webgpu.md) introduces GPU-backed drawing targets and links to the focused WebGPU pages.
- [WebGPU Environment and Support](webgpuenvironment.md) covers startup configuration, availability probes, compute-pipeline checks, and native error logging.
- [WebGPU Window Rendering](webgpuwindow.md) covers `WebGPUWindow`, frame loops, window state, framebuffer sizing, and presentation.
- [WebGPU External Surfaces](webgpuexternalsurface.md) covers `WebGPUExternalSurface`, native surface hosts, host-owned resize, and frame acquisition.
- [WebGPU Offscreen Render Targets](webgpurendertarget.md) covers `WebGPURenderTarget`, offscreen canvases, texture formats, and readback.
- [Migrating from System.Drawing](migratingfromsystemdrawing.md) maps common GDI+ drawing concepts to ImageSharp.Drawing.
- [Migrating from SkiaSharp](migratingfromskiasharp.md) maps common SkiaSharp drawing concepts to ImageSharp.Drawing.
- [Recipes](recipes.md) provides copy-pasteable solutions for common drawing tasks.
- [Troubleshooting](troubleshooting.md) covers common canvas, clipping, text, image, and WebGPU issues.

Built against [.NET 8](https://learn.microsoft.com/en-us/dotnet/core/whats-new/dotnet-8/overview), ImageSharp.Drawing can be used in device, cloud, and embedded/IoT scenarios.

### License
ImageSharp.Drawing is licensed under the terms of the [Six Labors Split License, Version 1.0](https://github.com/SixLabors/ImageSharp.Drawing/blob/main/LICENSE). See https://sixlabors.com/pricing for commercial licensing details.

>[!IMPORTANT]
>Starting with ImageSharp.Drawing 3.0.0, projects that directly depend on ImageSharp.Drawing require a valid Six Labors license at build time. This enforcement applies to direct dependencies only. See [License Enforcement Changes and a New Subscription Tier](https://sixlabors.com/posts/licence-enforcement-changes/) for details.

### Installation

ImageSharp.Drawing is installed via [NuGet](https://www.nuget.org/packages/SixLabors.ImageSharp.Drawing) with nightly builds available on [Feedz](https://f.feedz.io/sixlabors/sixlabors/nuget/index.json).

# [Package Manager](#tab/tabid-1)

```bash
PM > Install-Package SixLabors.ImageSharp.Drawing -Version VERSION_NUMBER
```

# [.NET CLI](#tab/tabid-2)

```bash
dotnet add package SixLabors.ImageSharp.Drawing --version VERSION_NUMBER
```

# [PackageReference](#tab/tabid-3)

```xml
<PackageReference Include="SixLabors.ImageSharp.Drawing" Version="VERSION_NUMBER" />
```

# [Paket CLI](#tab/tabid-4)

```bash
paket add SixLabors.ImageSharp.Drawing --version VERSION_NUMBER
```

***

>[!WARNING]
>Prerelease versions installed via the [Visual Studio NuGet Package Manager](https://docs.microsoft.com/en-us/nuget/consume-packages/install-use-packages-visual-studio) require the "include prerelease" checkbox to be checked.

### How to use the license file

By default, the build searches from each project directory for `sixlabors.lic`. Place the supplied file in the directory that contains the project file, or in a subdirectory below it. Use the file as supplied; it already contains the complete license string required by the build.

If you want to keep the file somewhere else, including a repository root that sits above the project directory, set `SixLaborsLicenseFile` in your project file or a shared props file:

```xml
<PropertyGroup>
  <SixLaborsLicenseFile>path/to/sixlabors.lic</SixLaborsLicenseFile>
</PropertyGroup>
```

If you do not want to store the license on disk, pass the license string directly from an environment variable or secret store. When extracting the value from `sixlabors.lic`, use the full file contents, not only the `Key` field:

```xml
<PropertyGroup>
  <SixLaborsLicenseKey>$(SIXLABORS_LICENSE_KEY)</SixLaborsLicenseKey>
</PropertyGroup>
```

You can also pass the key to common .NET CLI commands.

PowerShell:

```powershell
dotnet build -p:SixLaborsLicenseKey="$env:SIXLABORS_LICENSE_KEY"
dotnet publish -p:SixLaborsLicenseKey="$env:SIXLABORS_LICENSE_KEY"
```

Bash and other shells that expand environment variables with `$NAME`:

```bash
dotnet build -p:SixLaborsLicenseKey="$SIXLABORS_LICENSE_KEY"
dotnet publish -p:SixLaborsLicenseKey="$SIXLABORS_LICENSE_KEY"
```

Build as normal after the file or property is configured. If the license is missing or invalid, the build fails with a clear error. You do not need to reference the licensing package directly; it is carried by Six Labors libraries.

### How to Use These Docs

- Start with the canvas model, because replay, state, and lifetime explain the rest of the API.
- Use paths and brushes pages when geometry and styling decisions are still unclear.
- Use text and image-processing pages when drawing must combine rich text, source images, clipping, and effects.
- Use WebGPU pages only when the output target genuinely benefits from GPU-backed rendering.
