# ImageSharp

ImageSharp is the high-performance part of the Six Labors stack you reach for when you need to load, inspect, process, and save images entirely in managed .NET code. It gives you one consistent image model whether you are building a thumbnail service, a photo workflow, a web upload pipeline, or a lower-level imaging tool.

This section is written as a guided set of articles rather than a flat feature list. Start with [Getting Started](gettingstarted.md) if you are new to the library, then branch into loading, processing, formats, or lower-level pixel work as your needs get more specific.

## License

ImageSharp is licensed under the terms of the [Six Labors Split License, Version 1.0](https://github.com/SixLabors/ImageSharp/blob/main/LICENSE). See https://sixlabors.com/pricing for commercial licensing details.

>[!IMPORTANT]
>Starting with ImageSharp 4.0.0, projects that directly depend on ImageSharp require a `sixlabors.lic` file to compile. By default, place the file next to your project file, or set `SixLaborsLicenseFile` in your project or shared props file to point to a central location. This enforcement applies to direct dependencies only. See [License Enforcement Changes and a New Subscription Tier](https://sixlabors.com/posts/licence-enforcement-changes/) for details.

## Install ImageSharp

ImageSharp is distributed on [NuGet](https://www.nuget.org/packages/SixLabors.ImageSharp) with preview and nightly builds available on [Feedz](https://f.feedz.io/sixlabors/sixlabors/nuget/index.json).

# [Package Manager](#tab/tabid-1)

```bash
PM > Install-Package SixLabors.ImageSharp -Version VERSION_NUMBER
```

# [.NET CLI](#tab/tabid-2)

```bash
dotnet add package SixLabors.ImageSharp --version VERSION_NUMBER
```

# [PackageReference](#tab/tabid-3)

```xml
<PackageReference Include="SixLabors.ImageSharp" Version="VERSION_NUMBER" />
```

# [Paket CLI](#tab/tabid-4)

```bash
paket add SixLabors.ImageSharp --version VERSION_NUMBER
```

***

>[!WARNING]
>Prerelease versions installed via the [Visual Studio NuGet Package Manager](https://docs.microsoft.com/en-us/nuget/consume-packages/install-use-packages-visual-studio) require the "include prerelease" checkbox to be checked.

## Start Here

- [Getting Started](gettingstarted.md) walks through the core image types and the first end-to-end processing workflow.
- [Loading, Identifying, and Saving](loadingandsaving.md) covers file, stream, and buffer-based APIs plus encoder selection.
- [Working with Metadata](metadata.md) explains how to read and preserve EXIF, ICC, IPTC, XMP, and format-specific metadata.
- [Color Profiles and Color Conversion](colorprofiles.md) covers ICC and CICP metadata, decode-time profile handling, and explicit working-space conversion.
- [Image Formats](imageformats.md) explains format detection, encoders, decoders, and format registration.
- [Processing Images](processing.md) introduces `Mutate()` and `Clone()` pipelines.
- [Quantization, Palettes, and Dithering](quantization.md) explains `Quantize()`, palette-based encoders, and dithering tradeoffs.
- [Pixel Formats](pixelformats.md) and [Working with Pixel Buffers](pixelbuffers.md) cover direct pixel access and advanced processing.
- [Interop and Raw Memory](interop.md) covers `LoadPixelData(...)`, `WrapMemory(...)`, and contiguous-buffer interop.
- [Configuration](configuration.md), [Memory Management](memorymanagement.md), and [Security Considerations](security.md) cover production-focused setup.
- [Troubleshooting](troubleshooting.md) covers the common failure modes around format detection, streams, memory, and disposal.
- [Migrating from System.Drawing](migratingfromsystemdrawing.md) maps common GDI-style workflows to ImageSharp APIs.
- [Recipes](recipes.md) provides copy-pasteable solutions for common tasks.

## Implicit Usings

Set `UseImageSharp` in your project file to automatically import the most common ImageSharp namespaces:

```xml
<PropertyGroup>
  <UseImageSharp>true</UseImageSharp>
</PropertyGroup>
```

When enabled, ImageSharp adds implicit `global using` directives for:

- `SixLabors.ImageSharp`
- `SixLabors.ImageSharp.PixelFormats`
- `SixLabors.ImageSharp.Processing`

You can turn this off by removing the property or setting it to `false`.
