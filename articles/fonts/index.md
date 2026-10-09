# Introduction

## What is Fonts?
Fonts is the high-performance part of the Six Labors stack that handles font loading, text measurement, layout, shaping, and custom text rendering.

If you are new to the library, the easiest way to think about it is in layers: load families, create concrete `Font` instances, then measure or render text with `TextOptions`. The rest of this section is organized around that path so you can start simple and move into shaping, Unicode, fallback, and custom rendering only when you need them.

It supports TrueType and OpenType fonts, including CFF1 and CFF2 outlines, WOFF and WOFF2 web fonts, variable fonts, color fonts, advanced OpenType layout, complex script shaping, and bidirectional text rendering.

Fonts is often used underneath [ImageSharp.Drawing](../imagesharp.drawing/index.md), but it is not limited to image rendering. You can also use it for font inspection, text measurement, shaping, and custom rendering pipelines.

The main thing to learn early is the difference between font assets, font instances, and text layout. A font collection tells you what families are available, a `Font` chooses a family/style/size, and `TextOptions` describes how a specific piece of text should be shaped, wrapped, aligned, measured, or rendered. `TextBlock` builds on that by preparing layout once so you can inspect lines, hit-test, move carets, or draw the same shaped text consistently.

The Unicode pages are part of the practical API story, not a side topic. Most real text is not one UTF-16 code unit per visible character, and indexes used for rich text, placeholders, selection, and hit testing need to be understood in terms of graphemes and shaped layout rather than raw `char` positions.

## License

Fonts is licensed under the terms of the [Six Labors Split License, Version 1.0](https://github.com/SixLabors/Fonts/blob/main/LICENSE). See https://sixlabors.com/pricing for commercial licensing details.

>[!IMPORTANT]
>Projects that directly reference Fonts require a valid Six Labors license key at build time from version 2.2.0 in the previous major and 3.0.0 in the current major. Enforcement applies to direct dependencies only. This is enforcement of the existing license terms, not a license change.

## Installation

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

Prerelease versions installed via the [Visual Studio NuGet Package Manager](https://docs.microsoft.com/en-us/nuget/consume-packages/install-use-packages-visual-studio) require the "include prerelease" checkbox to be checked.

## How to use the license file

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

## Community keys for public projects

For an open-source or source-available application, provide the exact `AssemblyName` of every project that directly references a Six Labors package, including test projects. Names are case-sensitive.

For example, if `MyProject.csproj` sets `<AssemblyName>MyProject.Core</AssemblyName>`, enter `MyProject.Core`. If it does not set `AssemblyName`, enter `MyProject`, the project filename without `.csproj`. If a shared props file sets the name, use that value. Do not include `.dll` or `.csproj`.

**Existing community license holders can request one early replacement with an assembly-scoped key. These upgrade requests are approved automatically, without another eligibility review. You do not need to wait for your current key to enter its renewal window.**

Apply at [licensing.sixlabors.com](https://licensing.sixlabors.com/). Select open-source or source-available, use the same email address, and provide the assembly names. Later requests follow the normal renewal window: the final 90 days before the expiry date in your license. Commercial licenses are not eligible for this early replacement.

## Security support

The latest major version of each library is eligible for security updates. Each major remains eligible for 12 months after the first stable release of its successor. A later major release does not shorten an existing support window.

Install the latest available patch or minor release within a supported major to receive security fixes. Older releases within that major are not maintained separately. This policy covers security fixes only. It does not include feature backports or extend Microsoft's support for the underlying .NET version. Security fixes remain at Six Labors' discretion.

## Start Here

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
- [Text Shaping](shaping.md)
- [Font Hinting](hinting.md)
- [Color Fonts](colorfonts.md)
- [Unicode, Code Points, and Graphemes](unicode.md)
- [Fallback Fonts and Multilingual Text](fallbackfonts.md)
- [Variable Fonts](variablefonts.md)
- [Custom Rendering](customrendering.md)
- [Recipes](recipes.md)
- [Troubleshooting](troubleshooting.md)

## How to Use These Docs

- Start with font loading and measurement before moving into shaping, fallback, and rendering.
- Use the Unicode pages whenever text ranges, caret movement, styling, or placeholders are involved.
- Use `TextBlock` pages when layout must be measured, inspected, interacted with, and rendered consistently.
- Use custom rendering only after the layout model is clear.
