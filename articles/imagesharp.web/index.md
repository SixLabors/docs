# ImageSharp.Web

ImageSharp.Web is Six Labors' high-performance ASP.NET Core image middleware for on-the-fly processing and caching. It sits in front of one or more image providers, parses URL commands, runs the matching ImageSharp processors, and stores the result so repeated requests are inexpensive after the first hit.

The current package targets .NET 8 and is built on top of [ImageSharp](../imagesharp/index.md). The middleware is intentionally modular: you can change how commands are parsed, where source images come from, how cache keys are built, where processed images are stored, and whether image requests must be signed.

## License

ImageSharp.Web is licensed under the terms of the [Six Labors Split License, Version 1.0](https://github.com/SixLabors/ImageSharp.Web/blob/main/LICENSE). See https://sixlabors.com/pricing for commercial licensing details.

>[!IMPORTANT]
>Starting with ImageSharp.Web 4.0.0, projects that directly depend on ImageSharp.Web require a `sixlabors.lic` file to compile. By default, place the file next to your project file, or set `SixLaborsLicenseFile` in your project or shared props file to point to a central location. This enforcement applies to direct dependencies only. See [License Enforcement Changes and a New Subscription Tier](https://sixlabors.com/posts/licence-enforcement-changes/) for details.

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

>[!WARNING]
>Prerelease versions installed via the [Visual Studio NuGet Package Manager](https://docs.microsoft.com/en-us/nuget/consume-packages/install-use-packages-visual-studio) require the "include prerelease" checkbox to be checked.

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
