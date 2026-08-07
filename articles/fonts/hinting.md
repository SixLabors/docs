# Font Hinting

Font hinting adjusts outline glyphs for a raster grid. TrueType fonts carry bytecode programs that move outline points at a given size and DPI. CFF fonts declare stem hints and alignment zones that a rasterizer fits to the grid. Fonts supports both models.

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

## Hinting Modes

[`TextOptions.HintingMode`](xref:SixLabors.Fonts.TextOptions.HintingMode) controls how Fonts applies hinting:

- [`HintingMode.None`](xref:SixLabors.Fonts.HintingMode.None) leaves glyph outlines unhinted.
- [`HintingMode.Standard`](xref:SixLabors.Fonts.HintingMode.Standard) fits outlines to the pixel grid on the vertical axis only. Horizontal placement stays smooth.
- [`HintingMode.Full`](xref:SixLabors.Fonts.HintingMode.Full) fits outlines and glyph origins to the pixel grid on both axes. This reproduces the classic bi-level grid fitting that font hints were originally authored for.

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

## Standard Hinting

Standard hinting models FreeType's v40 subpixel hinting behavior. For TrueType fonts, it preserves full vertical instruction processing while intentionally disabling horizontal hinting. For CFF fonts, it fits the vertical axis only from the declared hints.

This mode is designed for modern antialiased text rendering, where horizontal subpixel placement remains smooth and glyph advances keep their fractional shaped values. It gives small text the vertical alignment benefits of hinting while avoiding legacy horizontal snapping that can make spacing less consistent.

## Full Hinting

Full hinting reproduces the classic rasterizer pipeline. It produces the sharpest results at small sizes, at the cost of shape fidelity and spacing regularity.

Under full hinting, Fonts:

- rounds the em size to a whole number of pixels, with a minimum of one pixel
- executes the complete horizontal and vertical TrueType instruction set, or fits CFF outlines on both axes
- aligns glyph origins and text decorations to the pixel grid on both axes
- replaces fractional advances on the flow axis with whole-pixel advances

For TrueType fonts, the whole-pixel advance comes from the font's `hdmx` device record when the font carries one. Otherwise Fonts uses the hinted advance that instruction execution produced, or the design advance rounded to whole pixels for glyphs the interpreter could not hint. CFF fonts carry no device advance records, so the design advance rounds to whole pixels.

Whole-pixel advances change spacing. Fractional positioning adjustments on the flow axis, such as pair kerning, are dropped because the classic pipeline never applied them. Inter-glyph spacing can vary by up to half a pixel from the unhinted design. Measurement uses the same advances as rendering, so measured layout and rendered output stay in agreement.

Two cases keep their shaped fractional advances: subscript and superscript runs, and upright glyphs in vertical layout.

## The TrueType Pipeline

Fonts uses a TrueType bytecode interpreter. When hinting is active, Fonts:

- executes the font program from `fpgm` to initialize TrueType function definitions
- scales the Control Value Table from `cvt ` for the current size and DPI
- executes the `prep` program to establish the graphics state for glyph programs
- applies `cvar` deltas to control values for variable TrueType fonts before hinting
- provides normalized variation coordinates for TrueType variation-aware instructions
- adds the four TrueType phantom points used for horizontal and vertical metrics during glyph hinting
- executes each glyph's TrueType instructions against the resolved outline
- leaves the outline unhinted if a glyph has no instructions, hinting is inhibited by the font program, or instruction execution fails

Some fonts are known to require hinting for correct rendering, and some are known to render badly with it. Fonts maintains compatibility lists that force such TrueType fonts to full hinting or to no hinting, regardless of the requested mode.

## The CFF Pipeline

CFF outlines carry no instructions. Instead, the font declares the regularities in its design:

- horizontal and vertical stem hints in each glyph's charstring
- hint masks and counter masks that control which stems apply in each region of the glyph
- alignment zones, standard stem widths, and related values in the Private DICT

When hinting is active, Fonts collects these declared hints while it evaluates the charstring, then fits the outline through a hint map. Standard hinting fits the vertical axis only, from the declared horizontal stem zones and alignment-zone flats. Full hinting fits both axes.

## Choosing a Mode

Use [`HintingMode.Standard`](xref:SixLabors.Fonts.HintingMode.Standard) when rendering small UI text to a raster target and you want grid-fitted outlines with smooth, fractional spacing.

Use [`HintingMode.Full`](xref:SixLabors.Fonts.HintingMode.Full) when you want the sharpest possible small text and accept the classic-rasterizer tradeoffs: whole-pixel spacing, dropped fractional kerning, and altered glyph shapes. It is also the mode to compare output against classic bi-level rasterizers.

Use [`HintingMode.None`](xref:SixLabors.Fonts.HintingMode.None) when you want raw outline behavior, when you are rendering large display text, or when the text is being treated as artwork rather than screen UI.

There is no universal best setting. Hinting is a raster-quality tradeoff: it can make small text clearer, but it can also move outlines away from their pure scaled design.

## Custom Renderers

The requested hinting mode is part of [`GlyphRendererParameters`](xref:SixLabors.Fonts.Rendering.GlyphRendererParameters). A renderer that caches glyph geometry can include the parameters in its cache key, so outlines fitted under one mode are never reused under another.

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
