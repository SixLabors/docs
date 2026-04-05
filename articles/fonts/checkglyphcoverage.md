# Check Glyph Coverage Before Choosing Fallbacks

This recipe is useful when you want to know whether a font can cover the text you plan to render before you choose fallback families.

### Check individual code points

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Unicode;

Font font = SystemFonts.CreateFont("Segoe UI", 16);

bool hasLatinA = font.TryGetGlyphs(new CodePoint('A'), out _);
bool hasOmega = font.TryGetGlyphs(new CodePoint(0x03A9), out _);
bool hasEmoji = font.TryGetGlyphs(new CodePoint(0x1F600), out _);
```

### Scan a whole string for missing glyphs

```csharp
using System.Collections.Generic;
using SixLabors.Fonts;
using SixLabors.Fonts.Unicode;

string text = "Hello 123 \u0645\u0631\u062D\u0628\u0627 \uD83D\uDE00";
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

If you want a broader face-level view instead of checking a specific string, use `Font.FontMetrics.GetAvailableCodePoints()`.

For the conceptual fallback guidance, see [Fallback Fonts and Multilingual Text](fallbackfonts.md). For face-level coverage inspection, see [Font Metrics](fontmetrics.md).
