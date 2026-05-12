# Measuring Text

Measurement is often the point where text layout stops being abstract and starts affecting a real UI. [`TextMeasurer`](xref:SixLabors.Fonts.TextMeasurer) lets you run the same shaping and layout engine that rendering uses, which means you can decide widths, line breaks, placements, and bounds before anything is drawn.

The measurement APIs come in three layers:

- [`TextMeasurer`](xref:SixLabors.Fonts.TextMeasurer): one-shot convenience methods for measuring a string. Best for ad-hoc work.
- [`TextBlock`](xref:SixLabors.Fonts.TextBlock): prepares a string once, then measures or renders it repeatedly at different wrapping lengths. See [Prepared Text with TextBlock](textblock.md).
- [`TextMetrics`](xref:SixLabors.Fonts.TextMetrics): the full measurement object returned by [`TextMeasurer.Measure(...)`](xref:SixLabors.Fonts.TextMeasurer.Measure*) or [`TextBlock.Measure(...)`](xref:SixLabors.Fonts.TextBlock.Measure*). Keep this when callers need several measurements, hit testing, carets, or selection geometry from the same laid-out text.

### Choose the right measurement

- [`MeasureAdvance(...)`](xref:SixLabors.Fonts.TextMeasurer.MeasureAdvance*) returns the logical advance rectangle from layout, including line height and advance.
- [`MeasureBounds(...)`](xref:SixLabors.Fonts.TextMeasurer.MeasureBounds*) returns only the tight rendered glyph ink bounds.
- [`MeasureRenderableBounds(...)`](xref:SixLabors.Fonts.TextMeasurer.MeasureRenderableBounds*) returns the union of the logical advance rectangle and the glyph ink bounds.

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
```

Replace `"Segoe UI"` with any installed family that exists on your machine.

Use `MeasureAdvance(...)` when you care about layout flow, alignment, wrapping, or line-box size.

Use `MeasureBounds(...)` when you want the pure glyph bounds only.

Use `MeasureRenderableBounds(...)` when you need the full rendered area that combines layout space and glyph overshoot.

### Understand bounds and origin

`MeasureBounds(...)` returns absolute glyph bounds only, so the returned `X` and `Y` can be non-zero, and the width and height reflect only where glyph ink exists.

`MeasureRenderableBounds(...)` returns a larger conceptual rectangle when needed: it includes the full logical advance rectangle from layout and then expands that rectangle to also include any glyph ink that extends beyond it.

If you need a rectangle that can safely contain both the typographic layout box and any glyph overshoot, prefer `MeasureRenderableBounds(...)`.

### Measure per-entry data

`TextMeasurer` exposes three per-entry collections. Each answers a different layout question and is independent of the others.

```csharp
using System;
using SixLabors.Fonts;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    WrappingLength = 320
};

ReadOnlyMemory<GraphemeMetrics> graphemes = TextMeasurer.GetGraphemeMetrics("Hello world", options);
ReadOnlyMemory<WordMetrics> words = TextMeasurer.GetWordMetrics("Hello world", options);
ReadOnlyMemory<GlyphMetrics> glyphs = TextMeasurer.GetGlyphMetrics("Hello world", options);
```

- [`GraphemeMetrics`](xref:SixLabors.Fonts.GraphemeMetrics) is the unit for text interaction: hit testing, caret positioning, range selection, and UI overlays. Use [`Advance`](xref:SixLabors.Fonts.GraphemeMetrics.Advance) for hit targets and selection geometry; [`Bounds`](xref:SixLabors.Fonts.GraphemeMetrics.Bounds) is the rendered ink only and can be empty or overhang.
- [`WordMetrics`](xref:SixLabors.Fonts.WordMetrics) describes one Unicode word-boundary segment from UAX #29, including separators. [`GraphemeStart`](xref:SixLabors.Fonts.WordMetrics.GraphemeStart) and [`StringStart`](xref:SixLabors.Fonts.WordMetrics.StringStart) are inclusive; [`GraphemeEnd`](xref:SixLabors.Fonts.WordMetrics.GraphemeEnd) and [`StringEnd`](xref:SixLabors.Fonts.WordMetrics.StringEnd) are exclusive.
- [`GlyphMetrics`](xref:SixLabors.Fonts.GlyphMetrics) exposes laid-out glyph entries for rendering diagnostics or glyph-level visualization. Do not use them as character or caret positions: ligatures, decomposition, fallback, emoji, and combining marks mean one grapheme can map to multiple glyph entries.

These APIs measure laid-out output, not raw UTF-16 code units, so do not assume a one-to-one mapping with the original string in the presence of shaping, ligatures, or complex scripts.

If you need a refresher on the difference between UTF-16 code units, `CodePoint` values, and graphemes, see [Unicode, Code Points, and Graphemes](unicode.md).

### Measure lines

When you care about wrapped text, use [`CountLines(...)`](xref:SixLabors.Fonts.TextMeasurer.CountLines*) and [`GetLineMetrics(...)`](xref:SixLabors.Fonts.TextMeasurer.GetLineMetrics*).

```csharp
using System;
using SixLabors.Fonts;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    WrappingLength = 320
};

int lineCount = TextMeasurer.CountLines("Hello world from Fonts", options);
ReadOnlyMemory<LineMetrics> lines = TextMeasurer.GetLineMetrics("Hello world from Fonts", options);
```

Each [`LineMetrics`](xref:SixLabors.Fonts.LineMetrics) entry includes:

- `Ascender`: the ascender guide position within the line box. This marks where tall glyphs such as `H` or `l` typically rise to.
- `Baseline`: the baseline position within the line box. This is the line most glyphs sit on.
- `Descender`: the descender guide position within the line box. This marks where descending glyph parts such as `g`, `p`, or `y` typically fall to.
- `LineHeight`: the total height of the line box after line spacing has been applied.
- `Start`: the positioned line-box origin in pixel units.
- `Extent`: the positioned line-box size in pixel units.
- `StringIndex`, `GraphemeIndex`, `GraphemeCount`: the source-text range owned by the line. `GraphemeCount` is not a glyph count.

`Start` and `Extent` are full `Vector2` values. Selection and caret APIs use the line box for the cross-axis size, which matches normal text editor and browser behavior: selecting mixed font sizes on the same line paints a consistent line-height rectangle rather than one rectangle per glyph height.

### Capture the full measurement with `TextMetrics`

When a single layout pass needs to feed several questions — overall size, per-line metrics, per-grapheme positions, hit testing, carets, and selection — measure once and keep the returned [`TextMetrics`](xref:SixLabors.Fonts.TextMetrics).

```csharp
using SixLabors.Fonts;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    WrappingLength = 320
};

TextMetrics metrics = TextMeasurer.Measure("Hello world", options);

FontRectangle advance = metrics.Advance;
FontRectangle bounds = metrics.Bounds;
FontRectangle renderable = metrics.RenderableBounds;
int lineCount = metrics.LineCount;

ReadOnlySpan<LineMetrics> lines = metrics.LineMetrics;
ReadOnlySpan<GraphemeMetrics> graphemes = metrics.GraphemeMetrics;
ReadOnlySpan<WordMetrics> words = metrics.WordMetrics;
```

Line and grapheme collections are in final layout order; for bidi text and reverse line-order layout modes, that can differ from source order. Word collections are in source order because word-boundary navigation is a logical operation.

[`TextMetrics`](xref:SixLabors.Fonts.TextMetrics) returns the per-entry collections as `ReadOnlySpan<T>` because the metrics object owns their lifetime. The [`TextMeasurer`](xref:SixLabors.Fonts.TextMeasurer) and [`TextBlock`](xref:SixLabors.Fonts.TextBlock) methods return `ReadOnlyMemory<T>` because those snapshots can be stored alongside other layout state. Use `.Span` when drawing.

The same object exposes interaction APIs:

```csharp
TextHit hit = metrics.HitTest(point);
CaretPosition caret = metrics.GetCaretPosition(hit);
ReadOnlyMemory<FontRectangle> selection = metrics.GetSelectionBounds(anchor, focus);
```

See [Hit Testing and Caret Movement](texthittesting.md) and [Selection and Bidi Drag](caretsandselection.md) for the full editor-style interaction surface.

### Keep measurement and rendering aligned

Always measure with the same `TextOptions` that you intend to render with. `Dpi`, `LineSpacing`, `WrappingLength`, `TextDirection`, `LayoutMode`, `KerningMode`, `Tracking`, `FeatureTags`, `TextRuns`, and fallback fonts all affect the final layout.

For repeated measurement of the same string at different wrapping lengths, prefer [`TextBlock`](xref:SixLabors.Fonts.TextBlock) over calling [`TextMeasurer`](xref:SixLabors.Fonts.TextMeasurer) multiple times — it shapes the text once and varies wrapping per call.

### Practical guidance

- Measure advance when you need layout flow; measure bounds when you need ink or selection geometry.
- Keep the same `TextOptions` for measuring, rendering, hit testing, and selection.
- Use `TextBlock` when the same shaped text will be inspected or wrapped more than once.
- For UI text, test with the longest localized strings and fallback fonts, not only the default language.
