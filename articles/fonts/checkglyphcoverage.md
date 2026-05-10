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

For the conceptual fallback guidance, see [Fallback Fonts and Multilingual Text](fallbackfonts.md). For face-level coverage inspection, see [Font Metrics](fontmetrics.md).
