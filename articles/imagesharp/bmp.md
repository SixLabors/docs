# BMP

BMP is the classic Windows bitmap format. It is simple, broadly recognized, and sometimes useful when you need predictable bit-depth control or interoperability with older Windows-oriented tools.

ImageSharp exposes BMP-specific APIs through [`BmpEncoder`](xref:SixLabors.ImageSharp.Formats.Bmp.BmpEncoder), [`BmpDecoderOptions`](xref:SixLabors.ImageSharp.Formats.Bmp.BmpDecoderOptions), and [`BmpMetadata`](xref:SixLabors.ImageSharp.Formats.Bmp.BmpMetadata).

## Format Characteristics

BMP is best thought of as a straightforward bitmap container rather than a delivery format optimized for file size.

BMP files are useful when another system expects simple Windows bitmap data, but they are rarely the best choice for public delivery. Depending on bit depth, the file may store direct color values or palette indexes. Lower bit depths require palette generation and therefore can change colors in the same way other indexed formats do.

The format's simplicity is also its main tradeoff. BMP output can be easy for older tools to consume, but it usually produces much larger files than PNG, WebP, or QOI for ordinary application assets. Use it because the receiving workflow expects BMP, not because it is generally efficient.

Transparency support is limited and workflow-dependent. In ImageSharp, `SupportTransparency` applies to 32-bit BMP output. If alpha preservation is the main requirement, PNG or WebP is usually a better default.

A few practical implications:

- ImageSharp can write BMP output at 1, 2, 4, 8, 16, 24, or 32 bits per pixel.
- Lower bit-depth BMP output is palette based, so encoding can reduce colors rather than preserving full true-color data.
- `SupportTransparency` only applies when writing 32-bit BMP output.
- BMP is easy to exchange with older tooling, but it is usually much larger than PNG, WebP, or QOI for the same image.

## Save as BMP

Use [`BmpEncoder`](xref:SixLabors.ImageSharp.Formats.Bmp.BmpEncoder) when you want explicit control over BMP bit depth:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Bmp;

using Image image = Image.Load("input.png");

image.Save("output.bmp", new BmpEncoder
{
    BitsPerPixel = BmpBitsPerPixel.Bit32,
    SupportTransparency = true
});
```

## Key BMP Encoder Options

The most commonly used `BmpEncoder` options are:

- `BitsPerPixel` controls the encoded BMP bit depth.
- `SupportTransparency` enables BMP alpha support for 32-bit output.
- `Quantizer` and `PixelSamplingStrategy` matter when you target indexed BMP output such as 1, 4, or 8 bits per pixel.

When targeting 1, 2, 4, or 8 bits per pixel, the encoder must map source colors into a limited palette. That can be useful for compatibility with old systems, but it should be treated as a color-reduction step. For 24-bit or 32-bit BMP output, the file is larger but avoids indexed palette tradeoffs.

## Read BMP Metadata

Use `GetBmpMetadata()` to inspect BMP-specific metadata:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Bmp;

using Image image = Image.Load("input.bmp");

BmpMetadata bmpMetadata = image.Metadata.GetBmpMetadata();

Console.WriteLine(bmpMetadata.BitsPerPixel);
Console.WriteLine(bmpMetadata.InfoHeaderType);
```

`BmpMetadata` includes values such as:

- `BitsPerPixel`
- `InfoHeaderType`
- `ColorTable`

## BMP-Specific Decode Options

ImageSharp also exposes [`BmpDecoderOptions`](xref:SixLabors.ImageSharp.Formats.Bmp.BmpDecoderOptions) when you need to control how skipped pixels in RLE-compressed BMP data are interpreted:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Bmp;

BmpDecoderOptions options = new()
{
    RleSkippedPixelHandling = RleSkippedPixelHandling.Transparent
};

using Image image = Image.Load(options, "input.bmp");
```

## When to Use BMP

BMP is usually worth considering when:

- You need explicit low-level BMP bit-depth control.
- You are interoperating with Windows-oriented tools or older software that expects BMP input.
- File size is a secondary concern.

BMP is usually a poor fit when:

- You need compact files for storage or delivery.
- You want a modern web-oriented format.

For most application and web output, [PNG](png.md), [WebP](webp.md), or [QOI](qoi.md) are usually better starting points.

## Practical Guidance

- Use BMP mainly for compatibility with software that specifically expects it.
- Expect large files compared with modern compressed formats.
- Choose bit depth deliberately when interoperating with older Windows-oriented tooling.
- Prefer PNG or WebP when the same image is intended for storage, delivery, or web use.
