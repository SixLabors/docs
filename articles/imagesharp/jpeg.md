# JPEG

JPEG remains the workhorse format for photographs on the web and in many application pipelines. It is best when you care about keeping file sizes small and are willing to trade away some exact pixel fidelity to get there.

## Format Characteristics

JPEG uses lossy compression. That means it reduces file size by permanently discarding some image information, which is usually acceptable for photos but much more noticeable on sharp edges, text, UI assets, or repeated save cycles.

JPEG is built around the assumption that photographic images can lose some high-frequency detail without the loss being obvious. It divides image data into blocks, transforms those blocks into frequency information, and quantizes that information according to the requested quality. This is why artifacts often appear as blockiness, ringing around edges, or smearing in areas that were originally detailed.

Most JPEG workflows also use chroma subsampling: color detail is stored at lower resolution than brightness detail because human vision is usually more sensitive to luminance than chroma. That is very effective for photos, but it can make saturated text, icons, and UI edges look soft or discolored. If a file contains sharp colored edges, compare JPEG output carefully against PNG or WebP.

JPEG has no alpha channel and no animation model. If the input contains transparency, the transparent pixels must be flattened onto a background before encoding. If the input is animated, save to a format that supports animation or choose a single frame deliberately.

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

`Quality` is not a percentage of original image quality. It controls quantization strength, and the visual difference between values is not linear. A move from 95 to 85 may save a lot of bytes with little visual change on many photos, while a move from 45 to 35 can be much more obvious. Pick values by testing representative images at the sizes you actually serve.

Progressive JPEG stores the image in multiple refinement passes. Browsers can show a rough version before the full file has arrived, which can improve perceived loading behavior for large images. Baseline JPEG is simpler and still broadly supported. Choose progressive output when public image delivery benefits from progressive rendering; choose baseline if a downstream system has strict compatibility requirements.

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

Decoder-specific resizing can be useful when you only need a smaller representation of a large JPEG. It can reduce work before a full ImageSharp resize pipeline runs, but it should be treated as a decode optimization rather than a replacement for layout-aware resizing with `ResizeOptions`.

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

## Practical Guidance

Set `Quality` explicitly for public output. JPEG quality is a product decision that balances file size and visible artifacts, so it should be visible in code rather than inherited from whatever default is active. Test the value against representative photos, not only one sample image.

Flatten transparent sources before saving as JPEG because the format has no alpha channel. Choose the background color deliberately; white is common, but product photos, logos, and UI previews often need a different page or brand background.

Keep ICC metadata or convert to a known output profile when color consistency matters. Avoid repeated JPEG-to-JPEG saves in editing workflows because each lossy encode can discard additional detail. If users edit repeatedly, keep a higher-fidelity working source and encode JPEG only at the export boundary.
