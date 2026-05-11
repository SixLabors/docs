# Introduction

### What is Fonts?
Fonts is the high-performance part of the Six Labors stack that handles font loading, text measurement, layout, shaping, and custom text rendering.

If you are new to the library, the easiest way to think about it is in layers: load families, create concrete `Font` instances, then measure or render text with `TextOptions`. The rest of this section is organized around that path so you can start simple and move into shaping, Unicode, fallback, and custom rendering only when you need them.

It supports TrueType and OpenType fonts, including CFF1 and CFF2 outlines, WOFF and WOFF2 web fonts, variable fonts, color fonts, advanced OpenType layout, complex script shaping, and bidirectional text rendering.

Fonts is often used underneath [ImageSharp.Drawing](../imagesharp.drawing/index.md), but it is not limited to image rendering. You can also use it for font inspection, text measurement, shaping, and custom rendering pipelines.

### License

Fonts is licensed under the terms of the [Six Labors Split License, Version 1.0](https://github.com/SixLabors/Fonts/blob/main/LICENSE). See https://sixlabors.com/pricing for commercial licensing details.

>[!IMPORTANT]
>Starting with Fonts 3.0.0, projects that directly depend on SixLabors.Fonts require a valid Six Labors license at build time. Add `sixlabors.lic` to your repository root, set `SixLaborsLicenseFile`, or set `SixLaborsLicenseKey`. This enforcement applies to direct dependencies only. See [License Enforcement Changes and a New Subscription Tier](https://sixlabors.com/posts/licence-enforcement-changes/) for details.

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

### How to use the license file

Add the supplied `sixlabors.lic` file to your repository root. Use the file as supplied; it already contains the complete license string required by the build.

If you want to keep the file somewhere else, set `SixLaborsLicenseFile` in your project file or a shared props file:

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

### Start Here

If you are new to Fonts, start with [Loading Fonts and Collections](gettingstarted.md) and then use the pages below to branch into the topics your application needs.

- [System Fonts](systemfonts.md)
- [Font Metadata and Inspection](fontmetadata.md)
- [Font Metrics](fontmetrics.md)
- [Measuring Text](measuringtext.md)
- [Prepared Text with TextBlock](textblock.md)
- [Hit Testing and Caret Movement](texthittesting.md)
- [Selection and Bidi Drag](caretsandselection.md)
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
