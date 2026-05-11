# Font Metadata and Inspection

Sometimes you need to inspect a font long before you care about laying text out with it. Maybe you are building an importer, a picker, or a diagnostics tool. [`FontDescription`](xref:SixLabors.Fonts.FontDescription) is the lightweight part of the API for that job.

### Read metadata without loading the font for layout

Use [`FontDescription.LoadDescription(...)`](xref:SixLabors.Fonts.FontDescription.LoadDescription*) when you only need descriptive information from a single font file or stream.

```csharp
using System.Globalization;
using SixLabors.Fonts;
using SixLabors.Fonts.WellKnownIds;

FontDescription description = FontDescription.LoadDescription("fonts/SourceSans3-Regular.ttf");

string family = description.FontFamilyInvariantCulture;
string fullName = description.FontNameInvariantCulture;
string subfamily = description.FontSubFamilyNameInvariantCulture;
string version = description.GetNameById(CultureInfo.InvariantCulture, KnownNameIds.Version);
```

This is a better fit than `FontCollection.Add(...)` when you are building font pickers, diagnostics, import tools, or metadata listings.

### Work with localized names

[`FontDescription`](xref:SixLabors.Fonts.FontDescription) exposes both invariant and culture-aware name accessors:

- `FontNameInvariantCulture`
- `FontFamilyInvariantCulture`
- `FontSubFamilyNameInvariantCulture`
- `FontName(culture)`
- `FontFamily(culture)`
- `FontSubFamilyName(culture)`

```csharp
using System.Globalization;
using SixLabors.Fonts;

FontDescription description = FontDescription.LoadDescription("fonts/SourceSans3-Regular.ttf");
CultureInfo english = CultureInfo.GetCultureInfo("en-US");

string familyName = description.FontFamily(english);
```

### Read additional name-table entries

Use [`GetNameById(...)`](xref:SixLabors.Fonts.FontDescription.GetNameById*) with [`KnownNameIds`](xref:SixLabors.Fonts.WellKnownIds.KnownNameIds) when you need more than the basic family and subfamily fields.

Common values include:

- `KnownNameIds.Version`
- `KnownNameIds.PostscriptName`
- `KnownNameIds.Designer`
- `KnownNameIds.Manufacturer`
- `KnownNameIds.LicenseDescription`
- `KnownNameIds.LicenseInfoUrl`
- `KnownNameIds.SampleText`

```csharp
using System.Globalization;
using SixLabors.Fonts;
using SixLabors.Fonts.WellKnownIds;

FontDescription description = FontDescription.LoadDescription("fonts/SourceSans3-Regular.ttf");

string designer = description.GetNameById(CultureInfo.InvariantCulture, KnownNameIds.Designer);
string sample = description.GetNameById(CultureInfo.InvariantCulture, KnownNameIds.SampleText);
```

### Inspect font collections

Use [`FontDescription.LoadFontCollectionDescriptions(...)`](xref:SixLabors.Fonts.FontDescription.LoadFontCollectionDescriptions*) when a file contains multiple faces, such as a `.ttc` collection.

```csharp
using System;
using SixLabors.Fonts;

ReadOnlyMemory<FontDescription> descriptions =
    FontDescription.LoadFontCollectionDescriptions("fonts/NotoSansCJK-Regular.ttc");
```

If you are loading a collection into a [`FontCollection`](xref:SixLabors.Fonts.FontCollection), the [`AddCollection(...)`](xref:SixLabors.Fonts.FontCollection.AddCollection*) overloads can also return the descriptions that were discovered during the load.

### Inspect loaded families and fonts

Once a family has been loaded, there are a few additional inspection helpers worth knowing about:

- [`FontFamily.GetAvailableStyles()`](xref:SixLabors.Fonts.FontFamily.GetAvailableStyles*) lists the styles currently available for that family in the collection
- [`FontFamily.TryGetPaths(...)`](xref:SixLabors.Fonts.FontFamily.TryGetPaths*) returns source file paths when the family came from filesystem-backed fonts
- [`Font.TryGetPath(...)`](xref:SixLabors.Fonts.Font.TryGetPath*) returns the backing file path for a concrete font instance when one exists
- [`Font.FontMetrics.Description`](xref:SixLabors.Fonts.FontMetrics.Description) exposes the same [`FontDescription`](xref:SixLabors.Fonts.FontDescription) for the resolved face

```csharp
using System;
using SixLabors.Fonts;

FontCollection collection = new();
FontFamily family = collection.Add("fonts/SourceSans3-Regular.ttf");

foreach (FontStyle style in family.GetAvailableStyles().Span)
{
    Console.WriteLine(style);
}

Font font = family.CreateFont(16);
FontDescription description = font.FontMetrics.Description;
```

### What `Style` means

[`FontDescription.Style`](xref:SixLabors.Fonts.FontDescription.Style) is the resolved [`FontStyle`](xref:SixLabors.Fonts.FontStyle) for that face. Fonts derives it from the face metadata in the font tables, so it is a useful quick check when you want to know whether a face is marked as bold, italic, or both.

For loading fonts into collections, see [Loading Fonts and Collections](gettingstarted.md). For working with installed machine fonts, see [System Fonts](systemfonts.md).

If you want the face-level metrics that drive layout and glyph inspection rather than just the descriptive metadata, see [Font Metrics](fontmetrics.md).

### Practical guidance

- Use metadata inspection before loading untrusted or user-supplied font files into normal collections.
- Store invariant names for stable configuration and localized names for UI.
- Inspect family styles before assuming bold or italic faces are available.
- Use font paths for diagnostics, not as the only identity for a face.
