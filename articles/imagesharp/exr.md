# OpenEXR

OpenEXR is the format to reach for when dynamic range and channel precision matter more than browser compatibility. It is most at home in rendering, compositing, HDR capture, and other imaging pipelines where half-float or float data is part of the workflow.

ImageSharp supports OpenEXR read and write workflows and exposes EXR-specific metadata through [`ExrMetadata`](xref:SixLabors.ImageSharp.Formats.Exr.ExrMetadata).

## Format Characteristics

OpenEXR is best thought of as a high-precision interchange format rather than a delivery format.

OpenEXR is designed for scene-referred and high-dynamic-range image data. Values are often intended to survive rendering, compositing, lighting, or color-grading steps before they are tone mapped for display. That makes EXR very different from web formats, where pixels are usually already display-referred.

The pixel type matters. Half-float storage is common because it gives much more range than 8-bit formats while keeping file size lower than full 32-bit float data. Full float output is useful when the pipeline needs the extra precision. Unsigned integer storage exists for workflows that require it, but it is not the common "HDR image" choice.

Compression should be chosen with the consuming pipeline in mind. ZIP and ZIPS are both lossless options, but they organize compression differently. Renderer, compositor, and asset-pipeline expectations are often more important than theoretical compression ratios.

A few practical implications:

- OpenEXR is common in VFX, rendering, compositing, and HDR-oriented workflows.
- ImageSharp tracks EXR pixel storage through [`ExrPixelType`](xref:SixLabors.ImageSharp.Formats.Exr.Constants.ExrPixelType) and image layout through [`ExrImageDataType`](xref:SixLabors.ImageSharp.Formats.Exr.Constants.ExrImageDataType).
- The current decoder supports uncompressed, ZIP, ZIPS, RLE, and B44-compressed EXR files.
- The current encoder supports uncompressed, ZIP, and ZIPS output.
- OpenEXR is usually not the best choice for browser-facing assets.

## Save as OpenEXR

Use [`ExrEncoder`](xref:SixLabors.ImageSharp.Formats.Exr.ExrEncoder) when you want to control how EXR data is written:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Exr;
using SixLabors.ImageSharp.Formats.Exr.Constants;

using Image image = Image.Load("input.png");

image.Save("output.exr", new ExrEncoder
{
    PixelType = ExrPixelType.Half,
    Compression = ExrCompression.Zip
});
```

## Key OpenEXR Encoder Options

The most commonly used `ExrEncoder` options are:

- `PixelType` controls whether channels are written as `Half`, `Float`, or `UnsignedInt`.
- `Compression` controls the current EXR encoder compression mode. Use `None`, `Zip`, or `Zips`.

Do not use OpenEXR only because an image is "high quality." Use it when the numeric range and precision are needed by the pipeline. If the next step is ordinary display, web delivery, or a thumbnail, tone mapping or conversion to a delivery format is usually the next deliberate step.

## Read OpenEXR Metadata

Use `GetExrMetadata()` to inspect EXR-specific metadata:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Exr;

using Image image = Image.Load("input.exr");

ExrMetadata exrMetadata = image.Metadata.GetExrMetadata();

Console.WriteLine(exrMetadata.PixelType);
Console.WriteLine(exrMetadata.ImageDataType);
Console.WriteLine(exrMetadata.Compression);
```

`ExrMetadata` includes values such as:

- `PixelType`
- `ImageDataType`
- `Compression`

## When to Use OpenEXR

OpenEXR is usually worth considering when:

- You need HDR or higher-precision image data in a rendering or imaging pipeline.
- You want floating-point or half-float channel storage.
- You care about EXR-specific compression and channel-layout metadata.

OpenEXR is usually a poor fit when:

- The output is primarily for browsers or ordinary app delivery.
- You want the broadest ecosystem compatibility for day-to-day assets.

For everyday application and web output, [PNG](png.md), [JPEG](jpeg.md), [WebP](webp.md), and [TIFF](tiff.md) are usually easier starting points.

## Practical Guidance

- Use OpenEXR when high dynamic range, floating-point data, or rendering-pipeline interchange is the real requirement.
- Keep tone mapping and display conversion separate from storing scene-referred data.
- Test compression and channel layout with the downstream renderer or compositing tool.
- Prefer TIFF, PNG, or WebP when the workflow does not need EXR-specific precision or metadata.
