# Prepared Text with TextBlock

[`TextMeasurer`](xref:SixLabors.Fonts.TextMeasurer) is the shortest path from a string to a measurement, but every call shapes the text from scratch. [`TextBlock`](xref:SixLabors.Fonts.TextBlock) does the wrapping-independent work once, then lets you measure, render, and inspect the same text repeatedly at different wrapping lengths.

Use [`TextBlock`](xref:SixLabors.Fonts.TextBlock) whenever the same string will be measured, wrapped, drawn, or inspected more than once: rich-text editors, layout panels that resize, anything that needs both a measurement pass and a render pass.

### Construct once, vary the wrapping length

```csharp
using SixLabors.Fonts;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    Origin = new System.Numerics.Vector2(20, 30)
};

TextBlock block = new("Hello, world!", options);

TextMetrics narrow = block.Measure(240);
TextMetrics wide = block.Measure(480);
```

[`TextOptions.WrappingLength`](xref:SixLabors.Fonts.TextOptions.WrappingLength) is ignored by the constructor. Pass the wrapping length to each operation instead, and use `-1` to disable wrapping for that call.

```csharp
TextMetrics unwrapped = block.Measure(-1);
```

### Detail APIs

[`TextBlock`](xref:SixLabors.Fonts.TextBlock) exposes the same per-entry collections that [`TextMetrics`](xref:SixLabors.Fonts.TextMetrics) does, for callers that do not need the full measurement object:

```csharp
using System;
using SixLabors.Fonts;

ReadOnlyMemory<LineMetrics> lines = block.GetLineMetrics(320);
ReadOnlyMemory<GraphemeMetrics> graphemes = block.GetGraphemeMetrics(320);
ReadOnlyMemory<WordMetrics> words = block.GetWordMetrics(320);
ReadOnlyMemory<GlyphMetrics> glyphs = block.GetGlyphMetrics(320);
```

Method-returned collections use `ReadOnlyMemory<T>` because they are snapshots a caller may store with their own layout state. Owner-backed properties such as `TextMetrics.LineMetrics` and `LineLayout.GraphemeMetrics` use `ReadOnlySpan<T>` because the owner already controls the lifetime.

### Per-line layout

When the UI needs line-local data, use [`GetLineLayouts(...)`](xref:SixLabors.Fonts.TextBlock.GetLineLayouts*) or [`EnumerateLineLayouts()`](xref:SixLabors.Fonts.TextBlock.EnumerateLineLayouts*). Both produce [`LineLayout`](xref:SixLabors.Fonts.LineLayout) instances that mirror the interaction surface of [`TextMetrics`](xref:SixLabors.Fonts.TextMetrics) for a single line — hit testing, caret positioning, caret movement, word lookup, and selection bounds — but they position those lines in different coordinate spaces.

#### Block coordinates with `GetLineLayouts`

[`GetLineLayouts(...)`](xref:SixLabors.Fonts.TextBlock.GetLineLayouts*) lays out the whole block as one unit. Lines stack in their natural flow direction starting from [`TextOptions.Origin`](xref:SixLabors.Fonts.TextOptions.Origin), so each successive line's [`LineMetrics.Start`](xref:SixLabors.Fonts.LineMetrics.Start) includes the cumulative advance of the lines that came before it.

```csharp
using SixLabors.Fonts;

ReadOnlyMemory<LineLayout> layouts = block.GetLineLayouts(320);

foreach (LineLayout line in layouts.Span)
{
    LineMetrics lineMetrics = line.LineMetrics;
    ReadOnlySpan<GraphemeMetrics> lineGraphemes = line.GraphemeMetrics;
    ReadOnlyMemory<GlyphMetrics> lineGlyphs = line.GetGlyphMetrics();
}
```

Use this when the whole block paints into one rectangle and you want the returned geometry to be ready to draw without any further offsetting.

#### Line-local coordinates with `EnumerateLineLayouts`

[`EnumerateLineLayouts()`](xref:SixLabors.Fonts.TextBlock.EnumerateLineLayouts*) lays out one line at a time and accepts the wrapping length per call. Each produced line is positioned independently, as if it were the first and only line in the block — its geometry sits at [`TextOptions.Origin`](xref:SixLabors.Fonts.TextOptions.Origin) regardless of which line index the enumerator is on. The caller is responsible for placing the line into the final layout.

```csharp
using SixLabors.Fonts;

LineLayoutEnumerator enumerator = block.EnumerateLineLayouts();

while (enumerator.MoveNext(wrappingLength: 320))
{
    LineLayout line = enumerator.Current;
}
```

Use this when each line goes into a different column, frame, or shape — flowed text, variable-width columns, virtualized lists, or curved baselines — and the block's natural top-to-bottom stacking does not match the surface you are painting on. The wrapping length can also vary per line.

#### Picking between them

- Use `GetLineLayouts(...)` when the whole block paints as one stacked unit and you want the returned line positions to be ready to draw against the block origin.
- Use `EnumerateLineLayouts()` when the caller controls where each line lands and the block's stacking is not the layout you want.

### Render the prepared block

[`RenderTo(...)`](xref:SixLabors.Fonts.TextBlock.RenderTo*) draws the block to any [`IGlyphRenderer`](xref:SixLabors.Fonts.Rendering.IGlyphRenderer) using the same wrapping-length argument as the measurement methods.

```csharp
using SixLabors.Fonts.Rendering;

block.RenderTo(renderer, wrappingLength: 480);
```

Always render with the same `TextOptions` and wrapping length you measured with. Reusing the prepared block avoids re-shaping the text between the two passes.

### When to choose TextBlock over TextMeasurer

Use `TextMeasurer` for one-off measurements where you do not need to keep a measurement object around.

Use `TextBlock` when:

- The same text is laid out repeatedly with different wrapping lengths.
- You want to measure once and render later with the same prepared shaping.
- You need per-line interaction (hit testing, carets, selection) — see [Hit Testing and Caret Movement](texthittesting.md).
- You want to walk the laid-out text line by line without materializing every line up front.
