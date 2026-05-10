# Use OpenType Features for Numbers and Fractions

This recipe shows the most common way people first encounter discretionary OpenType features: asking fonts through [`TextOptions.FeatureTags`](xref:SixLabors.Fonts.TextOptions.FeatureTags) to align figures more neatly or substitute fraction glyphs for number-heavy text.

### Align numeric columns with tabular figures

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Tables.AdvancedTypographic;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    FeatureTags = [KnownFeatureTags.TabularFigures]
};
```

This is useful for scoreboards, tables, counters, and any UI where digits should line up cleanly.

### Request diagonal fractions

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Tables.AdvancedTypographic;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    FeatureTags = [KnownFeatureTags.Fractions]
};
```

This only has an effect if the font actually provides the requested feature.

### Combine multiple features

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Tables.AdvancedTypographic;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    FeatureTags =
    [
        KnownFeatureTags.TabularFigures,
        KnownFeatureTags.OldstyleFigures,

        // 'ss01' is the first of OpenType's stylistic sets (ss01..ss20),
        // which a font can use to expose an alternate glyph design.
        Tag.Parse("ss01")
    ]
};
```

Use the same `TextOptions` for both `TextMeasurer` and `TextRenderer` so the measured result matches the rendered result.

For the fuller feature model, see [OpenType Features](opentypefeatures.md).
