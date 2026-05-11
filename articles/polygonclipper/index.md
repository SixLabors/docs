# PolygonClipper

PolygonClipper is Six Labors' high-performance focused geometry library for polygon boolean operations, contour normalization, and stroke-outline generation in managed .NET. It is designed for real 2D geometry workloads: non-convex shapes, holes, multiple contours, overlapping edges, and inputs that need canonicalized output.

The current package targets [.NET 8](https://learn.microsoft.com/en-us/dotnet/core/whats-new/dotnet-8/overview). If you already use [ImageSharp.Drawing](../imagesharp.drawing/index.md), you may already be relying on PolygonClipper indirectly: ImageSharp.Drawing uses it internally for boolean operations against paths and for stroke geometry generation.

Under the hood, the boolean-operation pipeline is based on a Martinez-Rueda sweep-line approach for complex polygon clipping, while normalization uses a separate Vatti/Clipper2-inspired cleanup path for resolving self-intersections and overlaps into positive-winding output. You do not need to understand those algorithms to use the library well, but it helps explain why PolygonClipper is comfortable with complex contour topology.

The library works with geometry, not pixels. Coordinates are numeric vertices, contours are rings, and polygons are collections of rings with explicit hierarchy for holes. That makes PolygonClipper useful before rendering, export, hit testing, path cleanup, or any workflow where you need the region itself rather than a raster mask.

Most users should begin with the static boolean, normalization, and stroking entry points. They take ordinary polygon inputs and return new polygon geometry, so the result can be inspected, transformed, rendered, serialized, or handed to another geometry pipeline.

### License
PolygonClipper is licensed under the terms of the [Six Labors Split License, Version 1.0](https://github.com/SixLabors/PolygonClipper/blob/main/LICENSE). See https://sixlabors.com/pricing for commercial licensing details.

>[!IMPORTANT]
>Starting with PolygonClipper 1.0.0, projects that directly depend on SixLabors.PolygonClipper require a valid Six Labors license at build time. Add `sixlabors.lic` to your repository root, set `SixLaborsLicenseFile`, or set `SixLaborsLicenseKey`. This enforcement applies to direct dependencies only. See [License Enforcement Changes and a New Subscription Tier](https://sixlabors.com/posts/licence-enforcement-changes/) for details.

### Installation

PolygonClipper is installed via [NuGet](https://www.nuget.org/packages/SixLabors.PolygonClipper) with nightly builds available on [Feedz](https://f.feedz.io/sixlabors/sixlabors/nuget/index.json).

# [Package Manager](#tab/tabid-1)

```bash
PM > Install-Package SixLabors.PolygonClipper -Version VERSION_NUMBER
```

# [.NET CLI](#tab/tabid-2)

```bash
dotnet add package SixLabors.PolygonClipper --version VERSION_NUMBER
```

# [PackageReference](#tab/tabid-3)

```xml
<PackageReference Include="SixLabors.PolygonClipper" Version="VERSION_NUMBER" />
```

# [Paket CLI](#tab/tabid-4)

```bash
paket add SixLabors.PolygonClipper --version VERSION_NUMBER
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

- [Getting Started](gettingstarted.md) walks through building a polygon from contours and vertices, then running a first boolean operation.
- [Polygons, Contours, and Holes](polygonsandcontours.md) explains the library's core data model and how hierarchy is represented.
- [Boolean Operations](booleanoperations.md) covers [`Intersection`](xref:SixLabors.PolygonClipper.PolygonClipper.Intersection*), [`Union`](xref:SixLabors.PolygonClipper.PolygonClipper.Union*), [`Difference`](xref:SixLabors.PolygonClipper.PolygonClipper.Difference*), and [`Xor`](xref:SixLabors.PolygonClipper.PolygonClipper.Xor*), including subject-versus-clip semantics.
- [Normalization and Winding](normalization.md) explains when to use [`Normalize(...)`](xref:SixLabors.PolygonClipper.PolygonClipper.Normalize*) to resolve self-intersections and overlaps into positive-winding output.
- [Stroking](stroking.md) covers [`PolygonStroker`](xref:SixLabors.PolygonClipper.PolygonStroker), [`StrokeOptions`](xref:SixLabors.PolygonClipper.StrokeOptions), joins, caps, and open-versus-closed path behavior.
