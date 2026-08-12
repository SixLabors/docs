# Color Fonts

Color fonts are one of the clearest signs of how much richer modern text rendering has become. Instead of a single monochrome outline, a glyph can carry layers, gradients, or even SVG content, and Fonts exposes that support explicitly through [`ColorFontSupport`](xref:SixLabors.Fonts.ColorFontSupport).

Fonts has comprehensive support for the major OpenType color-font technologies it exposes publicly:

- `ColorFontSupport.ColrV0` for layered solid-color glyphs defined by COLR and CPAL tables
- `ColorFontSupport.ColrV1` for paint-graph glyphs with gradients, transforms, and richer composition
- `ColorFontSupport.Svg` for color glyphs stored in the OpenType SVG table

## Enable or restrict color-font support

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

## Force monochrome output

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

## Font palettes

COLR glyphs take their colors from the font's CPAL palette table. Many color fonts ship more than one palette, such as a default and a dark-background variant. [`TextOptions.FontPalette`](xref:SixLabors.Fonts.TextOptions.FontPalette) selects the palette that resolves the colors. Leave the value `null` to keep the font's default palette.

```csharp
using SixLabors.Fonts;

Font font = SystemFonts.CreateFont("Segoe UI Emoji", 32);
TextOptions options = new(font)
{
    // Resolve COLR glyph colors with the font's second palette.
    // Palette indexes are zero-based; null keeps the font's default.
    FontPalette = new FontPalette(1)
};
```

A palette selection can also override individual entries. Each [`FontPaletteOverride`](xref:SixLabors.Fonts.FontPaletteOverride) replaces the palette color at one index:

```csharp
// Start from the default palette, then replace entry 2 with opaque red.
FontPalette palette = new(0,
[
    new FontPaletteOverride(2, new GlyphColor(255, 0, 0, 255))
]);
```

[`TextRun.FontPalette`](xref:SixLabors.Fonts.TextRun.FontPalette) replaces the selection over a range of text. [`GlyphOptions.FontPalette`](xref:SixLabors.Fonts.GlyphOptions.FontPalette) applies the same selection when rendering or measuring by glyph ID.

## What happens in custom renderers

When a resolved glyph is a painted color glyph, Fonts streams it through [`IGlyphRenderer`](xref:SixLabors.Fonts.Rendering.IGlyphRenderer) as one or more layers.

That means custom renderers should pay attention to:

- [`GlyphRendererParameters.GlyphType`](xref:SixLabors.Fonts.Rendering.GlyphRendererParameters.GlyphType)
- [`BeginLayer(...)`](xref:SixLabors.Fonts.Rendering.IGlyphRenderer.BeginLayer*)
- [`BeginGroup(...)`](xref:SixLabors.Fonts.Rendering.IGlyphRenderer.BeginGroup*) and [`EndGroup()`](xref:SixLabors.Fonts.Rendering.IGlyphRenderer.EndGroup*)
- [`Paint`](xref:SixLabors.Fonts.Rendering.Paint)
- [`FillRule`](xref:SixLabors.Fonts.Rendering.FillRule)
- [`ClipBounds`](xref:SixLabors.Fonts.ClipBounds)

Depending on the font technology in use, the `Paint` passed to `BeginLayer(...)` may be:

- [`SolidPaint`](xref:SixLabors.Fonts.Rendering.SolidPaint)
- [`LinearGradientPaint`](xref:SixLabors.Fonts.Rendering.LinearGradientPaint)
- [`RadialGradientPaint`](xref:SixLabors.Fonts.Rendering.RadialGradientPaint)
- [`SweepGradientPaint`](xref:SixLabors.Fonts.Rendering.SweepGradientPaint)

COLR v1 paint graphs can also form composite groups. Fonts wraps such content in [`BeginGroup(...)`](xref:SixLabors.Fonts.Rendering.IGlyphRenderer.BeginGroup*) and [`EndGroup()`](xref:SixLabors.Fonts.Rendering.IGlyphRenderer.EndGroup*) calls. Layers inside a group compose as one isolated unit. The finished group then blends onto the content below it with the [`CompositeMode`](xref:SixLabors.Fonts.Rendering.CompositeMode) given to `BeginGroup(...)`. A clip for the glyph arrives through [`GlyphRendererParameters.ClipBounds`](xref:SixLabors.Fonts.Rendering.GlyphRendererParameters.ClipBounds).

If your renderer ignores paint information, the glyph can still be drawn, but it will no longer preserve the font's intended color presentation.

## Inspect color glyphs directly

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

## COLR vs SVG in practice

At a high level:

- COLR v0 uses layered shapes with palette colors
- COLR v1 extends that model with richer paint graphs, gradients, transforms, and clipping
- SVG glyphs carry SVG-authored painted content

Fonts resolves those technologies into a common painted-glyph rendering flow, which is why custom renderers can consume them through the same layer and paint callbacks.

## Measurement and rendering stay aligned

Color-font support is part of text layout, not just final painting. If you measure text with one `ColorFontSupport` configuration and render with another, you can create drift between the measured and rendered result.

Use the same [`TextOptions`](xref:SixLabors.Fonts.TextOptions) instance for both [`TextMeasurer`](xref:SixLabors.Fonts.TextMeasurer) and [`TextRenderer`](xref:SixLabors.Fonts.Rendering.TextRenderer) when you want a guaranteed match.

For renderer implementation details, see [Custom Rendering](customrendering.md). For fallback across multiple families, see [Fallback Fonts and Multilingual Text](fallbackfonts.md).

## Practical guidance

- Use the same `ColorFontSupport` setting when measuring and rendering.
- Test the actual emoji or color glyph set you intend to support; technologies vary by font.
- Decide fallback order deliberately when both monochrome and color families can cover the same text.
- Custom renderers should handle painted glyph callbacks even if most text is outline-based.
