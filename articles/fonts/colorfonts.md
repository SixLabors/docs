# Color Fonts

Color fonts are one of the clearest signs of how much richer modern text rendering has become. Instead of a single monochrome outline, a glyph can carry layers, gradients, or even SVG content, and Fonts exposes that support explicitly through [`ColorFontSupport`](xref:SixLabors.Fonts.ColorFontSupport).

Fonts has comprehensive support for the major OpenType color-font technologies it exposes publicly:

- `ColorFontSupport.ColrV0` for layered solid-color glyphs defined by COLR and CPAL tables
- `ColorFontSupport.ColrV1` for paint-graph glyphs with gradients, transforms, and richer composition
- `ColorFontSupport.Svg` for color glyphs stored in the OpenType SVG table

### Enable or restrict color-font support

[`TextOptions.ColorFontSupport`](xref:SixLabors.Fonts.TextOptions.ColorFontSupport) controls which color-font technologies are honored during layout and rendering.

```csharp
using SixLabors.Fonts;

FontCollection collection = new();
FontFamily family = collection.Add("fonts/NotoColorEmoji-Regular.ttf");
Font font = family.CreateFont(32);

TextOptions options = new(font)
{
    ColorFontSupport = ColorFontSupport.ColrV1 | ColorFontSupport.ColrV0 | ColorFontSupport.Svg
};
```

[`TextOptions`](xref:SixLabors.Fonts.TextOptions) enables all three by default, so you usually only need to set this property when you want to disable color glyphs or restrict the allowed formats.

### Force monochrome output

Set [`ColorFontSupport.None`](xref:SixLabors.Fonts.ColorFontSupport.None) when you want color-font-capable text to fall back to monochrome outline rendering.

```csharp
using SixLabors.Fonts;

FontCollection collection = new();
FontFamily family = collection.Add("fonts/NotoColorEmoji-Regular.ttf");
Font font = family.CreateFont(32);

TextOptions options = new(font)
{
    ColorFontSupport = ColorFontSupport.None
};
```

### What happens in custom renderers

When a resolved glyph is a painted color glyph, Fonts streams it through [`IGlyphRenderer`](xref:SixLabors.Fonts.Rendering.IGlyphRenderer) as one or more layers.

That means custom renderers should pay attention to:

- [`GlyphRendererParameters.GlyphType`](xref:SixLabors.Fonts.Rendering.GlyphRendererParameters.GlyphType)
- [`BeginLayer(...)`](xref:SixLabors.Fonts.Rendering.IGlyphRenderer.BeginLayer*)
- [`Paint`](xref:SixLabors.Fonts.Rendering.Paint)
- [`FillRule`](xref:SixLabors.Fonts.Rendering.FillRule)
- [`ClipQuad`](xref:SixLabors.Fonts.ClipQuad)

Depending on the font technology in use, the `Paint` passed to `BeginLayer(...)` may be:

- [`SolidPaint`](xref:SixLabors.Fonts.Rendering.SolidPaint)
- [`LinearGradientPaint`](xref:SixLabors.Fonts.Rendering.LinearGradientPaint)
- [`RadialGradientPaint`](xref:SixLabors.Fonts.Rendering.RadialGradientPaint)
- [`SweepGradientPaint`](xref:SixLabors.Fonts.Rendering.SweepGradientPaint)

If your renderer ignores paint information, the glyph can still be drawn, but it will no longer preserve the font's intended color presentation.

### Inspect color glyphs directly

If you need to inspect a glyph without running full text layout, use [`Font.TryGetGlyphs(...)`](xref:SixLabors.Fonts.Font.TryGetGlyphs*) with explicit color support.

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Unicode;

FontCollection collection = new();
FontFamily family = collection.Add("fonts/NotoColorEmoji-Regular.ttf");
Font font = family.CreateFont(32);

if (font.TryGetGlyphs(
        new CodePoint(0x1F600), // 😀 GRINNING FACE
        ColorFontSupport.ColrV1 | ColorFontSupport.ColrV0 | ColorFontSupport.Svg,
        out Glyph? glyph))
{
    bool isPainted = glyph.GlyphMetrics.GlyphType == GlyphType.Painted;
}
```

### COLR vs SVG in practice

At a high level:

- COLR v0 uses layered shapes with palette colors
- COLR v1 extends that model with richer paint graphs, gradients, transforms, and clipping
- SVG glyphs carry SVG-authored painted content

Fonts resolves those technologies into a common painted-glyph rendering flow, which is why custom renderers can consume them through the same layer and paint callbacks.

### Measurement and rendering stay aligned

Color-font support is part of text layout, not just final painting. If you measure text with one `ColorFontSupport` configuration and render with another, you can create drift between the measured and rendered result.

Use the same [`TextOptions`](xref:SixLabors.Fonts.TextOptions) instance for both [`TextMeasurer`](xref:SixLabors.Fonts.TextMeasurer) and [`TextRenderer`](xref:SixLabors.Fonts.Rendering.TextRenderer) when you want a guaranteed match.

For renderer implementation details, see [Custom Rendering](customrendering.md). For fallback across multiple families, see [Fallback Fonts and Multilingual Text](fallbackfonts.md).
