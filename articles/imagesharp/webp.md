# WebP

WebP is often the first format to consider when you want one codec that can cover several common web scenarios. It can handle photographs, transparency, and animation, which makes it a flexible alternative to juggling separate JPEG, PNG, and GIF outputs.

In ImageSharp, it is one of the most flexible general-purpose web output formats.

## Format Characteristics

WebP is a modern format family rather than a single narrow use case. It can be used as:

- a lossy alternative to JPEG,
- a lossless alternative to PNG in many workflows,
- a transparency-capable web format,
- and an animation format.

A few practical implications:

- WebP is often the most flexible web-oriented output option.
- WebP supports both alpha transparency and animation.
- Lossy and lossless modes have different tuning behavior.
- Compatibility is generally strong in modern environments, but not identical to long-established formats like JPEG or PNG everywhere.

## Save as WebP

Use [`WebpEncoder`](xref:SixLabors.ImageSharp.Formats.Webp.WebpEncoder) when you want to tune WebP output:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Webp;

using Image image = Image.Load("input.png");

image.Save("output.webp", new WebpEncoder
{
    FileFormat = WebpFileFormatType.Lossless,
    Quality = 75,
    Method = WebpEncodingMethod.BestQuality,
    UseAlphaCompression = true
});
```

Set `FileFormat` to choose between lossy and lossless output.

## Key WebP Encoder Options

The most commonly used `WebpEncoder` options are:

- `FileFormat` chooses lossy or lossless encoding.
- `Quality` controls quality or compression effort, depending on the mode.
- `Method` controls the speed/quality tradeoff.
- `UseAlphaCompression` controls how the alpha plane is compressed.
- `NearLossless` and `NearLosslessQuality` tune near-lossless workflows.
- `EntropyPasses`, `SpatialNoiseShaping`, and `FilterStrength` expose more advanced tuning.

Because `WebpEncoder` inherits from [`AnimatedImageEncoder`](xref:SixLabors.ImageSharp.Formats.AnimatedImageEncoder), it also supports `RepeatCount`, `BackgroundColor`, and `AnimateRootFrame`.

## Read WebP Metadata

Use `GetWebpMetadata()` to inspect WebP-specific metadata:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Webp;

using Image image = Image.Load("input.webp");

WebpMetadata webpMetadata = image.Metadata.GetWebpMetadata();
```

`WebpMetadata` includes values such as:

- `FileFormat`
- `ColorType`
- `BitsPerPixel`
- `RepeatCount`
- `BackgroundColor`

For animated WebP, frame-level metadata is available through [`WebpFrameMetadata`](xref:SixLabors.ImageSharp.Formats.Webp.WebpFrameMetadata), including `FrameDelay`, `BlendMode`, and `DisposalMode`.

## When to Use WebP

WebP is a strong choice when you want:

- Lossy or lossless output from the same family of encoders.
- Transparency support.
- Animation support.
- More control over size/quality tradeoffs than a simple save-by-extension workflow provides.

WebP is often the best first alternative to compare against both JPEG and PNG when optimizing for delivery size.

If you need strict lossless preservation with a more traditional workflow, see [PNG](png.md). If you specifically need TIFF-style metadata and pixel layout control, see [TIFF](tiff.md).
