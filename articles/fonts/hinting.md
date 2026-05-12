# TrueType Hinting

Font hinting is the use of instructions in a font to adjust outline glyphs for a raster grid. In TrueType fonts, those instructions are bytecode programs stored in the font. The rasterizer executes them at a given size and DPI to move outline points before the glyph is drawn.

## Why Hinting Exists

Outline fonts are scalable. Raster images are not. When a glyph is small, its outline has to be represented by a limited number of pixels. Without adjustment, similar stems can round to different widths, horizontal features can fall between pixel rows, and small counters or serifs can lose definition.

Hinting changes the scaled outline before rasterization. It can improve:

- stem thickness
- counter shape
- baseline alignment
- x-height consistency
- serif and bar visibility
- mark attachment stability

The effect is most visible for small UI text at ordinary screen DPI. At larger sizes or high-resolution outputs, the outline has more pixels available and hinting usually has less visible effect.

## How Fonts Applies Hinting

[`TextOptions.HintingMode`](xref:SixLabors.Fonts.TextOptions.HintingMode) controls whether Fonts applies TrueType hinting:

- [`HintingMode.None`](xref:SixLabors.Fonts.HintingMode.None) leaves glyph outlines unhinted.
- [`HintingMode.Standard`](xref:SixLabors.Fonts.HintingMode.Standard) applies the library's FreeType v40-compatible TrueType hinting behavior.

```csharp
using SixLabors.Fonts;

Font font = SystemFonts.CreateFont("Segoe UI", 11);
TextOptions options = new(font)
{
    Dpi = 96,
    HintingMode = HintingMode.Standard
};
```

The active font size and [`Dpi`](xref:SixLabors.Fonts.TextOptions.Dpi) matter because hinting targets a specific pixels-per-em scale.

## Fonts' Hinting Approach

Fonts uses a TrueType bytecode interpreter modeled on FreeType's v40 subpixel hinting behavior. In practical terms, that means Fonts preserves full vertical TrueType instruction processing while intentionally disabling horizontal hinting.

This approach is designed for modern antialiased text rendering, where horizontal subpixel placement should remain smooth and glyph advances should not be forced into old bi-level grid-fitting behavior. It gives small text the vertical alignment benefits of TrueType hinting while avoiding legacy horizontal snapping that can make spacing and shapes less consistent in modern raster output.

When hinting is active, Fonts:

- executes the font program from `fpgm` to initialize TrueType function definitions
- scales the Control Value Table from `cvt ` for the current size and DPI
- executes the `prep` program to establish the graphics state for glyph programs
- applies `cvar` deltas to control values for variable TrueType fonts before hinting
- provides normalized variation coordinates for TrueType variation-aware instructions
- adds the four TrueType phantom points used for horizontal and vertical metrics during glyph hinting
- executes each glyph's TrueType instructions against the resolved outline
- leaves the outline unhinted if a glyph has no instructions, hinting is inhibited by the font program, or instruction execution fails

## TrueType Scope

Fonts applies this hinting path to TrueType outlines. It does not turn CFF or CFF2 outlines into hinted TrueType outlines, and it does not change which glyphs are selected for the text.

Within the TrueType path, Fonts supports:

- TrueType glyph instruction execution.
- Standard TrueType hinting tables such as `fpgm`, `prep`, and `cvt `.
- Per-glyph hinting at the active size and DPI.
- `cvar`-driven control-value adjustments for variable TrueType fonts before hinting runs.
- Hinted contour-point resolution for GPOS anchor data when a font uses contour-point anchors.
- Font-specific compatibility behavior for fonts known to require hinting.

## When to Enable It

Use [`HintingMode.Standard`](xref:SixLabors.Fonts.HintingMode.Standard) when rendering small TrueType UI text to a raster target and you want grid-fitted outlines.

Use [`HintingMode.None`](xref:SixLabors.Fonts.HintingMode.None) when you want raw outline behavior, when you are rendering large display text, or when the text is being treated as artwork rather than screen UI.

There is no universal best setting. Hinting is a raster-quality tradeoff: it can make small text clearer, but it can also move outlines away from their pure scaled design.

## Common Misunderstandings

Hinting does not:

- fix missing glyphs
- enable ligatures or OpenType features
- choose fallback fonts
- reorder complex scripts
- resolve bidirectional text
- change Unicode indexing or grapheme behavior

Those are layout and shaping concerns. For those, see [Text Shaping](shaping.md).

## Further Reading

[The Raster Tragedy](http://rastertragedy.com/) is a useful deeper discussion of why rasterizing outline text is difficult and why hinting can matter for small text.

## Related Topics

- [Text Layout and Options](textlayout.md)
- [Text Shaping](shaping.md)
- [Font Metrics](fontmetrics.md)
- [Custom Rendering](customrendering.md)
