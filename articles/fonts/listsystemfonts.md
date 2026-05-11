# List System Fonts and Resolve by Culture

This recipe is useful when you want a quick picture of what the current machine can actually provide through [`SystemFonts`](xref:SixLabors.Fonts.SystemFonts), whether for diagnostics, UI pickers, or culture-aware name resolution.

System fonts are environment-dependent. A font that exists on a developer workstation may be missing from a container, CI agent, Linux server, or customer machine. For predictable rendering, ship the fonts you require and load them into a private [`FontCollection`](xref:SixLabors.Fonts.FontCollection). Use `SystemFonts` when the goal is to use what the host operating system already provides.

### List installed families

```csharp
using System;
using SixLabors.Fonts;

foreach (FontFamily family in SystemFonts.Families)
{
    Console.WriteLine(family.Name);
}
```

### Show the searched directories

```csharp
using System;
using SixLabors.Fonts;

foreach (string directory in SystemFonts.Collection.SearchDirectories)
{
    Console.WriteLine(directory);
}
```

### Resolve a family by culture-aware name

```csharp
using System.Globalization;
using SixLabors.Fonts;

CultureInfo japanese = CultureInfo.GetCultureInfo("ja-JP");

if (SystemFonts.TryGetByCulture("Yu Gothic", japanese, out FontFamily family))
{
    Font font = family.CreateFont(16);
}
```

This is especially useful when a family's localized name differs from the invariant name you would use elsewhere.

Culture-aware lookup is about names, not shaping. After you resolve a family, still use the correct `TextOptions.Culture`, fallback families, and layout settings for the text you are measuring or rendering.

For the fuller system-font API surface, see [System Fonts](systemfonts.md).
