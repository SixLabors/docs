# Convert Between Formats

Format conversion is one of the most common reasons people adopt ImageSharp in the first place. The nice part is that you usually do not have to think in terms of format-to-format adapters; you load into ImageSharp's common image model, make any changes you need, and then save to the destination path, stream, or encoder.

That decode-and-re-encode flow is not a blind one. Once an image is loaded, the processing pipeline works with format-agnostic pixel data, while the metadata layer still carries enough information for the destination format to choose the best representation it supports.

For common conversions, saving to a destination path or format is intentionally useful. ImageSharp combines the decoded image, bridged metadata, pixel information, and registered encoder defaults to produce strong automated output. Use explicit encoders when your application has a specific output policy to express, not because the default conversion path is something to avoid.

## How ImageSharp Bridges Formats

ImageSharp's built-in codec metadata translates through [`FormatConnectingMetadata`](xref:SixLabors.ImageSharp.Formats.FormatConnectingMetadata) and [`FormatConnectingFrameMetadata`](xref:SixLabors.ImageSharp.Formats.FormatConnectingFrameMetadata). Those bridge types carry the common image and frame semantics that can be shared across formats, including:

- Encoded pixel information through [`PixelTypeInfo`](xref:SixLabors.ImageSharp.PixelFormats.PixelTypeInfo), such as color model, alpha behavior, bit depth, and component precision.
- Encoding intent such as lossy versus lossless output and quality.
- Indexed-color settings such as shared color table mode.
- Animation settings such as background color, repeat count, frame duration, blend mode, and disposal mode.

That is why ImageSharp's conversion story is more comprehensive than simply decoding everything to one in-memory layout and forgetting how the source was encoded. For example, PNG metadata can derive palette, grayscale, RGB, or RGBA output and choose 1, 2, 4, 8, or 16-bit encoding from bridged pixel information, while GIF metadata can carry indexed color-table mode and repeat-count behavior forward when the target format supports them. These bridges are what make the automatic conversion APIs useful for real application workflows rather than only toy examples.

## Use Identify to Plan the Conversion

You do not need to preflight every conversion. Use [`Image.Identify()`](xref:SixLabors.ImageSharp.Image.Identify*) when routing depends on how the source is encoded, or when you want to choose a different destination format before paying the cost of a full decode. [`ImageInfo.PixelType`](xref:SixLabors.ImageSharp.ImageInfo.PixelType) exposes [`PixelTypeInfo`](xref:SixLabors.ImageSharp.PixelFormats.PixelTypeInfo), including:

- [`BitsPerPixel`](xref:SixLabors.ImageSharp.PixelFormats.PixelTypeInfo.BitsPerPixel)
- [`ColorType`](xref:SixLabors.ImageSharp.PixelFormats.PixelTypeInfo.ColorType)
- [`AlphaRepresentation`](xref:SixLabors.ImageSharp.PixelFormats.PixelTypeInfo.AlphaRepresentation)
- [`ComponentInfo`](xref:SixLabors.ImageSharp.PixelFormats.PixelTypeInfo.ComponentInfo) for component count and precision

This is useful when you need to decide whether to flatten transparency for JPEG, keep higher-precision data in PNG, TIFF, or OpenEXR, preserve indexed workflows where the target format supports them, or select between several acceptable delivery formats.

## Convert PNG to JPEG

JPEG does not support alpha transparency, so transparent sources usually need to be flattened onto a background color first:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Jpeg;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.png");

image.Mutate(x => x.BackgroundColor(Color.White));

image.Save("output.jpg", new JpegEncoder
{
    Quality = 85
});
```

Choose the flattening color deliberately. White is common for documents and many web layouts, but logos, UI assets, and product imagery may need a brand color, a page background color, or a checkerboard-style review workflow before final export.

## Convert JPEG to WebP

Save with a WebP extension for the default WebP output, or pass a WebP encoder when you want to set a delivery policy such as lossy output and a specific quality value:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Webp;

using Image image = Image.Load("input.jpg");

image.Save("output.webp", new WebpEncoder
{
    FileFormat = WebpFileFormatType.Lossy,
    Quality = 80
});
```

For web delivery, compare both file size and visual quality against your JPEG baseline. WebP often wins for photographic content, but the right quality value is product-specific and should be chosen against representative images rather than one sample.

## Convert Any Input to PNG

PNG is a good target when you want lossless output or transparency support:

```csharp
using SixLabors.ImageSharp;

using Image image = Image.Load("input.bin");

image.Save("output.png");
```

PNG is not automatically the best "safe" target for every input. It preserves sharp graphics and transparency well, but photographic sources can become much larger than JPEG or WebP. Use PNG when lossless output, alpha, indexed color, or broad compatibility matter more than smallest file size.

## Choose the Output Based on Pixel Info

When you need to implement a routing policy, inspect the encoded pixel type first and then choose the destination accordingly:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Jpeg;
using SixLabors.ImageSharp.Formats.Png;
using SixLabors.ImageSharp.PixelFormats;

ImageInfo info = Image.Identify("input.tiff");

bool hasAlpha = info.PixelType.ColorType.HasFlag(PixelColorType.Alpha);
int precision = info.PixelType.ComponentInfo?.GetMaximumComponentPrecision() ?? 8;

using Image image = Image.Load("input.tiff");

if (hasAlpha)
{
    image.Save("output.png", new PngEncoder
    {
        BitDepth = precision > 8 ? PngBitDepth.Bit16 : PngBitDepth.Bit8
    });
}
else
{
    image.Save("output.jpg", new JpegEncoder
    {
        Quality = 85
    });
}
```

## Notes

- Converting from a lossy format to a lossless format does not restore discarded detail.
- Converting a transparent image to JPEG requires flattening or compositing first.
- ImageSharp uses bridged metadata, pixel-type information, and encoder defaults to pick good destination settings when the target format can represent them.
- Save-by-extension is the simplest and recommended path for ordinary conversions. Pass an explicit encoder when you want to override defaults for quality, compression, bit depth, palette behavior, metadata handling, or another application policy.
- Format conversion is also a metadata decision. Decide whether orientation, color profiles, animation timing, and authoring metadata should be preserved, transformed, or stripped.

For more on format behavior and encoder options, see [Image Formats](imageformats.md). For more on inspecting pixel types before a conversion, see [Read Image Info Without Decoding](identify.md) and [Pixel Formats](pixelformats.md).

## Practical Guidance

For everyday conversion, let ImageSharp do the normal thing: load the source, apply any processing you need, and save to the destination path or format. The conversion layer carries format-agnostic metadata and pixel information forward so encoders can choose strong defaults. This is a real feature of the library, especially for automated services that accept multiple input formats and produce a consistent output type.

Add policy only where policy is genuinely needed. A transparent PNG converted to JPEG still needs an explicit background color because JPEG cannot represent alpha. An animated input needs a target format that can represent frame timing and disposal behavior if animation must survive. A public API, cache, or asset pipeline may want fixed quality, compression, bit depth, palette behavior, or metadata handling. Those are reasons to pass an explicit encoder, but they are refinements on top of a capable automated conversion model rather than a workaround for it.
