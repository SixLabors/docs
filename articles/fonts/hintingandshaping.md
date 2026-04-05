# Hinting and Shaping

Hinting and shaping are often mentioned in the same breath because both influence the final appearance of text. For newcomers, it helps to separate them early: shaping decides which glyphs and positions the layout engine should use, while hinting adjusts outlines for pixel-oriented rendering.

Shaping answers "which glyphs should this text use, and where do those glyphs go?"

Hinting answers "how should this specific TrueType outline be adjusted for this size and DPI so it lands cleanly on the pixel grid?"

Fonts has comprehensive support for both, but the scope is different:

- shaping is a full text-layout concern and runs for all normal measurement and rendering
- hinting is a TrueType outline concern and runs when hinted glyph outlines are materialized

### The short version

| Topic | Shaping | Hinting |
| --- | --- | --- |
| Input | Unicode text, script, direction, font selection, OpenType features | A concrete glyph outline, size, and DPI |
| Output | The final glyph sequence and glyph positions | A grid-fitted outline for raster-oriented rendering |
| Main goal | Correct text layout and glyph choice | Better small-size screen rendering |
| Controlled by | `TextDirection`, `FeatureTags`, `KerningMode`, `Tracking`, `TextRuns`, `FallbackFontFamilies`, `LayoutMode` | `HintingMode` |

### What shaping means

Shaping is the process of turning text into the glyph sequence a font actually needs.

That is more than a simple character-to-glyph lookup. A shaping engine may need to:

- choose different glyph forms depending on neighboring text
- form ligatures such as `ffi`
- apply fractions or numeral variants
- position marks relative to a base glyph
- apply kerning and cursive attachment
- reorder glyphs for complex scripts
- resolve bidirectional text and mirrored forms

In other words, shaping works at the typography level. It decides what the text is supposed to look like before any pixel-grid tuning happens.

### Fonts has comprehensive shaping support

Fonts does not require a separate public shaping API for normal use because shaping is built into the layout engine that backs both `TextMeasurer` and `TextRenderer`.

That shaping support includes:

- full OpenType layout processing through GSUB and GPOS
- bidirectional analysis and automatic direction handling through `TextDirection.Auto`
- mirrored-form substitution for right-to-left text where required
- script-aware shapers in the codebase for Arabic, Hangul, Hebrew, Indic, Myanmar, and Thai/Lao text
- a Universal Shaping Engine for additional complex scripts
- kerning, ligatures, fractions, tabular figures, vertical alternates, and other OpenType feature-driven behaviors
- font fallback and per-range font selection through `FallbackFontFamilies` and `TextRuns`

This is why measurement and rendering stay aligned when you use the same `TextOptions` instance for both. Fonts measures shaped text, not a simplified pre-layout approximation.

### What you control in shaping

The main shaping controls are:

- `TextDirection` to force left-to-right, right-to-left, or automatic bidi resolution
- `LayoutMode` for horizontal and vertical layout behavior
- `FeatureTags` to request additional OpenType features such as fractions or tabular figures
- `KerningMode` to enable or disable font-provided kerning during shaping
- `Tracking` to add uniform letter spacing after the font's own spacing behavior
- `FallbackFontFamilies` when the main font does not cover every glyph you need
- `TextRuns` when different text ranges need different fonts, attributes, or decorations

Required script shaping still happens automatically. `FeatureTags` is for extra typographic features you want to request on top of that baseline shaping behavior.

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Tables.AdvancedTypographic;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    TextDirection = TextDirection.Auto,
    KerningMode = KerningMode.Standard,
    FeatureTags = new Tag[]
    {
        KnownFeatureTags.Fractions,
        KnownFeatureTags.TabularFigures
    }
};

FontRectangle bounds = TextMeasurer.MeasureAdvance("9/2", options);
```

### What hinting means

Hinting is not about choosing glyphs. It is about adjusting the points in a glyph outline so the shape lands better on the pixel grid at a particular size and DPI.

That matters most at smaller sizes, where a one-pixel decision can noticeably affect:

- stem thickness
- counter shape
- bar height
- baseline alignment
- mark attachment consistency

At larger sizes the difference is usually much smaller because the outline already has enough pixel resolution to describe itself cleanly.

### Fonts has comprehensive TrueType hinting support

Within the scope of TrueType outlines, Fonts has comprehensive hinting support.

`TextOptions.HintingMode` controls whether that hinting path is active:

- `HintingMode.None` leaves outlines unhinted
- `HintingMode.Standard` applies the library's FreeType v40-compatible TrueType hinting behavior

That means Fonts uses a modern screen-oriented TrueType hinting model rather than treating hinting as old black-and-white full-grid-fitting for legacy CRT text.

The hinting pipeline in Fonts includes:

- TrueType glyph instruction execution
- support for the standard TrueType hinting tables such as `fpgm`, `prep`, and `cvt`
- per-glyph hinting at the active size and DPI
- `cvar`-driven control-value adjustments for variable TrueType fonts before hinting runs
- hinted contour-point resolution for GPOS anchor data when the font uses contour-point anchors

This is specifically a TrueType feature. Fonts only applies this hinting path to TrueType glyph data, so CFF and CFF2 outlines do not gain extra hinting behavior from `HintingMode.Standard`.

```csharp
using SixLabors.Fonts;

Font font = SystemFonts.CreateFont("Segoe UI", 11);
TextOptions options = new(font)
{
    Dpi = 96,
    HintingMode = HintingMode.Standard
};
```

### Hinting and shaping are separate stages

The easiest way to think about the pipeline is:

1. Fonts analyzes the text, script, direction, features, and font selection.
2. Fonts shapes the text into the correct glyph sequence and glyph positions.
3. If the resolved glyphs are TrueType outlines and hinting is enabled, Fonts adjusts those outlines for the current size and DPI.

So:

- shaping decides which glyphs you get and where they belong
- hinting adjusts how those resolved glyphs are fit to the raster grid

Hinting does not choose ligatures, apply Arabic joining, reorder Indic glyphs, or enable OpenType features. Those are shaping concerns.

Shaping does not grid-fit outlines. It decides the typographic result that hinting may later refine for small-size raster output.

### Practical guidance

- Use `TextDirection.Auto` unless you have a specific reason to force directionality.
- Use `FallbackFontFamilies` for multilingual text, emoji, and scripts your main font does not cover.
- Use `FeatureTags` for discretionary features such as fractions, stylistic sets, or tabular figures.
- Use `HintingMode.Standard` when rendering small TrueType UI text and leave it off when you want the raw outline behavior.
- Treat shaping as a typography and layout concern.
- Treat hinting as a size-dependent TrueType raster-quality concern.

For the surrounding layout controls, see [Text Layout and Options](textlayout.md). For multilingual font fallback, see [Fallback Fonts and Multilingual Text](fallbackfonts.md).
