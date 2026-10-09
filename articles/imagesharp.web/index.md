# ImageSharp.Web

ImageSharp.Web is Six Labors' high-performance ASP.NET Core image middleware for on-the-fly processing and caching. It sits in front of one or more image providers, parses URL commands, runs the matching ImageSharp processors, and stores the result so repeated requests are inexpensive after the first hit.

The current package targets .NET 8 and is built on top of [ImageSharp](../imagesharp/index.md). The middleware is intentionally modular: you can change how commands are parsed, where source images come from, how cache keys are built, where processed images are stored, and whether image requests must be signed.

The practical model is a web request pipeline. A provider resolves the original image, a parser turns the request into commands, processors transform the image, an encoder writes the response, and a cache stores the result so the next matching request can avoid the expensive work. Most configuration choices are about one of those stages.

Use ImageSharp.Web when image variants are determined by HTTP requests: responsive thumbnails, CDN-backed transformations, signed URLs, tenant-specific providers, or cached format conversion. Use core ImageSharp directly when processing is an offline job, queue worker, or application workflow that is not naturally request-driven.

## License

ImageSharp.Web is licensed under the terms of the [Six Labors Split License, Version 1.0](https://github.com/SixLabors/ImageSharp.Web/blob/main/LICENSE). See https://sixlabors.com/pricing for commercial licensing details.

>[!IMPORTANT]
>Projects that directly reference ImageSharp.Web require a valid Six Labors license key at build time from version 3.3.0 in the previous major and 4.0.0 in the current major. Enforcement applies to direct dependencies only. This is enforcement of the existing license terms, not a license change.

## Install ImageSharp.Web

ImageSharp.Web is distributed on [NuGet](https://www.nuget.org/packages/SixLabors.ImageSharp.Web) with preview and nightly builds available on [Feedz](https://f.feedz.io/sixlabors/sixlabors/nuget/index.json).

# [Package Manager](#tab/tabid-1)

```bash
PM > Install-Package SixLabors.ImageSharp.Web -Version VERSION_NUMBER
```

# [.NET CLI](#tab/tabid-2)

```bash
dotnet add package SixLabors.ImageSharp.Web --version VERSION_NUMBER
```

# [PackageReference](#tab/tabid-3)

```xml
<PackageReference Include="SixLabors.ImageSharp.Web" Version="VERSION_NUMBER" />
```

# [Paket CLI](#tab/tabid-4)

```bash
paket add SixLabors.ImageSharp.Web --version VERSION_NUMBER
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

- [Getting Started](gettingstarted.md) covers the minimal ASP.NET Core setup and the default provider and cache behavior.
- [Configuration and Pipeline](configuration.md) explains what `AddImageSharp()` registers, the middleware's default auto-orientation behavior, web-focused encoder defaults, ICC profile handling, and how to replace or reorder the moving parts.
- [Processing Commands](processingcommands.md) documents the built-in resize, auto-orient, format, quality, and background-color commands, including which ones are implicit by default.
- [Image Providers](imageproviders.md) covers filesystem, Azure Blob Storage, and AWS S3 source images.
- [Image Caches](imagecaches.md) covers the default physical cache, cloud cache backends, cache keys, and cache lifetime.
- [Securing Requests](security.md) explains HMAC signing and preset-only parsing.
- [Tag Helpers](taghelpers.md) covers Razor integration and automatic HMAC generation.
- [Extensibility](extensibility.md) walks through custom processors, parsers, providers, caches, and converters.
- [Troubleshooting](troubleshooting.md) covers the most common middleware-order, provider, cache, and signing problems.

## Implicit Usings

Set `UseImageSharp` in your project file to automatically import the most common ImageSharp and ImageSharp.Web namespaces:

```xml
<PropertyGroup>
  <UseImageSharp>true</UseImageSharp>
</PropertyGroup>
```

When enabled, ImageSharp.Web adds implicit `global using` directives for:

- `SixLabors.ImageSharp`
- `SixLabors.ImageSharp.Processing`
- `SixLabors.ImageSharp.Web`

You can turn this off by removing the property or setting it to `false`.

## How to Use These Docs

- Start with getting started and processing commands to understand the default request pipeline.
- Read configuration, providers, and caches before deploying beyond a single local filesystem setup.
- Read security before exposing arbitrary command URLs to clients.
- Use extensibility only after choosing which pipeline stage actually owns the behavior you need.
