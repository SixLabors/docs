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

Lossy WebP is aimed at photographic and mixed web content, similar to JPEG, but with a different compression model and more tuning controls. It is often competitive for public delivery where byte size matters, especially after comparing quality settings against the JPEG baseline you would otherwise use.

Lossless WebP is closer to PNG in intent: preserve exact pixels while reducing file size. It can be attractive for transparent graphics and UI assets when client support is known. It should still be tested against PNG because the smaller file is not guaranteed for every image.

Animated WebP can replace GIF in modern delivery pipelines, but the animation behavior is more than the encoded frames. Frame delay, blend mode, disposal mode, repeat count, and background color all affect the final result. When converting an existing animation, inspect and set those values deliberately.

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

In lossy mode, `Quality` controls the visual quality and compression tradeoff. In lossless mode, quality-style settings are better understood as compression-effort controls. `Method` also changes encoding effort: higher-quality methods can produce smaller or better-looking output but cost more CPU. That distinction matters on web servers where many variants may be generated on demand.

Alpha compression is a separate concern from RGB compression. If transparent edges are important, test images with soft shadows, icons, and antialiased cutouts; those are the places where alpha handling becomes visible.

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

## Practical Guidance

Compare lossy WebP against the JPEG settings you would otherwise ship. WebP often produces smaller files at similar visual quality, but the right quality value depends on content and delivery expectations. Test photos, screenshots, graphics, and mixed-content images separately.

Use lossless WebP when transparency and smaller files matter but PNG compatibility is not required. That can be a good fit for controlled clients and modern web delivery, but it should not be the only public format unless your client and CDN support story is clear.

Animated WebP carries timing, blending, disposal, repeat count, and background behavior. When converting from GIF or APNG, inspect that metadata instead of assuming the animation will behave identically after re-encoding.
