# Loading Fonts and Collections

The quickest way to get comfortable with Fonts is to separate three ideas: where fonts come from, how a family becomes a concrete font instance, and how that font is later used for measurement or rendering. This page walks through that path before the more advanced layout guides.

The main types you will meet first are:

- [`FontCollection`](xref:SixLabors.Fonts.FontCollection) stores the families you load.
- [`FontFamily`](xref:SixLabors.Fonts.FontFamily) represents a family and the styles available for it.
- [`Font`](xref:SixLabors.Fonts.Font) represents a concrete instance of a family at a given point size, style, and optional variation settings.
- [`SystemFonts`](xref:SixLabors.Fonts.SystemFonts) gives you access to the fonts installed on the current machine.

### Load a single font

Use [`FontCollection.Add(...)`](xref:SixLabors.Fonts.FontCollection.Add*) when you want to register an individual font file such as a `.ttf`, `.otf`, `.woff`, or `.woff2`.

```csharp
using SixLabors.Fonts;

FontCollection collection = new();
FontFamily family = collection.Add("fonts/SourceSans3-Regular.ttf");
Font font = family.CreateFont(16, FontStyle.Regular);
```

[`Font.Size`](xref:SixLabors.Fonts.Font.Size) is expressed in points. Measurement and rendering are then converted to pixels using [`TextOptions.Dpi`](xref:SixLabors.Fonts.TextOptions.Dpi).

### Load from a stream and inspect metadata

The `Add(...)` overloads can also return a `FontDescription`, which is useful when you want to inspect what was loaded.

```csharp
using System.IO;
using SixLabors.Fonts;

FontCollection collection = new();

using FileStream stream = File.OpenRead("fonts/SourceSans3-Regular.ttf");
FontFamily family = collection.Add(stream, out FontDescription description);

string familyName = description.FontFamilyInvariantCulture;
Font font = family.CreateFont(16);
```

If you only need metadata, use [`FontDescription.LoadDescription(...)`](xref:SixLabors.Fonts.FontDescription.LoadDescription*) or [`FontDescription.LoadFontCollectionDescriptions(...)`](xref:SixLabors.Fonts.FontDescription.LoadFontCollectionDescriptions*) instead of adding the font to a collection. See [Font Metadata and Inspection](fontmetadata.md) for more detail.

### Load a font collection

Use [`AddCollection(...)`](xref:SixLabors.Fonts.FontCollection.AddCollection*) for files that contain multiple faces, such as `.ttc` collections.

```csharp
using SixLabors.Fonts;

FontCollection collection = new();
var families = collection.AddCollection("fonts/NotoSansCJK-Regular.ttc");
```

### Resolve families by name

Once fonts are loaded, resolve a family with [`Get(...)`](xref:SixLabors.Fonts.FontCollection.Get*) or [`TryGet(...)`](xref:SixLabors.Fonts.FontCollection.TryGet*).

```csharp
using SixLabors.Fonts;

FontCollection collection = new();
collection.Add("fonts/SourceSans3-Regular.ttf");
collection.Add("fonts/NotoColorEmoji-Regular.ttf");

if (collection.TryGet("Source Sans 3", out FontFamily textFamily) &&
    collection.TryGet("Noto Color Emoji", out FontFamily emojiFamily))
{
    TextOptions options = new(textFamily.CreateFont(16))
    {
        FallbackFontFamilies = [emojiFamily]
    };
}
```

[`FallbackFontFamilies`](xref:SixLabors.Fonts.TextOptions.FallbackFontFamilies) is a list of [`FontFamily`](xref:SixLabors.Fonts.FontFamily) instances, not [`Font`](xref:SixLabors.Fonts.Font) instances. Fonts are created after the fallback family is selected for a run.

### Use system fonts

If you want to work with fonts installed on the current machine, use [`SystemFonts`](xref:SixLabors.Fonts.SystemFonts).

```csharp
using SixLabors.Fonts;

Font caption = SystemFonts.CreateFont("Segoe UI", 12);
Font heading = SystemFonts.CreateFont("Segoe UI", 24, FontStyle.Bold);
```

Replace `"Segoe UI"` with any installed family that exists on your machine.

You can also merge the system font set into your own `FontCollection`.

```csharp
using SixLabors.Fonts;

FontCollection collection = new();
collection.AddSystemFonts();
collection.Add("fonts/BrandSans-Regular.ttf");
```

When you need localized family-name lookup, use [`AddWithCulture(...)`](xref:SixLabors.Fonts.FontCollection.AddWithCulture*), [`GetByCulture(...)`](xref:SixLabors.Fonts.FontCollection.GetByCulture*), or [`TryGetByCulture(...)`](xref:SixLabors.Fonts.FontCollection.TryGetByCulture*).

See [System Fonts](systemfonts.md) for the fuller system-font API surface, including enumeration, culture-aware lookup, and `SearchDirectories`.

### Create variable-font instances

Variable fonts are exposed through [`FontVariation`](xref:SixLabors.Fonts.FontVariation) and [`KnownVariationAxes`](xref:SixLabors.Fonts.KnownVariationAxes).

```csharp
using SixLabors.Fonts;

FontCollection collection = new();
FontFamily family = collection.Add("fonts/RobotoFlex.ttf");

Font font = family.CreateFont(
    16,
    new FontVariation(KnownVariationAxes.Weight, 700),
    new FontVariation(KnownVariationAxes.OpticalSize, 16));
```

The active variation values become part of the [`Font`](xref:SixLabors.Fonts.Font) instance, so the same family can be reused to create multiple design-space instances.

### Next steps

- Use [Measuring Text](measuringtext.md) when you need layout metrics before rendering.
- Use [System Fonts](systemfonts.md) when you want to inspect or consume the fonts installed on the current machine.
- Use [Font Metadata and Inspection](fontmetadata.md) when you need names, styles, or version information without loading a font for shaping.
- Use [Text Layout and Options](textlayout.md) to control wrapping, alignment, direction, shaping, fallback fonts, and text runs.
- Use [OpenType Features](opentypefeatures.md) when you want to request fractions, tabular figures, stylistic sets, or other font features explicitly.
- Use [Fallback Fonts and Multilingual Text](fallbackfonts.md) when one family is not enough for your content.
- Use [Variable Fonts](variablefonts.md) when you want to work with weight, width, optical size, or custom axes from a single font file.
- Use [Custom Rendering](customrendering.md) if you need to render glyph geometry to your own output surface.
