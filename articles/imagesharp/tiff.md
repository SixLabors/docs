# TIFF

TIFF is useful in workflows where compression mode, pixel layout, and metadata fidelity matter more than broad browser support. ImageSharp exposes a range of TIFF-specific encoder and metadata options for those cases.

## Format Characteristics

TIFF is best thought of as a flexible imaging container with multiple possible encodings and metadata conventions rather than a single narrow web format.

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
