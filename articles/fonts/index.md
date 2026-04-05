# Introduction

### What is Fonts?
Fonts is a font loading and layout library built primarily to provide text drawing support to ImageSharp.Drawing.

Built against [.NET 6](https://docs.microsoft.com/en-us/dotnet/standard/net-standard), Fonts can be used in device, cloud, and embedded/IoT scenarios.  
  
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
