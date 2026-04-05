# Inspect Font Files and Collections

This recipe is a good starting point when you have a font file in hand and want to learn what it contains before you add it to your app's normal font collection.

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

### Inspect a font collection such as a `.ttc`

```csharp
using System;
using SixLabors.Fonts;

FontDescription[] descriptions =
    FontDescription.LoadFontCollectionDescriptions("fonts/NotoSansCJK-Regular.ttc");

foreach (FontDescription description in descriptions)
{
    Console.WriteLine(description.FontNameInvariantCulture);
}
```

If you do want to load the collection afterward, use `FontCollection.AddCollection(...)`.

For the broader metadata API, see [Font Metadata and Inspection](fontmetadata.md).
