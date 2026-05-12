# PBM / PGM / PPM

In ImageSharp, [`PbmFormat`](xref:SixLabors.ImageSharp.Formats.Pbm.PbmFormat) covers the Netpbm PNM family: PBM for black-and-white images, PGM for grayscale images, and PPM for RGB images. These formats are intentionally simple and are often used for straightforward interchange or tooling pipelines.

ImageSharp exposes PNM-specific APIs through [`PbmEncoder`](xref:SixLabors.ImageSharp.Formats.Pbm.PbmEncoder) and [`PbmMetadata`](xref:SixLabors.ImageSharp.Formats.Pbm.PbmMetadata).

## Format Characteristics

The PNM family is best thought of as a simple interchange family rather than a compact delivery format.

The family covers three related subformats. PBM stores black-and-white images. PGM stores grayscale images. PPM stores RGB images. Each can be useful for tests, examples, and simple tooling because the structure is easy to generate and inspect.

Plain-text encoding is human-readable, which can be valuable for debugging small fixtures. Binary encoding is more compact and more appropriate for larger files, but it is still not a modern compressed delivery format. The formats do not carry alpha transparency or rich metadata.

A few practical implications:

- `PbmColorType.BlackAndWhite` maps to PBM output.
- `PbmColorType.Grayscale` maps to PGM output.
- `PbmColorType.Rgb` maps to PPM output.
- `PbmEncoding` lets you choose plain-text or binary pixel encoding.
- `PbmComponentType` lets you choose 1-bit black-and-white, 8-bit components, or 16-bit components depending on the target subformat.

## Save as PBM / PGM / PPM

Use [`PbmEncoder`](xref:SixLabors.ImageSharp.Formats.Pbm.PbmEncoder) when you want to choose the exact PNM subformat and encoding style:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Pbm;

using Image image = Image.Load("input.png");

image.Save("output.ppm", new PbmEncoder
{
    ColorType = PbmColorType.Rgb,
    ComponentType = PbmComponentType.Byte,
    Encoding = PbmEncoding.Binary
});
```

## Key PNM Encoder Options

The most commonly used `PbmEncoder` options are:

- `ColorType` selects PBM, PGM, or PPM style output.
- `ComponentType` selects 1-bit, 8-bit, or 16-bit component storage where that subformat allows it.
- `Encoding` selects plain-text or binary pixel encoding.

Choose the subformat from the data model. A mask or thresholded image belongs in PBM, grayscale analysis output belongs in PGM, and ordinary RGB test data belongs in PPM. Choose plain text when inspection matters more than size.

## Read PNM Metadata

Use `GetPbmMetadata()` to inspect PNM-specific metadata:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Pbm;

using Image image = Image.Load("input.ppm");

PbmMetadata pbmMetadata = image.Metadata.GetPbmMetadata();

Console.WriteLine(pbmMetadata.ColorType);
Console.WriteLine(pbmMetadata.ComponentType);
Console.WriteLine(pbmMetadata.Encoding);
```

`PbmMetadata` includes values such as:

- `ColorType`
- `ComponentType`
- `Encoding`

## When to Use PBM / PGM / PPM

The Netpbm family is usually worth considering when:

- You need a very simple interchange format.
- Human-readable plain-text image data is useful for debugging or tooling.
- You are working with existing Netpbm-style workflows.

It is usually a poor fit when:

- File size matters.
- You need richer metadata, transparency, or modern delivery characteristics.

For more compact or full-featured output, start with [PNG](png.md), [WebP](webp.md), or [QOI](qoi.md).

## Practical Guidance

- Use Netpbm formats for simple tooling, tests, and interchange workflows where readability matters.
- Avoid them for public delivery or storage where compression, metadata, or alpha support matters.
- Be explicit about plain versus binary encoding when files are consumed by external tools.
- Prefer PNG when you need a simple lossless format with a much broader ecosystem.
