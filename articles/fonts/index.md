# Introduction

### What is Fonts?
Fonts is the part of the Six Labors stack that handles font loading, text measurement, layout, shaping, and custom text rendering.

If you are new to the library, the easiest way to think about it is in layers: load families, create concrete `Font` instances, then measure or render text with `TextOptions`. The rest of this section is organized around that path so you can start simple and move into shaping, Unicode, fallback, and custom rendering only when you need them.

It supports TrueType and OpenType fonts, including CFF1 and CFF2 outlines, WOFF and WOFF2 web fonts, variable fonts, color fonts, advanced OpenType layout, complex script shaping, and bidirectional text rendering.

Fonts is often used underneath [ImageSharp.Drawing](../imagesharp.drawing/index.md), but it is not limited to image rendering. You can also use it for font inspection, text measurement, shaping, and custom rendering pipelines.

### License

Fonts is licensed under the terms of the [Six Labors Split License, Version 1.0](https://github.com/SixLabors/Fonts/blob/main/LICENSE). See https://sixlabors.com/pricing for commercial licensing details.

>[!IMPORTANT]
>Starting with Fonts 3.0.0, projects that directly depend on SixLabors.Fonts require a `sixlabors.lic` file to compile. By default, place the file next to your project file, or set `SixLaborsLicenseFile` in your project or shared props file to point to a central location. This enforcement applies to direct dependencies only. See [License Enforcement Changes and a New Subscription Tier](https://sixlabors.com/posts/licence-enforcement-changes/) for details.

### Installation

Fonts is installed via [NuGet](https://www.nuget.org/packages/SixLabors.Fonts) with nightly builds available on [Feedz](https://f.feedz.io/sixlabors/sixlabors/nuget/index.json).

# [Package Manager](#tab/tabid-1)

```bash
PM > Install-Package SixLabors.Fonts -Version VERSION_NUMBER
```

# [.NET CLI](#tab/tabid-2)

```bash
dotnet add package SixLabors.Fonts --version VERSION_NUMBER
```

# [PackageReference](#tab/tabid-3)

```xml
<PackageReference Include="SixLabors.Fonts" Version="VERSION_NUMBER" />
```

# [Paket CLI](#tab/tabid-4)

```bash
paket add SixLabors.Fonts --version VERSION_NUMBER
```

***

>[!WARNING]
>Prerelease versions installed via the [Visual Studio NuGet Package Manager](https://docs.microsoft.com/en-us/nuget/consume-packages/install-use-packages-visual-studio) require the "include prerelease" checkbox to be checked.

### Start Here

If you are new to Fonts, start with [Loading Fonts and Collections](gettingstarted.md) and then use the pages below to branch into the topics your application needs.

- [System Fonts](systemfonts.md)
- [Font Metadata and Inspection](fontmetadata.md)
- [Font Metrics](fontmetrics.md)
- [Measuring Text](measuringtext.md)
- [Text Layout and Options](textlayout.md)
- [OpenType Features](opentypefeatures.md)
- [Hinting and Shaping](hintingandshaping.md)
- [Color Fonts](colorfonts.md)
- [Unicode, Code Points, and Graphemes](unicode.md)
- [Fallback Fonts and Multilingual Text](fallbackfonts.md)
- [Variable Fonts](variablefonts.md)
- [Custom Rendering](customrendering.md)
- [Recipes](recipes.md)
- [Troubleshooting](troubleshooting.md)
