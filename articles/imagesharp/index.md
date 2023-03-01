# Introduction

### What is ImageSharp?
ImageSharp is a modern, fully featured, fully managed, cross-platform, 2D graphics library.
Designed to simplify image processing, ImageSharp brings you an incredibly powerful yet beautifully simple API.

ImageSharp is designed from the ground up to be flexible and extensible. The library provides API endpoints for common image processing operations and the building blocks to allow for the development of additional operations.  

Built against [.NET 6](https://learn.microsoft.com/en-us/dotnet/core/whats-new/dotnet-6), ImageSharp can be used in device, cloud, and embedded/IoT scenarios.  
  
### License  
ImageSharp is licensed under the terms of the [Six Labors Split License, Version 1.0](https://github.com/SixLabors/ImageSharp/blob/main/LICENSE). See https://sixlabors.com/pricing for commercial licensing details.
  
### Installation
  
ImageSharp is installed via [NuGet](https://www.nuget.org/packages/SixLabors.ImageSharp) with nightly builds available on [MyGet](https://www.myget.org/feed/sixlabors/package/nuget/SixLabors.ImageSharp).

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
