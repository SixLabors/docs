# OpenType Features

Fonts applies the shaping features that are required for correct layout automatically. `TextOptions.FeatureTags` is for the additional OpenType features you want to request on top of that baseline behavior.

That makes it a typography control, not a substitute for the shaping engine.

### How `FeatureTags` works

`TextOptions.FeatureTags` is an `IReadOnlyList<Tag>`.

You can populate it with:

- named values from `KnownFeatureTags`
- raw four-character tags parsed with `Tag.Parse(...)`

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Tables.AdvancedTypographic;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    FeatureTags = new Tag[]
    {
        KnownFeatureTags.Fractions,
        KnownFeatureTags.TabularFigures,
        Tag.Parse("ss01")
    }
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

Do not think of `FeatureTags` as a way to manually replace the shaping engine. Core script shaping, bidi handling, and other required layout behavior are already handled by Fonts.

### Common feature examples

Fractions:

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Tables.AdvancedTypographic;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
    TextOptions options = new(font)
{
    FeatureTags = new Tag[] { KnownFeatureTags.Fractions }
};
```

Tabular figures for aligned numeric columns:

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Tables.AdvancedTypographic;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    FeatureTags = new Tag[] { KnownFeatureTags.TabularFigures }
};
```

Oldstyle figures plus discretionary ligatures:

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Tables.AdvancedTypographic;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    FeatureTags = new Tag[]
    {
        KnownFeatureTags.OldstyleFigures,
        KnownFeatureTags.DiscretionaryLigatures
    }
};
```

Raw stylistic-set tag:

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Tables.AdvancedTypographic;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    FeatureTags = new Tag[] { Tag.Parse("ss01") }
};
```

### Named tags vs raw tags

Prefer the `KnownFeatureTags` enum when the feature already has a named constant in the library. Use `Tag.Parse(...)` for raw feature tags that you know exist in the target font but that you want to specify directly in your code.

`Tag.Parse(...)` expects a four-character tag such as `"liga"`, `"frac"`, or `"ss01"`.

### Feature tags and layout

Feature requests participate in shaping, so they affect both measurement and rendering. If you want the measured result to match the rendered result, use the same `TextOptions` instance for both `TextMeasurer` and `TextRenderer`.

### Vertical layout

Some OpenType features are especially relevant in vertical layout, such as `KnownFeatureTags.VerticalAlternates`, `KnownFeatureTags.VerticalAlternatesAndRotation`, and `KnownFeatureTags.VerticalAlternatesForRotation`.

Those work alongside `LayoutMode`; they do not replace it.

For the surrounding layout controls, see [Text Layout and Options](textlayout.md). For the broader shaping pipeline, see [Hinting and Shaping](hintingandshaping.md).
