# Introduction

>[!WARNING]
>Fonts is still considered BETA quality and we still reserve the rights to change the API shapes. WE are yet to priorities performance in our drawing APIs.

### What is Fonts?
Fonts is a font loading and layout library built primarily to provide text drawing support to ImageSharp.Drawing.

Built against [.NET Standard 1.3](https://docs.microsoft.com/en-us/dotnet/standard/net-standard), Fonts can be used in device, cloud, and embedded/IoT scenarios.  
  
### License  
Fonts is licensed under under the terms of [GNU Affero General
Public License, version 3](https://www.gnu.org/licenses/agpl-3.0.en.html). Commercial licensing options are available in addition to this license, see https://sixlabors.com/pricing for details.
  
### Installation
  
ImageSharp.Drawing is installed via [Nuget](https://www.nuget.org/packages/SixLabors.Fonts) with nightly builds available on [MyGet](https://www.myget.org/feed/sixlabors/package/nuget/SixLabors.Fonts).

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
>Prerelease versions installed via the [Visual Studio Nuget Package Manager](https://docs.microsoft.com/en-us/nuget/consume-packages/install-use-packages-visual-studio) require the "include prerelease" checkbox to be checked.