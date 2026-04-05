# Measuring Text

Measurement is often the point where text layout stops being abstract and starts affecting a real UI. `TextMeasurer` lets you run the same shaping and layout engine that rendering uses, which means you can decide widths, line breaks, placements, and bounds before anything is drawn.

### Choose the right measurement

- `MeasureAdvance(...)` returns the logical advance rectangle from layout, including line height and advance.
- `MeasureBounds(...)` returns only the tight rendered glyph ink bounds.
- `MeasureRenderableBounds(...)` returns the union of the logical advance rectangle and the glyph ink bounds.
- `MeasureSize(...)` returns the rendered width and height normalized to `(0, 0)`.

The important distinction is that glyph geometry and layout geometry are not the same thing. Glyphs can overshoot the logical advance box, and the logical advance box can also include space that no glyph pixels occupy.

### Measure a block of text

```csharp
using SixLabors.Fonts;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    WrappingLength = 320
};

FontRectangle advance = TextMeasurer.MeasureAdvance("Hello world", options);
FontRectangle bounds = TextMeasurer.MeasureBounds("Hello world", options);
FontRectangle renderable = TextMeasurer.MeasureRenderableBounds("Hello world", options);
FontRectangle size = TextMeasurer.MeasureSize("Hello world", options);
```

Replace `"Segoe UI"` with any installed family that exists on your machine.

Use `MeasureAdvance(...)` when you care about layout flow, alignment, wrapping, or line-box size.

Use `MeasureBounds(...)` when you want the pure glyph bounds only.

Use `MeasureRenderableBounds(...)` when you need the full rendered area that combines layout space and glyph overshoot.

### Understand bounds and origin

`MeasureBounds(...)` returns absolute glyph bounds only, so the returned `X` and `Y` can be non-zero, and the width and height reflect only where glyph ink exists.

`MeasureRenderableBounds(...)` returns a larger conceptual rectangle when needed: it includes the full logical advance rectangle from layout and then expands that rectangle to also include any glyph ink that extends beyond it.

`MeasureSize(...)` is the rendered glyph-bounds measurement normalized to width and height only.

If you need a rectangle that can safely contain both the typographic layout box and any glyph overshoot, prefer `MeasureRenderableBounds(...)`.

### Measure per-character entries

Fonts can also expose measurements for each laid-out entry.

```csharp
using System;
using SixLabors.Fonts;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font);

if (TextMeasurer.TryMeasureCharacterBounds("Hello", options, out ReadOnlySpan<GlyphBounds> bounds))
{
    GlyphBounds first = bounds[0];
}
```

These APIs measure laid-out output, not raw UTF-16 code units, so do not assume a one-to-one mapping with the original string in the presence of shaping, ligatures, or complex scripts.

If you need a refresher on the difference between UTF-16 code units, `CodePoint` values, and graphemes, see [Unicode, Code Points, and Graphemes](unicode.md).

Available per-entry methods include:

- `TryMeasureCharacterAdvances(...)`
- `TryMeasureCharacterSizes(...)`
- `TryMeasureCharacterBounds(...)`
- `TryMeasureCharacterRenderableBounds(...)`

### Measure lines

When you care about wrapped text, use `CountLines(...)` and `GetLineMetrics(...)`.

```csharp
using SixLabors.Fonts;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    WrappingLength = 320
};

int lineCount = TextMeasurer.CountLines("Hello world from Fonts", options);
LineMetrics[] lines = TextMeasurer.GetLineMetrics("Hello world from Fonts", options);
```

Each `LineMetrics` entry includes:

- `Ascender`: the ascender guide position within the line box. This marks where tall glyphs such as `H` or `l` typically rise to.
- `Baseline`: the baseline position within the line box. This is the line most glyphs sit on.
- `Descender`: the descender guide position within the line box. This marks where descending glyph parts such as `g`, `p`, or `y` typically fall to.
- `LineHeight`: the total height of the line box after line spacing has been applied.
- `Start`: the aligned start position of the line in the primary flow direction.
- `Extent`: the size of the line in the primary flow direction.

In horizontal layouts, `Start` is the X position and `Extent` is the line width. In vertical layouts, `Start` is the Y position and `Extent` is the line height.

### Keep measurement and rendering aligned

Always measure with the same `TextOptions` that you intend to render with. `Dpi`, `LineSpacing`, `WrappingLength`, `TextDirection`, `LayoutMode`, `KerningMode`, `Tracking`, `FeatureTags`, `TextRuns`, and fallback fonts all affect the final layout.
