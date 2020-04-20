# Introduction

### What is ImageSharp.Web?
ImageSharp.Web is a high performance ASP.NET Core Middleware built on top of ImageSharp that allows the processing and caching of image requests via a simple API.

ImageSharp.Web is designed from the ground up to be flexible and extensible. The library provides API endpoints for common image processing operations and the building blocks to allow for the development of addtional extensions to add image sources, caching mechanisms or even your own processing API.  

### License  
Imagesharp.Web is licensed under under the terms of [GNU Affero General
Public License, version 3](https://www.gnu.org/licenses/agpl-3.0.en.html). Commercial licensing options are available in addition to this license, see https://sixlabors.com/pricing for details.
  
### Installation
  
ImageSharp.Web is installed via [Nuget](https://www.nuget.org/packages/SixLabors.ImageSharp.Web) with nightly builds available on [MyGet](https://www.myget.org/feed/sixlabors/package/nuget/SixLabors.ImageSharp.Web).

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
>Prerelease versions installed via the [Visual Studio Nuget Package Manager](https://docs.microsoft.com/en-us/nuget/consume-packages/install-use-packages-visual-studio) require the "include prerelease" checkbox to be checked.