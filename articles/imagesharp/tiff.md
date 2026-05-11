# TIFF

TIFF is less about browser delivery and more about control. When a workflow cares about archival fidelity, scanning, publishing, print, or carrying richer metadata and pixel-layout choices forward, TIFF is often the format that gives you the room to do it.

ImageSharp exposes a range of TIFF-specific encoder and metadata options for those cases.

## Format Characteristics

TIFF is best thought of as a flexible imaging container with multiple possible encodings and metadata conventions rather than a single narrow web format.

TIFF can describe images using different photometric interpretations, bit depths, compression schemes, byte orders, and predictors. That flexibility is why it remains useful in scanning, print, archival, and professional imaging workflows, but it also means "TIFF support" varies between tools. A pipeline should choose the specific TIFF shape the downstream system expects.

Compression is not one-size-fits-all. LZW and deflate-style compression are common lossless choices, and predictors can improve compression by making neighboring sample values easier to encode. Those settings affect file size and compatibility rather than visual quality when the output is lossless.

TIFF metadata can be part of the workflow contract. Some files carry scanner, camera, print, publishing, or application-specific metadata. Before stripping or rewriting metadata, decide whether another system relies on it.

A few practical implications:

- TIFF is common in archival, print, scanning, publishing, and professional imaging workflows.
- TIFF can represent different compression schemes and pixel layouts.
- TIFF can carry rich format-specific metadata.
- TIFF is usually not the best choice for browser-facing delivery.

## Save as TIFF

Use [`TiffEncoder`](xref:SixLabors.ImageSharp.Formats.Tiff.TiffEncoder) when you want to control how TIFF data is written:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Tiff;
using SixLabors.ImageSharp.Formats.Tiff.Constants;

using Image image = Image.Load("input.png");

image.Save("output.tiff", new TiffEncoder
{
    Compression = TiffCompression.Lzw,
    HorizontalPredictor = TiffPredictor.Horizontal,
    BitsPerPixel = TiffBitsPerPixel.Bit24,
    PhotometricInterpretation = TiffPhotometricInterpretation.Rgb
});
```

## Key TIFF Encoder Options

The most commonly used `TiffEncoder` options are:

- `Compression` controls the TIFF compression algorithm.
- `CompressionLevel` controls deflate compression effort when deflate is used.
- `BitsPerPixel` controls the encoded pixel depth.
- `PhotometricInterpretation` controls how pixel data is interpreted.
- `HorizontalPredictor` can improve compression ratios for deflate or LZW output.

Some compression and photometric values are defined by the TIFF specification but are not currently supported by the encoder. In those cases, the encoder falls back rather than emitting unsupported output.

Because TIFF has many valid combinations, choose `BitsPerPixel`, `PhotometricInterpretation`, compression, and predictor settings together. For example, an RGB interchange file, a bilevel scanned document, and a higher-bit-depth imaging asset are all TIFF files, but they should not use the same encoder assumptions.

## Read TIFF Metadata

Use `GetTiffMetadata()` to inspect TIFF-specific metadata:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Tiff;

using Image image = Image.Load("input.tiff");

TiffMetadata tiffMetadata = image.Metadata.GetTiffMetadata();
```

`TiffMetadata` includes values such as:

- `ByteOrder`
- `FormatType`
- `Compression`
- `BitsPerPixel`
- `PhotometricInterpretation`
- `Predictor`

## When to Use TIFF

TIFF is usually worth considering when:

- You need TIFF-specific compression or pixel layout options.
- You care about byte order, predictor behavior, or TIFF format metadata.
- The workflow is archival, interchange, print, or imaging-pipeline oriented rather than browser-first.

TIFF is usually a poor fit when:

- The output is primarily intended for browser delivery.
- You just need a simple photo or web asset format.

For more typical application and web workloads, [PNG](png.md), [JPEG](jpeg.md), and [WebP](webp.md) are usually better starting points.

## Practical Guidance

Choose compression, predictor, and pixel layout explicitly when TIFF is part of an interchange contract. TIFF is a container family with many valid combinations, and downstream tools often support only the subset they care about. A file that is valid TIFF is not automatically compatible with every TIFF-consuming application.

Treat metadata as workflow data. TIFF files often carry scanner, archival, print, or pipeline-specific metadata, so decide whether that information should be preserved, transformed, or stripped. Test with the consuming application, because compatibility matters more than theoretical format support.

For browser delivery, ordinary thumbnails, and most application assets, PNG, JPEG, or WebP are usually easier to operate and validate.
