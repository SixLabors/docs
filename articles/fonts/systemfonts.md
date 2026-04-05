# System Fonts

`SystemFonts` gives you access to the fonts installed on the current machine.

Use it when you want to work with platform fonts directly instead of loading files into your own `FontCollection`.

### What `SystemFonts` exposes

The main entry points are:

- `SystemFonts.Families` to enumerate installed families
- `SystemFonts.Get(...)` and `SystemFonts.TryGet(...)` to resolve a family by invariant name
- `SystemFonts.CreateFont(...)` to create a `Font` directly
- `SystemFonts.Collection` when you also need access to the searched directories

```csharp
using SixLabors.Fonts;

Font caption = SystemFonts.CreateFont("Segoe UI", 12);
Font heading = SystemFonts.CreateFont("Segoe UI", 24, FontStyle.Bold);
```

Replace `"Segoe UI"` with any installed family that exists on your machine.

### Enumerate available families

Use `SystemFonts.Families` when you want to inspect what the current environment actually exposes.

```csharp
using System;
using SixLabors.Fonts;

foreach (FontFamily family in SystemFonts.Families)
{
    Console.WriteLine(family.Name);
}
```

### Use culture-aware lookup

Font family names can vary by culture, so `SystemFonts` also exposes the same culture-aware lookup helpers as `FontCollection`.

```csharp
using System.Globalization;
using SixLabors.Fonts;

CultureInfo japanese = CultureInfo.GetCultureInfo("ja-JP");

if (SystemFonts.TryGetByCulture("Yu Gothic", japanese, out FontFamily family))
{
    Font font = family.CreateFont(16);
}
```

You can also create a font directly with the culture-aware `CreateFont(...)` overloads.

### Merge system fonts into your own collection

If you want your own custom fonts and the machine fonts in one lookup surface, copy the system font set into a `FontCollection`.

```csharp
using SixLabors.Fonts;

FontCollection collection = new();
collection.AddSystemFonts();
collection.Add("fonts/BrandSans-Regular.ttf");
```

There is also a filtered overload when you only want a subset of the installed fonts.

```csharp
using System;
using SixLabors.Fonts;

FontCollection collection = new();
collection.AddSystemFonts(metric =>
    metric.Description.FontFamilyInvariantCulture.Contains("Noto", StringComparison.OrdinalIgnoreCase));
```

### Search directories

`SystemFonts.Collection` implements `IReadOnlySystemFontCollection`, which exposes `SearchDirectories`.

That is useful for diagnostics and for understanding where the current process looked for fonts.

```csharp
using System;
using SixLabors.Fonts;

foreach (string directory in SystemFonts.Collection.SearchDirectories)
{
    Console.WriteLine(directory);
}
```

### Portability considerations

The available system fonts are environment-specific.

- Windows, Linux, macOS, containers, and CI agents will often expose different families.
- A family name that exists on your dev machine may not exist in production.
- If predictable output matters, prefer shipping the fonts you need and loading them into a `FontCollection`.

For file-based loading, see [Loading Fonts and Collections](gettingstarted.md). For metadata-only inspection, see [Font Metadata and Inspection](fontmetadata.md).
