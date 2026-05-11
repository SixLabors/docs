# Text Layout and Options

Once you have a [`Font`](xref:SixLabors.Fonts.Font), [`TextOptions`](xref:SixLabors.Fonts.TextOptions) becomes the center of almost everything else. It is where you tell Fonts how text should flow, wrap, align, shape, and render, so getting comfortable with this type pays off quickly.

The same options type is used by both [`TextMeasurer`](xref:SixLabors.Fonts.TextMeasurer) and [`TextRenderer`](xref:SixLabors.Fonts.Rendering.TextRenderer), which makes it easy to keep measurement and rendering in sync.

### Core units

[`Font.Size`](xref:SixLabors.Fonts.Font.Size) is expressed in points. [`TextOptions.Dpi`](xref:SixLabors.Fonts.TextOptions.Dpi) controls how that size is converted into pixels for measurement and rendering. The default DPI is `72`.

[`WrappingLength`](xref:SixLabors.Fonts.TextOptions.WrappingLength) is expressed in pixels and defines when text wraps. [`Origin`](xref:SixLabors.Fonts.TextOptions.Origin) sets the rendering origin used by the layout engine.

```csharp
using System.Numerics;
using SixLabors.Fonts;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    Dpi = 96,
    Origin = new Vector2(20, 40),
    WrappingLength = 480
};
```

Replace `"Segoe UI"` with any installed family that exists on your machine in the `SystemFonts` examples on this page.

### Wrapping, flow, and direction

These properties control how text is broken into lines and laid out:

- `WrappingLength`
- `WordBreaking`
- `MaxLines`
- `TextEllipsis`
- `TextHyphenation`
- `TextDirection`
- `LayoutMode`

[`WordBreaking`](xref:SixLabors.Fonts.TextOptions.WordBreaking) supports `Standard`, `BreakAll`, `KeepAll`, and `BreakWord`. [`MaxLines`](xref:SixLabors.Fonts.TextOptions.MaxLines) limits how many lines are laid out; use `-1` for unlimited lines. [`TextDirection`](xref:SixLabors.Fonts.TextOptions.TextDirection) supports left-to-right, right-to-left, and automatic detection. [`LayoutMode`](xref:SixLabors.Fonts.TextOptions.LayoutMode) supports horizontal and vertical layouts, including mixed vertical modes that rotate horizontal glyphs.

```csharp
using SixLabors.Fonts;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    WrappingLength = 320,
    WordBreaking = WordBreaking.BreakWord,
    TextDirection = TextDirection.Auto,
    LayoutMode = LayoutMode.HorizontalTopBottom
};
```

### Ellipsis and hyphenation markers

[`TextEllipsis`](xref:SixLabors.Fonts.TextOptions.TextEllipsis) controls whether a marker is inserted when [`MaxLines`](xref:SixLabors.Fonts.TextOptions.MaxLines) hides remaining text. `TextEllipsis.Standard` inserts the standard ellipsis marker, `TextEllipsis.Custom` uses [`CustomEllipsis`](xref:SixLabors.Fonts.TextOptions.CustomEllipsis), and `TextEllipsis.None` clips to the line limit without adding a marker.

[`TextHyphenation`](xref:SixLabors.Fonts.TextOptions.TextHyphenation) controls the marker used when wrapping selects a soft-hyphen break opportunity. `TextHyphenation.Standard` inserts the standard hyphenation marker, `TextHyphenation.Custom` uses [`CustomHyphen`](xref:SixLabors.Fonts.TextOptions.CustomHyphen), and `TextHyphenation.None` allows the soft-hyphen break without drawing a marker.

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Unicode;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    WrappingLength = 220,
    MaxLines = 2,
    TextEllipsis = TextEllipsis.Standard,
    TextHyphenation = TextHyphenation.Custom,

    // CustomHyphen is used only when wrapping chooses a soft-hyphen break.
    CustomHyphen = new CodePoint('-')
};
```

Set `CustomEllipsis` or `CustomHyphen` only when the matching option is `Custom`. Standard markers still depend on glyph coverage in the selected font or fallback families.

### Alignment and justification

[`TextAlignment`](xref:SixLabors.Fonts.TextOptions.TextAlignment) expresses logical alignment within the text box using `Start`, `End`, and `Center`, and it respects the active text direction. [`TextJustification`](xref:SixLabors.Fonts.TextOptions.TextJustification) controls whether additional spacing is distributed between words or between characters.

[`HorizontalAlignment`](xref:SixLabors.Fonts.TextOptions.HorizontalAlignment) and [`VerticalAlignment`](xref:SixLabors.Fonts.TextOptions.VerticalAlignment) give you physical alignment controls for the layout box itself.

```csharp
using SixLabors.Fonts;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    WrappingLength = 320,
    TextAlignment = TextAlignment.Start,
    TextJustification = TextJustification.InterWord,
    HorizontalAlignment = HorizontalAlignment.Left,
    VerticalAlignment = VerticalAlignment.Top
};
```

### Spacing, hinting, and shaping controls

Fonts exposes several knobs that directly affect glyph layout:

- [`LineSpacing`](xref:SixLabors.Fonts.TextOptions.LineSpacing) multiplies the line height.
- [`TabWidth`](xref:SixLabors.Fonts.TextOptions.TabWidth) controls tab stops in space units.
- [`KerningMode`](xref:SixLabors.Fonts.TextOptions.KerningMode) enables, disables, or lets the engine decide about font-provided kerning during shaping.
- [`Tracking`](xref:SixLabors.Fonts.TextOptions.Tracking) adds uniform spacing after each rendered grapheme. It is measured in em, so `0.02F` adds 2% of the current em size; it is not a multiplier like `LineSpacing`.
- [`HintingMode`](xref:SixLabors.Fonts.TextOptions.HintingMode) is separate from shaping and controls TrueType grid fitting for the current size and DPI.

```csharp
using SixLabors.Fonts;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    LineSpacing = 1.2F,
    TabWidth = 4,
    KerningMode = KerningMode.Standard,
    Tracking = 0.02F,
    HintingMode = HintingMode.Standard
};
```

For a deeper explanation of how Fonts applies GSUB/GPOS shaping, bidi analysis, fallback runs, and TrueType hinting, see [Hinting and Shaping](hintingandshaping.md).

### Fallback fonts and color fonts

Use [`FallbackFontFamilies`](xref:SixLabors.Fonts.TextOptions.FallbackFontFamilies) when a single font cannot cover every glyph you need.

```csharp
using SixLabors.Fonts;

FontCollection collection = new();
FontFamily textFamily = collection.Add("fonts/NotoSans-Regular.ttf");
FontFamily arabicFamily = collection.Add("fonts/NotoSansArabic-Regular.ttf");
FontFamily emojiFamily = collection.Add("fonts/NotoColorEmoji-Regular.ttf");

TextOptions options = new(textFamily.CreateFont(16))
{
    FallbackFontFamilies = [arabicFamily, emojiFamily],
    ColorFontSupport = ColorFontSupport.ColrV1 | ColorFontSupport.Svg
};
```

[`ColorFontSupport`](xref:SixLabors.Fonts.TextOptions.ColorFontSupport) controls which color-font technologies are honored during layout and rendering: `ColrV0`, `ColrV1`, and `Svg`.

For a fuller discussion of multilingual text, fallback ordering, and script coverage, see [Fallback Fonts and Multilingual Text](fallbackfonts.md).

### OpenType feature tags

[`FeatureTags`](xref:SixLabors.Fonts.TextOptions.FeatureTags) lets you request additional OpenType features during shaping. The property type is `IReadOnlyList<Tag>`, which means you can use either [`KnownFeatureTags`](xref:SixLabors.Fonts.Tables.AdvancedTypographic.KnownFeatureTags) enum values or parse raw four-character tags with [`Tag.Parse(...)`](xref:SixLabors.Fonts.Tables.AdvancedTypographic.Tag.Parse*).

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Tables.AdvancedTypographic;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    FeatureTags =
    [
        KnownFeatureTags.Ligatures,
        KnownFeatureTags.TabularFigures,

        // 'ss01' is the first of OpenType's stylistic sets (ss01..ss20),
        // which a font can use to expose an alternate glyph design.
        Tag.Parse("ss01")
    ]
};
```

Use `KnownFeatureTags` values when the feature already has a named constant. Use `Tag.Parse(...)` when you need a raw tag that is not otherwise surfaced in your code.

See [OpenType Features](opentypefeatures.md) for a fuller guide to common feature tags and when to request them explicitly.

### Text runs

[`TextRuns`](xref:SixLabors.Fonts.TextOptions.TextRuns) lets you override layout attributes for subranges of text. A [`TextRun`](xref:SixLabors.Fonts.TextRun) can replace the font and apply `TextAttributes` or `TextDecorations`.

[`TextRun.Start`](xref:SixLabors.Fonts.TextRun.Start) is inclusive and [`TextRun.End`](xref:SixLabors.Fonts.TextRun.End) is exclusive. Both are grapheme indices, not UTF-16 code-unit indices.

```csharp
using SixLabors.Fonts;

const string text = "Title: 1234";

Font baseFont = SystemFonts.CreateFont("Segoe UI", 18);
Font emphasisFont = SystemFonts.CreateFont("Segoe UI", 18, FontStyle.Bold);

TextOptions options = new(baseFont)
{
    TextRuns =
    [
        new TextRun
        {
            Start = 7,
            End = 11,
            Font = emphasisFont,
            TextDecorations = TextDecorations.Underline
        }
    ]
};
```

For plain ASCII text, grapheme indices often line up with character positions. For emoji, combining marks, and complex scripts, calculate ranges in graphemes rather than assuming one UTF-16 code unit equals one visible character.

See [Unicode, Code Points, and Graphemes](unicode.md) for a fuller explanation of `char`, `CodePoint`, and grapheme units.

### Inline placeholders

Use [`TextPlaceholder`](xref:SixLabors.Fonts.TextPlaceholder) when the text layout must reserve space for an inline object that your renderer will draw separately, such as an icon, emoji image, inline control, or attachment. Placeholders participate in measurement, wrapping, bidi ordering, and line-height calculation, but they do not consume text from the source string.

Add a placeholder through a zero-length [`TextRun`](xref:SixLabors.Fonts.TextRun). The run's `Start` and `End` values must be the same grapheme index, because the placeholder is inserted at that point rather than replacing text.

```csharp
using SixLabors.Fonts;

const string text = "Pay now";

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    TextRuns =
    [
        new TextRun
        {
            // Placeholder runs are zero-length insertion points: [Start, End).
            Start = 4,
            End = 4,

            // The placeholder reserves inline space; the caller draws the object itself.
            Placeholder = new TextPlaceholder(
                width: 28,
                height: 20,
                alignment: TextPlaceholderAlignment.Middle,
                baselineOffset: 14)
        }
    ]
};

FontRectangle bounds = TextMeasurer.MeasureAdvance(text, options);
```

[`TextPlaceholderAlignment`](xref:SixLabors.Fonts.TextPlaceholderAlignment) controls how the placeholder box aligns with the surrounding line. `Baseline` uses the supplied baseline offset directly, while `AboveBaseline`, `BelowBaseline`, `Top`, `Bottom`, and `Middle` align the placeholder against the surrounding line box.

### Practical guidance

Treat `TextOptions` as the complete layout contract for a string. Font, culture, DPI, wrapping length, line spacing, direction, layout mode, fallback families, feature tags, text runs, and placeholders all participate in shaping and measurement. If you measure with one set of options and render with another, the result can move, wrap, or shape differently.

Use grapheme indexes for `TextRun` ranges and placeholder insertion points. A placeholder is an insertion into the layout flow, not a replacement for characters in the source string, so its run is zero-length: `[Start, End)` with the same value for both ends. That keeps source text ranges stable while still reserving inline space for an object that your renderer draws separately.

When text must fit inside a known region, set wrapping and alignment explicitly. Avoid measuring a string manually and then adjusting coordinates by hand; that bypasses the layout engine exactly where shaping, fallback, bidi order, and line metrics matter most.
