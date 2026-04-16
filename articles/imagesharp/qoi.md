# QOI

QOI, the Quite OK Image Format, is a simple lossless image format designed around easy implementation and fast encode/decode loops. In ImageSharp, it is a compact option when you want lossless RGB or RGBA output without the broader feature surface of PNG.

ImageSharp exposes QOI-specific APIs through [`QoiEncoder`](xref:SixLabors.ImageSharp.Formats.Qoi.QoiEncoder) and [`QoiMetadata`](xref:SixLabors.ImageSharp.Formats.Qoi.QoiMetadata).

## Format Characteristics

QOI is best thought of as a small, focused lossless format.

A few practical implications:

- QOI is lossless.
- The format stores image channel count as RGB or RGBA.
- The format stores a simple color-space flag.
- In ImageSharp, `Channels` and `ColorSpace` are informative metadata. They do not change how the pixel chunks themselves are encoded.
- QOI has a much smaller ecosystem than PNG or WebP.

## Save as QOI

Use [`QoiEncoder`](xref:SixLabors.ImageSharp.Formats.Qoi.QoiEncoder) when you want QOI output:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Qoi;

using Image image = Image.Load("input.png");

image.Save("output.qoi", new QoiEncoder
{
    Channels = QoiChannels.Rgba,
    ColorSpace = QoiColorSpace.SrgbWithLinearAlpha
});
```

## Key QOI Metadata

The most useful QOI-specific values are:

- `Channels`, which records whether the image is RGB or RGBA.
- `ColorSpace`, which records whether the image is tagged as sRGB with linear alpha or all-channels-linear.

## Read QOI Metadata

Use `GetQoiMetadata()` to inspect QOI-specific metadata:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Qoi;

using Image image = Image.Load("input.qoi");

QoiMetadata qoiMetadata = image.Metadata.GetQoiMetadata();

Console.WriteLine(qoiMetadata.Channels);
Console.WriteLine(qoiMetadata.ColorSpace);
```

## When to Use QOI

QOI is usually worth considering when:

- You want a simple lossless format in a controlled pipeline.
- Fast, straightforward encoding and decoding matters more than ecosystem breadth.

QOI is usually a poor fit when:

- You need broad browser or tool compatibility.
- You need richer metadata or more mature ecosystem support.

For wider compatibility, [PNG](png.md) and [WebP](webp.md) are usually better starting points.
