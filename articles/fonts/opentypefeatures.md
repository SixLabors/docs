# OpenType Features

Fonts already applies the OpenType features that are required for correct shaping and layout. [`TextOptions.FeatureTags`](xref:SixLabors.Fonts.TextOptions.FeatureTags) is where you ask for the extra typographic touches a font may support, such as tabular figures, fractions, stylistic alternates, or discretionary ligatures.

That makes it a typography control, not a substitute for the shaping engine.

### How `FeatureTags` works

[`TextOptions.FeatureTags`](xref:SixLabors.Fonts.TextOptions.FeatureTags) is an `IReadOnlyList<Tag>`.

You can populate it with:

- named values from [`KnownFeatureTags`](xref:SixLabors.Fonts.Tables.AdvancedTypographic.KnownFeatureTags)
- raw four-character tags parsed with [`Tag.Parse(...)`](xref:SixLabors.Fonts.Tables.AdvancedTypographic.Tag.Parse*)

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Tables.AdvancedTypographic;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    FeatureTags =
    [
        KnownFeatureTags.Fractions,
        KnownFeatureTags.TabularFigures,

        // 'ss01' is the first of OpenType's stylistic sets (ss01..ss20),
        // which a font can use to expose an alternate glyph design.
        Tag.Parse("ss01")
    ]
};
```

A requested feature only has an effect if the font actually supports it.

### When to use feature tags

Use explicit feature tags for discretionary typographic behavior such as:

- fractions
- tabular figures
- oldstyle figures
- discretionary ligatures
- stylistic sets
- small capitals
- case-sensitive punctuation
- vertical alternates

Do not think of [`FeatureTags`](xref:SixLabors.Fonts.TextOptions.FeatureTags) as a way to manually replace the shaping engine. Core script shaping, bidi handling, and other required layout behavior are already handled by Fonts.

### Common feature examples

Fractions:

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Tables.AdvancedTypographic;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    FeatureTags = [KnownFeatureTags.Fractions]
};
```

Tabular figures for aligned numeric columns:

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Tables.AdvancedTypographic;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    FeatureTags = [KnownFeatureTags.TabularFigures]
};
```

Oldstyle figures plus discretionary ligatures:

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Tables.AdvancedTypographic;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    FeatureTags =
    [
        KnownFeatureTags.OldstyleFigures,
        KnownFeatureTags.DiscretionaryLigatures
    ]
};
```

Raw stylistic-set tag:

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Tables.AdvancedTypographic;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{

    // 'ss01' is the first of OpenType's stylistic sets (ss01..ss20),
    // which a font can use to expose an alternate glyph design.
    FeatureTags = [Tag.Parse("ss01")]
};
```

### Named tags vs raw tags

Prefer the [`KnownFeatureTags`](xref:SixLabors.Fonts.Tables.AdvancedTypographic.KnownFeatureTags) enum when the feature already has a named constant in the library. Use [`Tag.Parse(...)`](xref:SixLabors.Fonts.Tables.AdvancedTypographic.Tag.Parse*) for raw feature tags that you know exist in the target font but that you want to specify directly in your code.

[`Tag.Parse(...)`](xref:SixLabors.Fonts.Tables.AdvancedTypographic.Tag.Parse*) expects a four-character tag such as `"liga"`, `"frac"`, or `"ss01"`.

### Feature tags and layout

Feature requests participate in shaping, so they affect both measurement and rendering. If you want the measured result to match the rendered result, use the same `TextOptions` instance for both `TextMeasurer` and `TextRenderer`.

### Vertical layout

Some OpenType features are especially relevant in vertical layout, such as [`KnownFeatureTags.VerticalAlternates`](xref:SixLabors.Fonts.Tables.AdvancedTypographic.KnownFeatureTags.VerticalAlternates), [`KnownFeatureTags.VerticalAlternatesAndRotation`](xref:SixLabors.Fonts.Tables.AdvancedTypographic.KnownFeatureTags.VerticalAlternatesAndRotation), and [`KnownFeatureTags.VerticalAlternatesForRotation`](xref:SixLabors.Fonts.Tables.AdvancedTypographic.KnownFeatureTags.VerticalAlternatesForRotation).

Those work alongside [`LayoutMode`](xref:SixLabors.Fonts.TextOptions.LayoutMode); they do not replace it.

For the surrounding layout controls, see [Text Layout and Options](textlayout.md). For the broader shaping pipeline, see [Hinting and Shaping](hintingandshaping.md).

### Practical guidance

- Treat feature tags as shaping inputs that affect both measurement and rendering.
- Prefer known feature tags where available and raw four-character tags for font-specific features.
- Validate requested features with the actual production font.
- Be careful combining features that intentionally choose competing glyph forms.
