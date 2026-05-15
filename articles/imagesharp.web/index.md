# ImageSharp.Web

ImageSharp.Web is Six Labors' high-performance ASP.NET Core image middleware for on-the-fly processing and caching. It sits in front of one or more image providers, parses URL commands, runs the matching ImageSharp processors, and stores the result so repeated requests are inexpensive after the first hit.

The current package targets .NET 8 and is built on top of [ImageSharp](../imagesharp/index.md). The middleware is intentionally modular: you can change how commands are parsed, where source images come from, how cache keys are built, where processed images are stored, and whether image requests must be signed.

The practical model is a web request pipeline. A provider resolves the original image, a parser turns the request into commands, processors transform the image, an encoder writes the response, and a cache stores the result so the next matching request can avoid the expensive work. Most configuration choices are about one of those stages.

Use ImageSharp.Web when image variants are determined by HTTP requests: responsive thumbnails, CDN-backed transformations, signed URLs, tenant-specific providers, or cached format conversion. Use core ImageSharp directly when processing is an offline job, queue worker, or application workflow that is not naturally request-driven.

## License

ImageSharp.Web is licensed under the terms of the [Six Labors Split License, Version 1.0](https://github.com/SixLabors/ImageSharp.Web/blob/main/LICENSE). See https://sixlabors.com/pricing for commercial licensing details.

>[!IMPORTANT]
>Starting with ImageSharp.Web 4.0.0, projects that directly depend on ImageSharp.Web require a valid Six Labors license at build time. This enforcement applies to direct dependencies only. See [License Enforcement Changes and a New Subscription Tier](https://sixlabors.com/posts/licence-enforcement-changes/) for details.

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

By default, the build searches from each project directory for `sixlabors.lic`. Place the supplied file in the directory that contains the project file, or in a subdirectory below it. Use the file as supplied; it already contains the complete license string required by the build.

>[!IMPORTANT]
>Do not commit `sixlabors.lic` or a license key to public repositories such as open source projects. Use environment variables or repository secrets instead, and let contributors apply for their own independent keys at https://licensing.sixlabors.com/.

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
