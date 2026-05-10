# Introduction

### What is ImageSharp.Drawing?
ImageSharp.Drawing is a library built on top of ImageSharp to provide 2D drawing extensions.

ImageSharp.Drawing is designed from the ground up to be high-performance, flexible, and extensible. It provides vector geometry, brush and pen styling, canvas drawing, image compositing, and text rendering building blocks for custom images.

### Start Here

- [Getting Started](gettingstarted.md) introduces the `Paint(...)` and `DrawingCanvas` workflow.
- [Canvas Drawing](canvas.md) covers canvas state, clipping, regions, and applying ImageSharp processors to drawn regions.
- [Primitive Drawing Helpers](primitives.md) covers rectangles, ellipses, arcs, pies, lines, and Bezier helpers.
- [Paths and Shapes](pathsandshapes.md) covers built-in shapes, custom paths, and fill rules.
- [Brushes and Pens](brushesandpens.md) covers solid, pattern, and gradient fills plus stroke options.
- [Clipping, Regions, and Layers](clippingregionslayers.md) covers clip paths, region canvases, save/restore state, and isolated layer composition.
- [Images, Masks, and Processing](imagesandprocessing.md) covers `DrawImage(...)`, image brushes, clipping masks, and `Apply(...)`.
- [Transforms and Composition](transformsandcomposition.md) covers transforms, blending, alpha composition, and antialiasing.
- [Drawing Text](text.md) covers `RichTextOptions`, measuring, and text along paths.
- [WebGPU](webgpu.md) covers GPU-backed windows, external surfaces, and offscreen render targets.
- [Recipes](recipes.md) provides copy-pasteable solutions for common drawing tasks.
- [Troubleshooting](troubleshooting.md) covers common canvas, clipping, text, image, and WebGPU issues.

Built against [.NET 8](https://learn.microsoft.com/en-us/dotnet/core/whats-new/dotnet-8/overview), ImageSharp.Drawing can be used in device, cloud, and embedded/IoT scenarios.

### License
ImageSharp.Drawing is licensed under the terms of the [Six Labors Split License, Version 1.0](https://github.com/SixLabors/ImageSharp.Drawing/blob/main/LICENSE). See https://sixlabors.com/pricing for commercial licensing details.

>[!IMPORTANT]
>Starting with ImageSharp.Drawing 3.0.0, projects that directly depend on ImageSharp.Drawing require a `sixlabors.lic` file to compile. By default, place the file next to your project file, or set `SixLaborsLicenseFile` in your project or shared props file to point to a central location. This enforcement applies to direct dependencies only. See [License Enforcement Changes and a New Subscription Tier](https://sixlabors.com/posts/licence-enforcement-changes/) for details.

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
