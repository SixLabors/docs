# Text Shaping

Text shaping converts Unicode text into glyph IDs and positions. It takes the source string, the selected fonts, script and direction information, OpenType tables, fallback rules, and requested typographic features, then produces the glyph run that measurement and rendering use.

The input is text. The output is not text anymore. It is an ordered set of glyph IDs, glyph advances, offsets, bidi levels, source indexes, and font metrics. That output is what lets Fonts measure, wrap, hit-test, and render text consistently.

## Why Shaping Exists

Unicode stores text as code points. Fonts store drawable shapes as glyphs. The relationship between the two is many-to-many:

- One code point can map to one glyph, as with many Latin letters.
- Several code points can become one glyph, as with ligatures or composed forms.
- One code point can become multiple glyphs, as with decomposition and fallback behavior.
- A glyph can move because of kerning, mark positioning, cursive attachment, vertical layout, or script rules.
- The visual order can differ from the logical string order in bidirectional text.

For simple English text in a basic font, shaping may look almost invisible. The same pipeline still matters because kerning, ligatures, fallback fonts, line breaks, and source indexes all depend on the shaped result.

## Shaping and Rendering

Shaping decides which glyphs should be used and where those glyphs should be placed. Rendering draws those glyphs onto a target surface.

In Fonts, shaping and rendering are connected but separate responsibilities. Fonts prepares the glyph run and layout data. A renderer then consumes that data to draw paths, color glyph layers, SVG glyphs, or another representation through [`TextRenderer`](xref:SixLabors.Fonts.Rendering.TextRenderer) and [`IGlyphRenderer`](xref:SixLabors.Fonts.Rendering.IGlyphRenderer). ImageSharp.Drawing provides a renderer for drawing text into images, but Fonts itself also supports custom renderers.

This separation matters when you build your own renderer. Do not map characters to glyphs inside the renderer. Let Fonts shape the text once, then render the glyphs it gives you.

## What Fonts Produces

After shaping, Fonts has enough information to answer layout questions in visual terms while still mapping back to the original string.

The shaped data records:

- which font supplied each glyph
- the glyph ID or glyph sequence that should be rendered
- the source code point and grapheme indexes
- the resolved bidi run and embedding level
- glyph advance and positioning data
- glyph bounds and line metrics
- text-run attributes and decorations

This is why shaped text affects more than drawing. It changes measured width, line wrapping, caret movement, hit testing, selection, and text bounds.

## The Fonts Shaping Pipeline

Fonts shapes text during normal measurement and rendering. [`TextMeasurer`](xref:SixLabors.Fonts.TextMeasurer), [`TextBlock`](xref:SixLabors.Fonts.TextBlock), and [`TextRenderer`](xref:SixLabors.Fonts.Rendering.TextRenderer) all use the same [`TextOptions`](xref:SixLabors.Fonts.TextOptions) contract.

At a high level, Fonts does the following:

1. Builds the resolved [`TextRun`](xref:SixLabors.Fonts.TextRun) list for the string. If no runs are supplied, the whole string uses `TextOptions.Font`. If runs are supplied, Fonts orders them, fills gaps with the default font, and trims overlaps.
2. Runs Unicode bidirectional analysis using [`TextDirection`](xref:SixLabors.Fonts.TextOptions.TextDirection) and [`TextBidiMode`](xref:SixLabors.Fonts.TextOptions.TextBidiMode).
3. Walks the text by grapheme and then code point so source indexes remain meaningful for caret, selection, and hit testing.
4. Maps code points to glyph IDs with the current text-run font.
5. Applies right-to-left mirrored forms and vertical alternates where the layout requires them.
6. Applies OpenType GSUB substitutions through the appropriate script shaper.
7. Applies GPOS positioning for kerning, marks, cursive attachment, and related placement behavior.
8. Retries unmapped code points with the configured fallback font families.
9. Updates final glyph positions for every font involved in the shaped result.

The first shaping result is independent of wrapping width. Line composition and alignment happen after shaping, so the same shaped text can be measured, wrapped, rendered, or inspected without changing which glyphs were chosen.

## Script Shapers

Fonts uses the OpenType Layout shaping model. It reads Unicode script data and the OpenType script tags available in the font, then chooses the script shaper for the run.

Specialized shapers handle scripts whose glyph selection or ordering has rules beyond the default feature plan:

- Arabic-family scripts, including Arabic, Syriac, Nko, Mongolian, Mandaic, Manichaean, Phags Pa, and Psalter Pahlavi.
- Hebrew.
- Thai and Lao.
- Hangul.
- Indic scripts such as Devanagari, Bengali, Gujarati, Gurmukhi, Kannada, Malayalam, Oriya, Tamil, Telugu, and Khmer.
- Myanmar when the font exposes the modern `mym2` shaping model.
- Universal Shaping Engine scripts such as Balinese, Brahmi, Chakma, Javanese, Tibetan, Sinhala, Tai Tham, and other complex scripts covered by the USE model.

Other scripts use the default shaper, which still applies common OpenType behavior such as composition, localized forms, required ligatures, standard ligatures, contextual alternates, mark positioning, kerning, and directional alternates.

Fonts does not use HarfBuzz, Graphite, Apple Advanced Typography, Uniscribe, or platform text APIs. It implements its shaping behavior directly in managed code using the font data it loads.

## OpenType Features

Fonts applies required features automatically. You do not need to request core script behavior with [`FeatureTags`](xref:SixLabors.Fonts.TextOptions.FeatureTags).

The default feature plan includes common features such as:

- `ccmp` for glyph composition and decomposition
- `locl` for localized forms
- `rlig` for required ligatures
- `mark` and `mkmk` for mark positioning
- `calt`, `clig`, `liga`, `rclt`, and `curs` for horizontal text where applicable
- `kern` unless kerning is disabled
- `vert` for vertical glyph alternates where applicable
- directional features such as `ltra`, `ltrm`, `rtla`, and `rtlm`
- `rvrn` for required variation alternates

[`FeatureTags`](xref:SixLabors.Fonts.TextOptions.FeatureTags) is for optional features you want to request from the font, such as tabular figures, fractions, stylistic sets, discretionary ligatures, or small capitals. Feature support depends on the font.

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Tables.AdvancedTypographic;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    TextDirection = TextDirection.Auto,
    KerningMode = KerningMode.Standard,
    FeatureTags =
    [
        KnownFeatureTags.Fractions,
        KnownFeatureTags.TabularFigures
    ]
};

FontRectangle bounds = TextMeasurer.MeasureAdvance("9/2", options);
```

Fractions are a good example of a feature that changes the glyph plan. Fonts handles the required `frac`, `numr`, and `dnom` feature assignment around fraction sequences when fraction features are requested.

## Direction and Bidi

Bidirectional text is handled before font substitution and positioning. Fonts resolves directional runs, records the bidi run for each shaped glyph, and uses that information during line layout.

Use [`TextDirection.Auto`](xref:SixLabors.Fonts.TextDirection.Auto) unless your input has an external direction contract. Use [`TextBidiMode`](xref:SixLabors.Fonts.TextOptions.TextBidiMode) when you need override behavior rather than normal Unicode bidi resolution.

Mirrored forms, such as paired punctuation in right-to-left runs, are part of the shaping result. Fonts first relies on font support and also uses Unicode mirror data where needed.

## Fallback Fonts

Fallback is not just a missing-glyph replacement step at the end of rendering. It participates in shaping because each font has its own glyph coverage, metrics, OpenType tables, script tags, and mark positioning behavior.

When the primary text-run font cannot map every code point, Fonts retries unresolved text against [`FallbackFontFamilies`](xref:SixLabors.Fonts.TextOptions.FallbackFontFamilies). The fallback font supplies the glyphs and positions for the code points it covers.

For multilingual text, emoji, and complex scripts, validate fallback with real production strings. A font can contain the individual code points but still lack the OpenType data needed for correct shaping.

## Text Runs and Placeholders

Use [`TextRuns`](xref:SixLabors.Fonts.TextOptions.TextRuns) when a range of text needs a different font, style attributes, decorations, or a placeholder.

Text runs are indexed by grapheme range, not raw UTF-16 code unit count. Fonts resolves the run list before shaping, so font selection and attributes are known when code points are mapped to glyphs.

Placeholder runs are inserted into the layout stream without consuming source text. That makes them useful for inline objects while preserving source text indexes for the surrounding content.

## Measurement and Rendering

Shaping changes advance widths and glyph positions, so measurement and rendering must use the same options. Do not measure with one font, direction, feature set, fallback list, or wrapping policy and render with another.

For one-off layout, use [`TextMeasurer`](xref:SixLabors.Fonts.TextMeasurer). Use [`TextBlock`](xref:SixLabors.Fonts.TextBlock) when the shaped result becomes state: you need to measure it more than once, render it later, inspect its lines, hit-test it, or support caret and selection behavior.

## Practical Guidance

- Treat [`TextOptions`](xref:SixLabors.Fonts.TextOptions) as the shaping contract.
- Use `TextDirection.Auto` for natural text unless a protocol or UI explicitly supplies direction.
- Use `FeatureTags` for optional typography, not for required script shaping.
- Use `FallbackFontFamilies` for multilingual text and test fallback with realistic content.
- Use `TextRuns` for known range-level font or attribute changes.
- Keep measurement, rendering, hit testing, and selection on the same shaped options.
- Validate complex scripts with the actual fonts and strings your application will ship.

## Related Topics

- [Text Layout and Options](textlayout.md)
- [OpenType Features](opentypefeatures.md)
- [Fallback Fonts and Multilingual Text](fallbackfonts.md)
- [Unicode, Code Points, and Graphemes](unicode.md)
- [Prepared Text with TextBlock](textblock.md)
