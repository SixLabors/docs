# Text Layout and Options

Once you have a `Font`, `TextOptions` becomes the center of almost everything else. It is where you tell Fonts how text should flow, wrap, align, shape, and render, so getting comfortable with this type pays off quickly.

The same options type is used by both `TextMeasurer` and `TextRenderer`, which makes it easy to keep measurement and rendering in sync.

### Core units

`Font.Size` is expressed in points. `TextOptions.Dpi` controls how that size is converted into pixels for measurement and rendering. The default DPI is `72`.

`WrappingLength` is expressed in pixels and defines when text wraps. `Origin` sets the rendering origin used by the layout engine.

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
- `TextDirection`
- `LayoutMode`

`WordBreaking` supports `Standard`, `BreakAll`, `KeepAll`, and `BreakWord`. `TextDirection` supports left-to-right, right-to-left, and automatic detection. `LayoutMode` supports horizontal and vertical layouts, including mixed vertical modes that rotate horizontal glyphs.

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

### Alignment and justification

`TextAlignment` expresses logical alignment within the text box using `Start`, `End`, and `Center`, and it respects the active text direction. `TextJustification` controls whether additional spacing is distributed between words or between characters.

`HorizontalAlignment` and `VerticalAlignment` give you physical alignment controls for the layout box itself.

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

- `LineSpacing` multiplies the line height.
- `TabWidth` controls tab stops in space units.
- `KerningMode` enables, disables, or lets the engine decide about font-provided kerning during shaping.
- `Tracking` applies uniform letter-spacing and is measured in em.
- `HintingMode` is separate from shaping and controls TrueType grid fitting for the current size and DPI.

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

Use `FallbackFontFamilies` when a single font cannot cover every glyph you need.

```csharp
using SixLabors.Fonts;

FontCollection collection = new();
FontFamily textFamily = collection.Add("fonts/NotoSans-Regular.ttf");
FontFamily arabicFamily = collection.Add("fonts/NotoSansArabic-Regular.ttf");
FontFamily emojiFamily = collection.Add("fonts/NotoColorEmoji-Regular.ttf");

TextOptions options = new(textFamily.CreateFont(16))
{
    FallbackFontFamilies = new[] { arabicFamily, emojiFamily },
    ColorFontSupport = ColorFontSupport.ColrV1 | ColorFontSupport.Svg
};
```

`ColorFontSupport` controls which color-font technologies are honored during layout and rendering: `ColrV0`, `ColrV1`, and `Svg`.

For a fuller discussion of multilingual text, fallback ordering, and script coverage, see [Fallback Fonts and Multilingual Text](fallbackfonts.md).

### OpenType feature tags

`FeatureTags` lets you request additional OpenType features during shaping. The property type is `IReadOnlyList<Tag>`, which means you can use either `KnownFeatureTags` enum values or parse raw four-character tags with `Tag.Parse(...)`.

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Tables.AdvancedTypographic;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    FeatureTags = new Tag[]
    {
        KnownFeatureTags.Ligatures,
        KnownFeatureTags.TabularFigures,
        Tag.Parse("ss01")
    }
};
```

Use `KnownFeatureTags` values when the feature already has a named constant. Use `Tag.Parse(...)` when you need a raw tag that is not otherwise surfaced in your code.

See [OpenType Features](opentypefeatures.md) for a fuller guide to common feature tags and when to request them explicitly.

### Text runs

`TextRuns` lets you override layout attributes for subranges of text. A `TextRun` can replace the font and apply `TextAttributes` or `TextDecorations`.

`TextRun.Start` is inclusive and `TextRun.End` is exclusive. Both are grapheme indices, not UTF-16 code-unit indices.

```csharp
using SixLabors.Fonts;

const string text = "Title: 1234";

Font baseFont = SystemFonts.CreateFont("Segoe UI", 18);
Font emphasisFont = SystemFonts.CreateFont("Segoe UI", 18, FontStyle.Bold);

TextOptions options = new(baseFont)
{
    TextRuns = new[]
    {
        new TextRun
        {
            Start = 7,
            End = 11,
            Font = emphasisFont,
            TextDecorations = TextDecorations.Underline
        }
    }
};
```

For plain ASCII text, grapheme indices often line up with character positions. For emoji, combining marks, and complex scripts, calculate ranges in graphemes rather than assuming one UTF-16 code unit equals one visible character.

See [Unicode, Code Points, and Graphemes](unicode.md) for a fuller explanation of `char`, `CodePoint`, and grapheme units.
