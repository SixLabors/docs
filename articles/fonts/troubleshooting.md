# Troubleshooting

When text does not measure or render the way you expect, the underlying cause is usually one of a few things: family resolution, font-file validity, fallback, shaping assumptions, or misunderstanding the different measurement APIs. This page starts with those common failure modes.

### A font family cannot be found

If `Get(...)` or `SystemFonts.CreateFont(...)` fails, you may see `FontFamilyNotFoundException`.

Typical causes:

- the family name does not match the font's actual family name
- the font was never added to your `FontCollection`
- you are relying on a system font that is not installed on the current machine
- you loaded the font with a culture-specific family name and are resolving it with a different culture

Safer patterns are:

- use `TryGet(...)` instead of `Get(...)` when probing
- inspect `FontDescription` after loading a file
- prefer application-owned font files over machine-specific `SystemFonts` when portability matters

### A font file loads poorly or throws

Invalid or unsupported font data can surface as:

- `InvalidFontFileException`
- `InvalidFontTableException`
- `MissingFontTableException`

If you hit one of these:

- verify the file is a real font and not an incomplete download
- prefer loading from a stable local file or stream
- if the font is a collection, use `AddCollection(...)` or `LoadFontCollectionDescriptions(...)`

### Text renders with missing glyphs

If some characters do not render as expected:

- make sure the selected font actually contains the script you need
- add script-specific families to `FallbackFontFamilies`
- enable color-font support if the missing content is emoji
- use `TryGetGlyphs(...)` when you need to probe a specific `CodePoint` value directly

Fallback can only help if one of the supplied families actually contains the required glyphs.

### Fallback fonts are not being used

The most common reason is that the primary font already contains a glyph for that Unicode scalar value, so fallback never activates.

If you want a specific range to use a different font even when the primary font could render it, use `TextRuns` instead of relying on fallback.

Fallback order also matters. Fonts searches `FallbackFontFamilies` in order and uses the first suitable family it finds.

### RTL or complex-script text looks wrong

Check these first:

- use a font that actually supports the script
- set `TextDirection = TextDirection.Auto` or explicitly choose the correct direction
- avoid assuming simple one-character-per-glyph behavior
- verify your fallback families cover the script, not just isolated characters

Arabic, Indic, Thai, Hebrew, and similar scripts depend on shaping, not just raw Unicode coverage.

### Measurements look larger or smaller than expected

This is usually a measurement-choice issue:

- `MeasureAdvance(...)` is the logical layout box
- `MeasureBounds(...)` is pure glyph ink bounds
- `MeasureRenderableBounds(...)` is the union of the two

It is normal for these values to differ. Italics, accents, and decorative forms often extend outside the advance box, while line height can add space that no glyph pixels occupy.

### Text run indices look wrong

`TextRun.Start` and `TextRun.End` are grapheme indices, not UTF-16 code-unit indices.

That matters for:

- emoji
- combining marks
- ligatures
- many non-Latin scripts

If a text run seems offset or slices the wrong part of the string, re-check the range in grapheme terms.

See [Unicode, Code Points, and Graphemes](unicode.md) for the distinction between raw `char` positions, `CodePoint` values, and grapheme indices.

### Variable font changes do nothing

Usually one of these is true:

- the font is not actually variable
- the axis tag is wrong
- the value is outside the font's supported range

Use `font.FontMetrics.TryGetVariationAxes(...)` to inspect the actual axes and ranges exposed by the font. `FontVariation` tags must be exactly four characters.

### System font behavior differs by machine

`SystemFonts` is convenient, but it is not deterministic across environments. Different machines can have different installed families, versions, and script coverage.

If you need repeatable output across CI, servers, containers, and user machines, ship your own fonts and load them through `FontCollection`.
