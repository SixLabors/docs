# Font Metadata and Inspection

Sometimes you need to inspect a font long before you care about laying text out with it. Maybe you are building an importer, a picker, or a diagnostics tool. `FontDescription` is the lightweight part of the API for that job.

### Read metadata without loading the font for layout

Use `FontDescription.LoadDescription(...)` when you only need descriptive information from a single font file or stream.

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

`FontDescription` exposes both invariant and culture-aware name accessors:

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

Use `GetNameById(...)` with `KnownNameIds` when you need more than the basic family and subfamily fields.

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

Use `FontDescription.LoadFontCollectionDescriptions(...)` when a file contains multiple faces, such as a `.ttc` collection.

```csharp
using SixLabors.Fonts;

FontDescription[] descriptions =
    FontDescription.LoadFontCollectionDescriptions("fonts/NotoSansCJK-Regular.ttc");
```

If you are loading a collection into a `FontCollection`, the `AddCollection(...)` overloads can also return the descriptions that were discovered during the load.

### Inspect loaded families and fonts

Once a family has been loaded, there are a few additional inspection helpers worth knowing about:

- `FontFamily.GetAvailableStyles()` lists the styles currently available for that family in the collection
- `FontFamily.TryGetPaths(...)` returns source file paths when the family came from filesystem-backed fonts
- `Font.TryGetPath(...)` returns the backing file path for a concrete font instance when one exists
- `Font.FontMetrics.Description` exposes the same `FontDescription` for the resolved face

```csharp
using System;
using SixLabors.Fonts;

FontCollection collection = new();
FontFamily family = collection.Add("fonts/SourceSans3-Regular.ttf");

foreach (FontStyle style in family.GetAvailableStyles())
{
    Console.WriteLine(style);
}

Font font = family.CreateFont(16);
FontDescription description = font.FontMetrics.Description;
```

### What `Style` means

`FontDescription.Style` is the resolved `FontStyle` for that face. Fonts derives it from the face metadata in the font tables, so it is a useful quick check when you want to know whether a face is marked as bold, italic, or both.

For loading fonts into collections, see [Loading Fonts and Collections](gettingstarted.md). For working with installed machine fonts, see [System Fonts](systemfonts.md).

If you want the face-level metrics that drive layout and glyph inspection rather than just the descriptive metadata, see [Font Metrics](fontmetrics.md).
