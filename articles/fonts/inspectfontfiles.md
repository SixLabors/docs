# Inspect Font Files and Collections

This recipe is a good starting point when you have a font file in hand and want to learn what it contains before you add it to your app's normal font collection with [`FontDescription`](xref:SixLabors.Fonts.FontDescription).

### Read a single font file

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

This is useful for import tools, font pickers, diagnostics, and file-inspection utilities.

Use invariant names when you need stable storage, configuration, or logs. Use culture-specific names when presenting font choices to people, because many families expose localized names that are more useful in UI than the invariant English metadata.

### Inspect a font collection such as a `.ttc`

```csharp
using System;
using SixLabors.Fonts;

ReadOnlyMemory<FontDescription> descriptions =
    FontDescription.LoadFontCollectionDescriptions("fonts/NotoSansCJK-Regular.ttc");

foreach (FontDescription description in descriptions.Span)
{
    Console.WriteLine(description.FontNameInvariantCulture);
}
```

If you do want to load the collection afterward, use [`FontCollection.AddCollection(...)`](xref:SixLabors.Fonts.FontCollection.AddCollection*).

Inspection does not add the font to a collection. That separation is useful for upload validation and tooling: you can reject, categorize, or display font metadata before deciding whether the file should participate in normal font resolution.

For the broader metadata API, see [Font Metadata and Inspection](fontmetadata.md).
