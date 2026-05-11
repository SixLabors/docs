# System Fonts

[`SystemFonts`](xref:SixLabors.Fonts.SystemFonts) are convenient because they let you get moving without shipping font files yourself. They also come with the tradeoff that the available families depend on the machine you are running on, so this page treats portability as part of the topic rather than an afterthought.

Use it when you want to work with platform fonts directly instead of loading files into your own [`FontCollection`](xref:SixLabors.Fonts.FontCollection).

### What `SystemFonts` exposes

The main entry points are:

- [`SystemFonts.Families`](xref:SixLabors.Fonts.SystemFonts.Families) to enumerate installed families
- [`SystemFonts.Get(...)`](xref:SixLabors.Fonts.SystemFonts.Get*) and [`SystemFonts.TryGet(...)`](xref:SixLabors.Fonts.SystemFonts.TryGet*) to resolve a family by invariant name
- [`SystemFonts.CreateFont(...)`](xref:SixLabors.Fonts.SystemFonts.CreateFont*) to create a [`Font`](xref:SixLabors.Fonts.Font) directly
- [`SystemFonts.Collection`](xref:SixLabors.Fonts.SystemFonts.Collection) when you also need access to the searched directories

```csharp
using SixLabors.Fonts;

Font caption = SystemFonts.CreateFont("Segoe UI", 12);
Font heading = SystemFonts.CreateFont("Segoe UI", 24, FontStyle.Bold);
```

Replace `"Segoe UI"` with any installed family that exists on your machine.

### Enumerate available families

Use [`SystemFonts.Families`](xref:SixLabors.Fonts.SystemFonts.Families) when you want to inspect what the current environment actually exposes.

```csharp
using System;
using SixLabors.Fonts;

foreach (FontFamily family in SystemFonts.Families)
{
    Console.WriteLine(family.Name);
}
```

### Use culture-aware lookup

Font family names can vary by culture, so [`SystemFonts`](xref:SixLabors.Fonts.SystemFonts) also exposes the same culture-aware lookup helpers as [`FontCollection`](xref:SixLabors.Fonts.FontCollection).

```csharp
using System.Globalization;
using SixLabors.Fonts;

CultureInfo japanese = CultureInfo.GetCultureInfo("ja-JP");

if (SystemFonts.TryGetByCulture("Yu Gothic", japanese, out FontFamily family))
{
    Font font = family.CreateFont(16);
}
```

You can also create a font directly with the culture-aware [`CreateFont(...)`](xref:SixLabors.Fonts.SystemFonts.CreateFont*) overloads.

### Merge system fonts into your own collection

If you want your own custom fonts and the machine fonts in one lookup surface, copy the system font set into a [`FontCollection`](xref:SixLabors.Fonts.FontCollection).

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

[`SystemFonts.Collection`](xref:SixLabors.Fonts.SystemFonts.Collection) implements [`IReadOnlySystemFontCollection`](xref:SixLabors.Fonts.IReadOnlySystemFontCollection), which exposes [`SearchDirectories`](xref:SixLabors.Fonts.IReadOnlySystemFontCollection.SearchDirectories).

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
- If predictable output matters, prefer shipping the fonts you need and loading them into a [`FontCollection`](xref:SixLabors.Fonts.FontCollection).

For file-based loading, see [Loading Fonts and Collections](gettingstarted.md). For metadata-only inspection, see [Font Metadata and Inspection](fontmetadata.md).

### Practical guidance

- Use `SystemFonts` for host-specific behavior and diagnostics.
- Use a private `FontCollection` for deterministic rendering.
- Log `SearchDirectories` when diagnosing missing fonts in containers or CI.
- Resolve by culture-aware names only when the user-facing font name is localized.
