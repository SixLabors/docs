# Check Glyph Coverage Before Choosing Fallbacks

Before you wire up fallback families, it helps to know what your primary font can already cover. This recipe shows a quick way to probe individual scalar values with [`Font.TryGetGlyphs(...)`](xref:SixLabors.Fonts.Font.TryGetGlyphs*) or scan a string so you can make fallback decisions based on actual glyph coverage instead of guesswork.

### Check individual code points

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Unicode;

Font font = SystemFonts.CreateFont("Segoe UI", 16);

bool hasLatinA = font.TryGetGlyphs(new CodePoint('A'), out _);
bool hasOmega = font.TryGetGlyphs(new CodePoint(0x03A9), out _); // Ω GREEK CAPITAL LETTER OMEGA
bool hasEmoji = font.TryGetGlyphs(new CodePoint(0x1F600), out _); // 😀 GRINNING FACE
```

### Scan a whole string for missing glyphs

```csharp
using System.Collections.Generic;
using SixLabors.Fonts;
using SixLabors.Fonts.Unicode;

string text = "Hello 123 مرحبا 😀";
Font font = SystemFonts.CreateFont("Segoe UI", 16);
List<CodePoint> missing = new();

foreach (CodePoint codePoint in text.AsSpan().EnumerateCodePoints())
{
    if (!font.TryGetGlyphs(codePoint, out _))
    {
        missing.Add(codePoint);
    }
}
```

This is a simple way to decide whether you need `FallbackFontFamilies` before you measure or render the text.

If you want a broader face-level view instead of checking a specific string, use [`Font.FontMetrics.GetAvailableCodePoints()`](xref:SixLabors.Fonts.FontMetrics.GetAvailableCodePoints*).

Glyph coverage is only the first question. A font can contain glyphs for individual code points but still lack the shaping behavior, marks, variation sequences, or color glyph data needed for the text to look right in a real script. Use coverage checks to choose candidate fallback families, then measure or render with the same `TextOptions` you will use in production.

Emoji and complex scripts are the usual cases where this distinction matters. A visible emoji can be a grapheme made from several code points, and Arabic, Indic, or Southeast Asian scripts can require shaping features that are not captured by a one-code-point probe.

For the conceptual fallback guidance, see [Fallback Fonts and Multilingual Text](fallbackfonts.md). For face-level coverage inspection, see [Font Metrics](fontmetrics.md).
