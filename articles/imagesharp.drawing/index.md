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
>Projects that directly reference ImageSharp.Drawing require a valid Six Labors license key at build time from version 2.2.0 in the previous major and 3.0.0 in the current major. Enforcement applies to direct dependencies only. This is enforcement of the existing license terms, not a license change.

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

Prerelease versions installed via the [Visual Studio NuGet Package Manager](https://docs.microsoft.com/en-us/nuget/consume-packages/install-use-packages-visual-studio) require the "include prerelease" checkbox to be checked.

### How to use the license file

By default, the build searches from each project directory for `sixlabors.lic`. Place the supplied file in the directory that contains the project file, or in a subdirectory below it. Use the file as supplied; it contains the complete license string required by the build.

>[!IMPORTANT]
>Assembly-scoped community keys can be committed to a public repository. Contributors can use the included key to build the named assemblies without obtaining their own keys. Unrestricted community keys and commercial keys must remain private. Use environment variables or repository secrets for those keys.

To keep the file elsewhere, including a repository root above the project directory, set `SixLaborsLicenseFile` in your project file or a shared props file:

```xml
<PropertyGroup>
  <!-- Set the location of the supplied license file. -->
  <SixLaborsLicenseFile>path/to/sixlabors.lic</SixLaborsLicenseFile>
</PropertyGroup>
```

To use an environment variable instead, set this project property:

```xml
<PropertyGroup>
  <!-- Read the complete license string from the environment. -->
  <SixLaborsLicenseKey>$(SIXLABORS_LICENSE_KEY)</SixLaborsLicenseKey>
</PropertyGroup>
```

Set `SIXLABORS_LICENSE_KEY` to the complete contents of your issued license, not only its `Key` field. Use the original value without escaping. Replace the entire example value below with your issued license contents.

PowerShell:

```powershell
# Quotes preserve the field separators and the pipe between assembly signatures.
$env:SIXLABORS_LICENSE_KEY = 'Id=<id>;Kind=Community;ExpiryDateUtc=<expiry>;Key=Assembly:<signature>|<signature>'
dotnet build
dotnet publish
```

Bash:

```bash
# Quotes preserve the field separators and the pipe between assembly signatures.
export SIXLABORS_LICENSE_KEY='Id=<id>;Kind=Community;ExpiryDateUtc=<expiry>;Key=Assembly:<signature>|<signature>'
dotnet build
dotnet publish
```

If you pass the license directly through `-p:SixLaborsLicenseKey`, escape every semicolon as `%253B`. MSBuild treats semicolons as property separators even inside a quoted argument. The pipe between assembly signatures stays unchanged.

PowerShell:

```powershell
# Escape field separators only when passing the license through -p:.
dotnet build "-p:SixLaborsLicenseKey=$($env:SIXLABORS_LICENSE_KEY.Replace(';', '%253B'))"
dotnet publish "-p:SixLaborsLicenseKey=$($env:SIXLABORS_LICENSE_KEY.Replace(';', '%253B'))"
```

Bash:

```bash
# Escape field separators only when passing the license through -p:.
dotnet build "-p:SixLaborsLicenseKey=${SIXLABORS_LICENSE_KEY//;/%253B}"
dotnet publish "-p:SixLaborsLicenseKey=${SIXLABORS_LICENSE_KEY//;/%253B}"
```

You do not need to reference the licensing package directly. Projects that directly reference a Six Labors package carry its build-time validation.

### Community keys for public projects

For an open-source or source-available application, provide the exact `AssemblyName` of every project that directly references a Six Labors package, including test projects. Names are case-sensitive.

For example, if `MyProject.csproj` sets `<AssemblyName>MyProject.Core</AssemblyName>`, enter `MyProject.Core`. If it does not set `AssemblyName`, enter `MyProject`, the project filename without `.csproj`. If a shared props file sets the name, use that value. Do not include `.dll` or `.csproj`.

**Existing community license holders can request one early replacement with an assembly-scoped key. These upgrade requests are approved automatically, without another eligibility review. You do not need to wait for your current key to enter its renewal window.**

Apply at [licensing.sixlabors.com](https://licensing.sixlabors.com/). Select open-source or source-available, use the same email address, and provide the assembly names. Later requests follow the normal renewal window: the final 90 days before the expiry date in your license. Commercial licenses are not eligible for this early replacement.

### Security support

The latest major version of each library is eligible for security updates. Each major remains eligible for 12 months after the first stable release of its successor. A later major release does not shorten an existing support window.

Install the latest available patch or minor release within a supported major to receive security fixes. Older releases within that major are not maintained separately. This policy covers security fixes only. It does not include feature backports or extend Microsoft's support for the underlying .NET version. Security fixes remain at Six Labors' discretion.

### How to Use These Docs

- Start with the canvas model, because replay, state, and lifetime explain the rest of the API.
- Use paths and brushes pages when geometry and styling decisions are still unclear.
- Use text and image-processing pages when drawing must combine rich text, source images, clipping, and effects.
- Use WebGPU pages only when the output target genuinely benefits from GPU-backed rendering.
