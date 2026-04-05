# JPEG

JPEG remains the workhorse format for photographs on the web and in many application pipelines. It is best when you care about keeping file sizes small and are willing to trade away some exact pixel fidelity to get there.

## Format Characteristics

JPEG uses lossy compression. That means it reduces file size by permanently discarding some image information, which is usually acceptable for photos but much more noticeable on sharp edges, text, UI assets, or repeated save cycles.

A few practical implications:

- JPEG is usually excellent for photos and gradients.
- JPEG is usually poor for logos, diagrams, screenshots, and pixel-precise artwork.
- JPEG does not support alpha transparency.
- Re-encoding a JPEG repeatedly can compound visible artifacts over time.

## Save as JPEG

Use [`JpegEncoder`](xref:SixLabors.ImageSharp.Formats.Jpeg.JpegEncoder) when you want to tune JPEG output:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Jpeg;

using Image image = Image.Load("input.png");

image.Save("output.jpg", new JpegEncoder
{
    Quality = 85,
    Progressive = true
});
```

## Key JPEG Encoder Options

The most commonly used `JpegEncoder` options are:

- `Quality` controls the quality/compression tradeoff on a 1-100 scale.
- `Progressive` enables progressive JPEG output.
- `ProgressiveScans` controls how progressive data is split into scans.
- `Interleaved` controls interleaved versus non-interleaved output.
- `ColorType` lets you influence the encoded JPEG color model.

JPEG is a lossy format and does not preserve alpha transparency. If the source image includes transparency, composite it onto a background first.

## Read JPEG Metadata

You can inspect format-specific metadata through `GetJpegMetadata()`:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Jpeg;

using Image image = Image.Load("input.jpg");

JpegMetadata jpegMetadata = image.Metadata.GetJpegMetadata();
```

General image metadata such as EXIF and ICC profiles remains available through [Working with Metadata](metadata.md).

## JPEG-Specific Decode Options

ImageSharp also exposes [`JpegDecoderOptions`](xref:SixLabors.ImageSharp.Formats.Jpeg.JpegDecoderOptions) for specialized JPEG decoding scenarios, including decoder-specific resize behavior.

## When to Use JPEG

JPEG is usually a good fit when:

- The source is photographic rather than flat-color artwork.
- You do not need transparency.
- A smaller file size is more important than exact pixel preservation.

JPEG is usually a poor fit when:

- The image contains text, hard UI edges, or line art.
- You need pixel-perfect reproduction.
- You need an alpha channel.

If you need lossless output or alpha transparency, start with [PNG](png.md) or [WebP](webp.md) instead.
