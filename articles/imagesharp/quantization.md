# Quantization, Palettes, and Dithering

Quantization is the part of image processing where you stop thinking in terms of continuous color and start thinking in terms of a limited palette. Even if you never call `Quantize()` directly, it still matters because formats like GIF, indexed PNG, CUR, and ICO rely on the same ideas.

In ImageSharp, quantization matters both as an explicit processing step and as part of formats that write indexed or palette-constrained output.

## Where Quantization Shows Up

Quantization is relevant in a few common places:

- [`Quantize()`](xref:SixLabors.ImageSharp.Processing.QuantizeExtensions) when you want to reduce colors as part of a processing pipeline.
- [`GifEncoder`](xref:SixLabors.ImageSharp.Formats.Gif.GifEncoder), because GIF output is palette based.
- [`PngEncoder`](xref:SixLabors.ImageSharp.Formats.Png.PngEncoder) when you target [`PngColorType.Palette`](xref:SixLabors.ImageSharp.Formats.Png.PngColorType.Palette).
- [`IcoEncoder`](xref:SixLabors.ImageSharp.Formats.Ico.IcoEncoder) and [`CurEncoder`](xref:SixLabors.ImageSharp.Formats.Cur.CurEncoder) for icon and cursor workflows.

Use quantization when you want smaller palette-based outputs, fixed-color branding palettes, retro or posterized looks, or more control over indexed formats.

## Quantize as a Processing Step

The default [`Quantize()`](xref:SixLabors.ImageSharp.Processing.QuantizeExtensions.Quantize*) overload uses [`KnownQuantizers.Hexadecatree`](xref:SixLabors.ImageSharp.Processing.KnownQuantizers.Hexadecatree), which is a fast, good general-purpose adaptive quantizer.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;
using SixLabors.ImageSharp.Processing.Processors.Quantization;

using Image image = Image.Load("input.png");

image.Mutate(x => x.Quantize(new WuQuantizer(new QuantizerOptions
{
    MaxColors = 64
})));

image.Save("output.png");
```

This remaps the image content to a smaller palette before you save it. That can be useful when you want the palette reduction to be part of the visible processing result rather than only an encoder detail.

## Choose the Quantizer

[`KnownQuantizers`](xref:SixLabors.ImageSharp.Processing.KnownQuantizers) exposes reusable built-in choices:

- `KnownQuantizers.Hexadecatree` for a fast adaptive quantizer with solid general results.
- `KnownQuantizers.Wu` for high-quality adaptive palette generation.
- `KnownQuantizers.WebSafe` for the fixed web-safe palette.
- `KnownQuantizers.Werner` for the fixed Werner palette.

When you need more control, create a quantizer directly:

- [`WuQuantizer`](xref:SixLabors.ImageSharp.Processing.Processors.Quantization.WuQuantizer) for adaptive palette generation with configurable [`QuantizerOptions`](xref:SixLabors.ImageSharp.Processing.Processors.Quantization.QuantizerOptions).
- [`HexadecatreeQuantizer`](xref:SixLabors.ImageSharp.Processing.Processors.Quantization.HexadecatreeQuantizer) for fast adaptive quantization.
- [`PaletteQuantizer`](xref:SixLabors.ImageSharp.Processing.Processors.Quantization.PaletteQuantizer) when you want to force output to a known palette.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;
using SixLabors.ImageSharp.Processing.Processors.Quantization;

using Image image = Image.Load("input.png");

Color[] brandPalette =
{
    Color.Black,
    Color.White,
    Color.ParseHex("0057B8"),
    Color.ParseHex("FFD100")
};

image.Mutate(x => x.Quantize(new PaletteQuantizer(brandPalette)));
```

## Dithering Choices

[`QuantizerOptions`](xref:SixLabors.ImageSharp.Processing.Processors.Quantization.QuantizerOptions) controls the main quantization tradeoffs:

- `MaxColors` limits the palette size.
- `Dither` selects the dithering algorithm.
- `DitherScale` adjusts how strongly dithering is applied.
- `ColorMatchingMode` chooses how pixels are matched back to palette entries after the palette has been built.
- `TransparencyThreshold` and `TransparentColorMode` affect how transparent pixels are reduced into the palette.

[`ColorMatchingMode`](xref:SixLabors.ImageSharp.Processing.Processors.Quantization.ColorMatchingMode) has two built-in choices:

- `Coarse` is the default and favors speed.
- `Exact` uses more precise palette matching for cases where the extra accuracy matters more than throughput.

The API surface is intentionally small here: pick the quantizer that builds the palette you want, then choose either `Coarse` or `Exact` for the palette-matching pass.

[`KnownDitherings`](xref:SixLabors.ImageSharp.Processing.KnownDitherings) exposes the built-in dithering algorithms, including ordered Bayer variants and error-diffusion algorithms such as Floyd-Steinberg, Atkinson, Burks, Jarvis-Judice-Ninke, and Stucki.

Set `Dither = null` when you want flatter output with no dithering pattern. Keep dithering enabled when you want to hide banding in gradients or other smooth transitions.

ImageSharp also has a separate [`Dither()`](xref:SixLabors.ImageSharp.Processing.DitherExtensions) processing extension. Its default overload reduces the image to the web-safe palette using [`KnownDitherings.Bayer8x8`](xref:SixLabors.ImageSharp.Processing.KnownDitherings.Bayer8x8), and other overloads let you dither against a palette you provide.

## Encoder-Time Quantization

Many palette-sensitive exports are better controlled at save time by configuring the encoder directly:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;
using SixLabors.ImageSharp.Formats.Png;
using SixLabors.ImageSharp.Processing;
using SixLabors.ImageSharp.Processing.Processors.Quantization;

using Image image = Image.Load("input.png");

image.Save("output-indexed.png", new PngEncoder
{
    ColorType = PngColorType.Palette,
    Quantizer = new WuQuantizer(new QuantizerOptions
    {
        MaxColors = 128,
        ColorMatchingMode = ColorMatchingMode.Exact,
        Dither = KnownDitherings.FloydSteinberg,
        DitherScale = 0.75F,
        TransparentColorMode = TransparentColorMode.Preserve
    }),
    PixelSamplingStrategy = new ExtensivePixelSamplingStrategy()
});
```

This approach is usually the right choice when you want format-specific palette output without permanently changing the in-memory image first.

## Sampling and Transparency

Encoders that implement quantizing behavior also expose a pixel-sampling strategy. The default strategy samples a subset of pixels on large inputs to keep palette generation practical. [`ExtensivePixelSamplingStrategy`](xref:SixLabors.ImageSharp.Processing.Processors.Quantization.ExtensivePixelSamplingStrategy) scans all pixels instead, which can improve results when rare colors matter, at the cost of more work.

Transparency handling matters most for GIF, palette PNG, ICO, and CUR output. [`TransparentColorMode`](xref:SixLabors.ImageSharp.Formats.TransparentColorMode) controls how transparency is represented in the reduced palette, while `TransparencyThreshold` controls when partially transparent pixels are treated as transparent during quantization.

## Related Topics

- [GIF](gif.md)
- [PNG](png.md)
- [Convert Between Formats](formatconversion.md)
- [Read Image Info Without Decoding](identify.md)
