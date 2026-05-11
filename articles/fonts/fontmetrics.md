# Font Metrics

[`FontDescription`](xref:SixLabors.Fonts.FontDescription) tells you what a face is called. [`FontMetrics`](xref:SixLabors.Fonts.FontMetrics) tells you how that face behaves.

Once you know what a font is, the next question is usually how it behaves. [`FontMetrics`](xref:SixLabors.Fonts.FontMetrics) is where you inspect the measurements and coverage data that explain line spacing, decoration placement, variation support, and glyph availability.

### How to get `FontMetrics`

The most direct route is through a resolved `Font` instance:

```csharp
using System;
using SixLabors.Fonts;

FontCollection collection = new();
FontFamily family = collection.Add("fonts/SourceSans3-Regular.ttf");
Font font = family.CreateFont(16);

FontMetrics metrics = font.FontMetrics;
```

You can also inspect available faces on a family before you create a `Font`.

```csharp
using System;
using SixLabors.Fonts;

FontCollection collection = new();
FontFamily family = collection.Add("fonts/SourceSans3-Regular.ttf");

if (family.TryGetMetrics(FontStyle.Regular, out FontMetrics? metrics))
{
    Console.WriteLine(metrics.Description.FontNameInvariantCulture);
}
```

### Description, units, and scale

The core identity and scaling properties are:

- [`Description`](xref:SixLabors.Fonts.FontMetrics.Description) for the face metadata
- [`UnitsPerEm`](xref:SixLabors.Fonts.FontMetrics.UnitsPerEm) for the design-space resolution of the font
- [`ScaleFactor`](xref:SixLabors.Fonts.FontMetrics.ScaleFactor) for the face-level unit-to-point scaling used by glyph metrics

`UnitsPerEm` is the important anchor for understanding almost every other metric on the typeface. Values like ascenders, underline positions, or glyph advances are stored in font units and should be interpreted relative to that em square.

### Horizontal and vertical metrics

[`FontMetrics`](xref:SixLabors.Fonts.FontMetrics) exposes both [`HorizontalMetrics`](xref:SixLabors.Fonts.FontMetrics.HorizontalMetrics) and [`VerticalMetrics`](xref:SixLabors.Fonts.FontMetrics.VerticalMetrics).

Both headers provide the same core fields:

- `Ascender`
- `Descender`
- `LineGap`
- `LineHeight`
- `AdvanceWidthMax`
- `AdvanceHeightMax`

The difference is not in the property names. It is in which layout direction those values are meant to describe.

- `HorizontalMetrics` describes the face when text is laid out in horizontal modes such as `LayoutMode.HorizontalTopBottom` and `LayoutMode.HorizontalBottomTop`.
- `VerticalMetrics` describes the face when text is laid out in vertical modes such as `LayoutMode.VerticalLeftRight`, `LayoutMode.VerticalRightLeft`, `LayoutMode.VerticalMixedLeftRight`, and `LayoutMode.VerticalMixedRightLeft`.

In practical terms:

- use `HorizontalMetrics` for normal Latin-style line layout, UI text, paragraphs, and most measurement scenarios
- use `VerticalMetrics` for vertical text layout, especially CJK-oriented column flow and vertical glyph advance

### What the fields mean

`Ascender` and `Descender` define the font's recommended extents above and below the baseline for the layout direction you are inspecting.

`LineGap` is the additional space the font recommends between lines or columns beyond the ascender and descender space.

`LineHeight` is the face's typographic line spacing for that metrics header. If you want the font's default line advance, this is usually the most direct value to start from.

`AdvanceWidthMax` is the maximum glyph advance width in that face.

`AdvanceHeightMax` is the maximum glyph advance height in that face. This matters most for vertical layout. For fonts that do not provide dedicated vertical metrics, this value falls back to the line height.

### When to use `HorizontalMetrics`

Reach for `HorizontalMetrics` when you need:

- default line spacing for ordinary left-to-right or right-to-left text
- baseline, ascender, and descender values for UI layout or custom renderers
- a face-level sanity check before measuring or clipping horizontal text
- maximum advance budgeting for horizontally flowing glyphs

```csharp
using SixLabors.Fonts;

Font font = SystemFonts.CreateFont("Segoe UI", 16);
FontMetrics metrics = font.FontMetrics;

short ascender = metrics.HorizontalMetrics.Ascender;
short descender = metrics.HorizontalMetrics.Descender;
short lineHeight = metrics.HorizontalMetrics.LineHeight;
short maxAdvanceWidth = metrics.HorizontalMetrics.AdvanceWidthMax;
```

### When to use `VerticalMetrics`

Reach for `VerticalMetrics` when you need:

- default line or column spacing for vertical layout
- face-level values for custom vertical renderers
- the maximum advance height budget for vertical glyph flow
- inspection of whether a font behaves sensibly in vertical layout

```csharp
using SixLabors.Fonts;

Font font = SystemFonts.CreateFont("Segoe UI", 16);
FontMetrics metrics = font.FontMetrics;

short verticalAscender = metrics.VerticalMetrics.Ascender;
short verticalLineHeight = metrics.VerticalMetrics.LineHeight;
short maxAdvanceHeight = metrics.VerticalMetrics.AdvanceHeightMax;
```

These values are expressed in font units, not pixels.

### Decoration and script-positioning metrics

[`FontMetrics`](xref:SixLabors.Fonts.FontMetrics) also exposes the face-level metrics that support decoration and typographic adjustments:

- `UnderlinePosition`
- `UnderlineThickness`
- `StrikeoutPosition`
- `StrikeoutSize`
- `SubscriptXSize`
- `SubscriptYSize`
- `SubscriptXOffset`
- `SubscriptYOffset`
- `SuperscriptXSize`
- `SuperscriptYSize`
- `SuperscriptXOffset`
- `SuperscriptYOffset`
- `ItalicAngle`

These are useful when you are building your own renderer, diagnostics, or typography tools and want the font's own recommendations rather than hard-coded values.

### Variable-font support

[`FontMetrics.TryGetVariationAxes(...)`](xref:SixLabors.Fonts.FontMetrics.TryGetVariationAxes*) lets you inspect the variation axes that the resolved face supports.

```csharp
using System;
using SixLabors.Fonts;
using SixLabors.Fonts.Tables.AdvancedTypographic.Variations;

FontCollection collection = new();
FontFamily family = collection.Add("fonts/RobotoFlex.ttf");
Font font = family.CreateFont(16);

if (font.FontMetrics.TryGetVariationAxes(out ReadOnlyMemory<VariationAxis> axes))
{
    foreach (VariationAxis axis in axes.Span)
    {
        Console.WriteLine($"{axis.Tag}: {axis.Min}..{axis.Max} (default {axis.Default})");
    }
}
```

Each [`VariationAxis`](xref:SixLabors.Fonts.Tables.AdvancedTypographic.Variations.VariationAxis) gives you:

- `Name`
- `Tag`
- `Min`
- `Max`
- `Default`

The registered tags in [`KnownVariationAxes`](xref:SixLabors.Fonts.KnownVariationAxes) such as `wght`, `wdth`, `opsz`, `slnt`, and `ital` are useful when you want to relate those exposed axes back to font creation with [`FontVariation`](xref:SixLabors.Fonts.FontVariation).

### Code-point coverage

Use [`GetAvailableCodePoints()`](xref:SixLabors.Fonts.FontMetrics.GetAvailableCodePoints*) when you need to know which Unicode scalar values the face can map directly.

```csharp
using System;
using SixLabors.Fonts;
using SixLabors.Fonts.Unicode;

Font font = SystemFonts.CreateFont("Segoe UI", 16);
ReadOnlyMemory<CodePoint> codePoints = font.FontMetrics.GetAvailableCodePoints();
```

This is useful for diagnostics, glyph coverage tooling, fallback decisions, and script-support inspection.

### Inspect glyph metrics directly

If you need glyph-level inspection without going through full text layout, use [`TryGetGlyphMetrics(...)`](xref:SixLabors.Fonts.FontMetrics.TryGetGlyphMetrics*).

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Unicode;

Font font = SystemFonts.CreateFont("Segoe UI", 16);

if (font.FontMetrics.TryGetGlyphMetrics(
        new CodePoint('A'),
        TextAttributes.None,
        TextDecorations.None,
        LayoutMode.HorizontalTopBottom,
        ColorFontSupport.None,
        out FontGlyphMetrics? glyphMetrics))
{
    float width = glyphMetrics.Width;
    ushort advance = glyphMetrics.AdvanceWidth;
    GlyphType glyphType = glyphMetrics.GlyphType;
}
```

This is the lower-level face inspection API behind the higher-level [`Font.TryGetGlyphs(...)`](xref:SixLabors.Fonts.Font.TryGetGlyphs*) helpers.

### When to use `FontMetrics` vs `FontDescription`

Use [`FontDescription`](xref:SixLabors.Fonts.FontDescription) when you care about names and face identity.

Use [`FontMetrics`](xref:SixLabors.Fonts.FontMetrics) when you care about:

- line and em metrics
- underline and strikeout placement
- subscript and superscript recommendations
- variation-axis availability
- code-point coverage
- direct glyph inspection

For face names and other descriptive metadata, see [Font Metadata and Inspection](fontmetadata.md). For variable-font usage, see [Variable Fonts](variablefonts.md).

### Practical guidance

- Use font metrics when layout, decoration, glyph coverage, or variation axes matter.
- Use font descriptions when the question is identity, naming, style, or version metadata.
- Treat glyph availability as a layout input, not as a guarantee of final script quality.
- Cache metrics-derived decisions with the font face and variation values that produced them.
