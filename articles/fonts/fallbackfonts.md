# Fallback Fonts and Multilingual Text

Modern text often mixes scripts, emoji, and symbols that do not all exist in a single font. Fonts handles that through `TextOptions.FallbackFontFamilies`.

When the primary `Font` does not contain a glyph for part of the text, the layout engine searches the fallback families in order and uses the first family that can supply the missing glyphs.

### Use families, not fonts

Fallback is configured with `FontFamily` instances, not `Font` instances.

```csharp
using SixLabors.Fonts;

FontCollection collection = new();
FontFamily latin = collection.Add("fonts/NotoSans-Regular.ttf");
FontFamily arabic = collection.Add("fonts/NotoSansArabic-Regular.ttf");
FontFamily emoji = collection.Add("fonts/NotoColorEmoji-Regular.ttf");

TextOptions options = new(latin.CreateFont(16))
{
    FallbackFontFamilies = new[] { arabic, emoji }
};
```

The primary font still controls the default point size and layout options. When a fallback family is selected, Fonts creates the matching font instance for that run automatically.

### Order matters

Fallback families are searched in the order you provide them.

- Put script-specific fonts before more general fallback fonts.
- Put emoji fonts after your normal text families unless you explicitly want them to win earlier.
- Keep the fallback list as small and intentional as possible so the selection stays predictable.

### Mixed-script example

This pattern works well for text that mixes Latin, Arabic, and emoji:

```csharp
using SixLabors.Fonts;

FontCollection collection = new();
FontFamily latin = collection.Add("fonts/NotoSans-Regular.ttf");
FontFamily arabic = collection.Add("fonts/NotoSansArabic-Regular.ttf");
FontFamily emoji = collection.Add("fonts/NotoColorEmoji-Regular.ttf");

string text = "Status: ready \U0001F600 \u0645\u0631\u062D\u0628\u0627";

TextOptions options = new(latin.CreateFont(18))
{
    FallbackFontFamilies = new[] { arabic, emoji },
    TextDirection = TextDirection.Auto,
    ColorFontSupport = ColorFontSupport.ColrV1 | ColorFontSupport.Svg
};
```

`TextDirection.Auto` lets the layout engine determine whether a run should flow left-to-right or right-to-left. `ColorFontSupport` matters when one of your fallback families is a color emoji font.

### Fallback is not the same as explicit styling

Use fallback fonts when the goal is "use another family if the current one cannot render this text".

Use `TextRuns` when the goal is "this specific range should use a different font even if the base font could render it".

```csharp
using SixLabors.Fonts;

const string text = "Latin title \u0627\u0644\u0639\u0631\u0628\u064A\u0629";

FontCollection collection = new();
FontFamily latin = collection.Add("fonts/NotoSans-Regular.ttf");
FontFamily arabic = collection.Add("fonts/NotoSansArabic-Regular.ttf");

TextOptions options = new(latin.CreateFont(18))
{
    FallbackFontFamilies = new[] { arabic },
    TextRuns = new[]
    {
        new TextRun
        {
            Start = 12,
            End = 19,
            Font = arabic.CreateFont(18)
        }
    }
};
```

The fallback list helps with missing glyphs. `TextRuns` gives you deliberate control over which grapheme ranges use which fonts.

### Wrapping and script behavior

Multilingual text often benefits from layout settings beyond just fallback families:

- `TextDirection.Auto` for mixed LTR and RTL content
- `WordBreaking.KeepAll` or `WordBreaking.BreakWord` for CJK-heavy text
- `LayoutMode` for vertical scripts or mixed vertical presentation

If a script needs shaping support, make sure the selected font actually supports that script. Fallback can only help if one of the supplied families contains the needed glyphs and shaping data.

### Common pitfalls

- A fallback family will not be used if the primary font already has a glyph for that Unicode scalar value, even if you would prefer the fallback font's design.
- `TextRuns` use grapheme indices, not UTF-16 code-unit indices.
- Emoji color layers are only used if `ColorFontSupport` allows them.
- Mixing many broad-coverage fonts can make fallback order hard to reason about.

If layout still looks wrong after fallback is configured, see [Troubleshooting](troubleshooting.md).
