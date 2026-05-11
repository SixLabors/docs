# PNG

PNG is the format people usually reach for when they want the saved pixels to stay exactly as they were processed in memory. That makes it a natural fit for UI assets, screenshots, diagrams, icons, and any workflow where transparency and crisp edges matter more than aggressive compression.

ImageSharp also supports animated PNG metadata and encoding scenarios.

## Format Characteristics

PNG is a lossless format. It preserves pixel data exactly, which makes it a strong fit for graphics where edges, text, and flat-color regions need to stay crisp.

PNG compresses image data without discarding pixel information. Before compression, scanline filters can transform rows into forms that compress better. The chosen filter does not change the decoded pixels, but it can change encoding speed and file size. Adaptive filtering lets the encoder choose filters per row and is usually a good default for mixed content.

PNG supports several pixel representations, including grayscale, grayscale with alpha, RGB, RGB with alpha, and palette-indexed color. That is why `ColorType` and `BitDepth` matter: they decide how pixels are represented in the file, not just how strongly the file is compressed. A screenshot with a small number of colors may be much smaller as a palette PNG, while a translucent UI asset usually needs RGBA-style output.

PNG can store ancillary information such as gamma, text chunks, and color-management data. Those chunks can be important for appearance or workflow, but they can also increase file size or carry information you do not want to publish. Treat metadata as part of the output decision.

A few practical implications:

- PNG is excellent for screenshots, icons, logos, diagrams, and UI assets.
- PNG supports alpha transparency.
- PNG is often much larger than JPEG for photographic content.
- PNG can also carry animated PNG data, though ecosystem support is not as universal as static PNG support.

## Save as PNG

Use [`PngEncoder`](xref:SixLabors.ImageSharp.Formats.Png.PngEncoder) when you want to tune PNG output:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Png;

using Image image = Image.Load("input.png");

image.Save("output.png", new PngEncoder
{
    CompressionLevel = PngCompressionLevel.BestCompression,
    FilterMethod = PngFilterMethod.Adaptive,
    ColorType = PngColorType.RgbWithAlpha
});
```

PNG encoding is lossless. The main tradeoffs are encoder speed, file size, and how the pixel data is represented.

## Key PNG Encoder Options

The most commonly used `PngEncoder` options are:

- `CompressionLevel` controls deflate compression effort.
- `FilterMethod` controls how scanlines are filtered before compression.
- `ColorType` and `BitDepth` control how pixel data is represented.
- `InterlaceMethod` lets you write an Adam7 interlaced image.
- `ChunkFilter` and `TextCompressionThreshold` control which ancillary data is written and how text chunks are compressed.
- `Gamma` lets you write a gamma value into the output metadata.

Because `PngEncoder` inherits from [`QuantizingAnimatedImageEncoder`](xref:SixLabors.ImageSharp.Formats.QuantizingAnimatedImageEncoder), it also supports `Quantizer`, `PixelSamplingStrategy`, and `TransparentColorMode` when you are writing palette-based PNG data.

Compression level is a speed-versus-size choice. Higher compression can reduce output size, but it costs more CPU and does not improve image quality because PNG is already lossless. For high-volume services, benchmark realistic images before choosing the slowest compression level globally.

Adam7 interlacing allows a progressively refined display as bytes arrive. That can help in some delivery scenarios, but it can also increase file size. For small UI assets and cached application images, non-interlaced PNG is often simpler.

## Quantization and Palette PNGs

PNG does not always quantize. Quantization is only part of the encode path when you target a palette PNG by setting [`PngColorType.Palette`](xref:SixLabors.ImageSharp.Formats.Png.PngColorType.Palette). For RGB, RGBA, grayscale, or grayscale-with-alpha PNG output, ImageSharp writes the image in those representations without first reducing it to a palette.

Palette PNGs can be a very good fit for icons, diagrams, pixel art, and other flat-color assets where a smaller indexed palette is acceptable. They are usually a poor fit for photos, gradients, and other images with subtle transitions.

When you choose palette PNG output, ImageSharp uses the same quantization building blocks as the GIF encoder:

- [`Quantizer`](xref:SixLabors.ImageSharp.Formats.QuantizingImageEncoder.Quantizer) selects the palette-generation algorithm.
- [`PixelSamplingStrategy`](xref:SixLabors.ImageSharp.Formats.QuantizingImageEncoder.PixelSamplingStrategy) controls how pixels are sampled when building the palette.
- [`TransparentColorMode`](xref:SixLabors.ImageSharp.Formats.AlphaAwareImageEncoder.TransparentColorMode) controls how fully transparent pixels are normalized during encoding.

If you pass a quantizer with custom [`QuantizerOptions`](xref:SixLabors.ImageSharp.Processing.Processors.Quantization.QuantizerOptions), palette matching is configured through [`ColorMatchingMode`](xref:SixLabors.ImageSharp.Processing.Processors.Quantization.ColorMatchingMode), which offers the `Coarse` and `Exact` choices.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;
using SixLabors.ImageSharp.Formats.Png;
using SixLabors.ImageSharp.Processing.Processors.Quantization;

using Image image = Image.Load("input.png");

image.Save("output-indexed.png", new PngEncoder
{
    ColorType = PngColorType.Palette,
    Quantizer = new WuQuantizer(new QuantizerOptions
    {
        MaxColors = 64,
        Dither = null,
        TransparentColorMode = TransparentColorMode.Preserve
    })
});
```

If you need a fixed output palette instead of an adaptive one, use [`PaletteQuantizer`](xref:SixLabors.ImageSharp.Processing.Processors.Quantization.PaletteQuantizer). If you keep `ColorType` as `Rgb`, `RgbWithAlpha`, `Grayscale`, or `GrayscaleWithAlpha`, the quantizer settings are not the main control surface because the encoder is not writing palette-indexed PNG data.

## Read PNG and APNG Metadata

Use `GetPngMetadata()` to inspect PNG-specific metadata:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Png;

using Image image = Image.Load("input.png");

PngMetadata pngMetadata = image.Metadata.GetPngMetadata();
```

`PngMetadata` includes values such as:

- `ColorType`
- `BitDepth`
- `InterlaceMethod`
- `Gamma`
- `RepeatCount`
- `AnimateRootFrame`

For animated PNGs, frame-level metadata is available through [`PngFrameMetadata`](xref:SixLabors.ImageSharp.Formats.Png.PngFrameMetadata), including `FrameDelay`, `DisposalMode`, and `BlendMode`.

## PNG-Specific Decode Options

[`PngDecoderOptions`](xref:SixLabors.ImageSharp.Formats.Png.PngDecoderOptions) exposes `MaxUncompressedAncillaryChunkSizeBytes`, which can be useful when controlling how much memory decompressed ancillary chunks are allowed to occupy.

## When to Use PNG

PNG is usually a good fit when:

- You need lossless output.
- The image uses transparency.
- You are working with screenshots, logos, diagrams, or UI assets.
- You need APNG-style animation metadata and frame control.

PNG is usually a poor fit when:

- The content is photographic and file size is a major concern.
- You only need a web-first animated format and modern browser-oriented compression matters more than static PNG compatibility.

If you want a lossy photographic format, start with [JPEG](jpeg.md). If you want a modern alternative that supports both lossy and lossless output, see [WebP](webp.md).

## Practical Guidance

Use PNG when lossless pixels, transparency, screenshots, diagrams, or UI assets matter more than the smallest possible file. It is a strong default for sharp graphics because it avoids lossy artifacts around text, icons, and hard edges.

When PNG size matters, consider palette output and quantization rather than switching formats immediately. A palette PNG can be much smaller for limited-color graphics, but that choice should be tested against gradients, shadows, and transparency because quantization can introduce visible banding or dithering texture.

Preserve or convert color profiles intentionally. PNG is often used in workflows where exact appearance matters, so silently dropping profile information can be a real output bug. For photographic delivery where smaller files matter more than lossless pixels, compare JPEG and WebP instead.
