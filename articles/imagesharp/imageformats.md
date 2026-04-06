# Image Formats

ImageSharp keeps the in-memory image model separate from the file format on disk. That means the same processing code can work across JPEG, PNG, WebP, TIFF, GIF, and the other built-in codecs, while the encoder and metadata layers handle the format-specific details at the edges.

This page is the format map for the library: which built-in formats ship by default, what each one is good at, and where to go next for format-specific guidance.

## Built-In Formats

The source of truth for the built-in format list is [`Configuration`](xref:SixLabors.ImageSharp.Configuration): the default ImageSharp configuration preregisters encoder, decoder, and detector modules for the following public [`IImageFormat`](xref:SixLabors.ImageSharp.Formats.IImageFormat) types:

| Format | Public API type | Built in by default |
| --- | --- | --- |
| BMP | [`BmpFormat`](xref:SixLabors.ImageSharp.Formats.Bmp.BmpFormat) | Read and write |
| CUR | [`CurFormat`](xref:SixLabors.ImageSharp.Formats.Cur.CurFormat) | Read and write |
| GIF | [`GifFormat`](xref:SixLabors.ImageSharp.Formats.Gif.GifFormat) | Read and write |
| ICO | [`IcoFormat`](xref:SixLabors.ImageSharp.Formats.Ico.IcoFormat) | Read and write |
| JPEG | [`JpegFormat`](xref:SixLabors.ImageSharp.Formats.Jpeg.JpegFormat) | Read and write |
| PBM | [`PbmFormat`](xref:SixLabors.ImageSharp.Formats.Pbm.PbmFormat) | Read and write |
| PNG | [`PngFormat`](xref:SixLabors.ImageSharp.Formats.Png.PngFormat) | Read and write |
| QOI | [`QoiFormat`](xref:SixLabors.ImageSharp.Formats.Qoi.QoiFormat) | Read and write |
| TGA | [`TgaFormat`](xref:SixLabors.ImageSharp.Formats.Tga.TgaFormat) | Read and write |
| TIFF | [`TiffFormat`](xref:SixLabors.ImageSharp.Formats.Tiff.TiffFormat) | Read and write |
| WebP | [`WebpFormat`](xref:SixLabors.ImageSharp.Formats.Webp.WebpFormat) | Read and write |

ICO and CUR are distinct built-in formats even though detection is handled by a shared icon detector internally.

## At a Glance

If you only need a quick rule of thumb:

- JPEG is the usual choice for photos when small files matter and transparency does not.
- PNG is the usual choice for lossless graphics, screenshots, and transparency.
- GIF is mainly useful for simple palette-based animation and legacy compatibility.
- WebP covers lossy, lossless, transparency, and animation in one format family.
- TIFF is primarily for archival, print, interchange, and imaging-pipeline workflows.

Another way to think about it:

- Lossy formats: JPEG, lossy WebP.
- Lossless formats: PNG, lossless WebP, TIFF, QOI, BMP.
- Transparency-friendly formats: PNG, WebP, TIFF, TGA, QOI.
- Animation-friendly formats: GIF, animated PNG workflows through [`PngEncoder`](xref:SixLabors.ImageSharp.Formats.Png.PngEncoder), and animated WebP.

No single format is best everywhere. The right choice depends on whether your priority is fidelity, file size, transparency, animation, compatibility, or workflow metadata.

## Load, Detect, and Preserve Formats

[`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1) represents decoded pixel data. Once an image is loaded into memory, it is no longer tied to a specific file format unless you explicitly inspect or preserve that information.

ImageSharp can detect the encoded format of a source before loading it:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;

IImageFormat format = Image.DetectFormat("input.bin");

Console.WriteLine(format.Name);
```

Decoded images also keep the original format in [`ImageMetadata.DecodedImageFormat`](xref:SixLabors.ImageSharp.Metadata.ImageMetadata.DecodedImageFormat).

That metadata is useful when you want to explicitly save back to the originally decoded format, especially when writing to a stream where there is no file extension to select an encoder for you:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x.Resize(1200, 800));

if (image.Metadata.DecodedImageFormat is not null)
{
    using FileStream outputStream = File.Create("output.jpg");
    image.Save(outputStream, image.Metadata.DecodedImageFormat);
}
```

When you save by path, `image.Save("output.jpg")` or `image.Save("output.png")` selects the encoder from the destination file extension.

You can also choose a format explicitly by passing an encoder or by using the `SaveAs...()` helpers.

## Save with Explicit Encoders

[`ImageEncoder`](xref:SixLabors.ImageSharp.Formats.ImageEncoder) implementations are lightweight configuration objects. Create one when you want to control how a format is written:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Jpeg;
using SixLabors.ImageSharp.Formats.Png;

using Image image = Image.Load("input.png");

image.Save("output.jpg", new JpegEncoder { Quality = 85 });
image.Save("output.png", new PngEncoder());
```

ImageSharp also provides format-specific helpers:

- `image.SaveAsBmp()` (shortcut for `image.Save(new BmpEncoder())`)
- `image.SaveAsCur()` (shortcut for `image.Save(new CurEncoder())`)
- `image.SaveAsGif()` (shortcut for `image.Save(new GifEncoder())`)
- `image.SaveAsIco()` (shortcut for `image.Save(new IcoEncoder())`)
- `image.SaveAsJpeg()` (shortcut for `image.Save(new JpegEncoder())`)
- `image.SaveAsPbm()` (shortcut for `image.Save(new PbmEncoder())`)
- `image.SaveAsPng()` (shortcut for `image.Save(new PngEncoder())`)
- `image.SaveAsQoi()` (shortcut for `image.Save(new QoiEncoder())`)
- `image.SaveAsTga()` (shortcut for `image.Save(new TgaEncoder())`)
- `image.SaveAsTiff()` (shortcut for `image.Save(new TiffEncoder())`)
- `image.SaveAsWebp()` (shortcut for `image.Save(new WebpEncoder())`)

## General Decoder Options

Use [`DecoderOptions`](xref:SixLabors.ImageSharp.Formats.DecoderOptions) with the general `Load()` APIs when you want to control metadata handling, frame limits, or decode-to-size behavior:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;

DecoderOptions options = new()
{
    MaxFrames = 1,
    SkipMetadata = false,
    TargetSize = new Size(1600, 1600)
};

using Image image = Image.Load(options, "input.webp");
```

Format-specific decoder option types also exist for specialized scenarios such as JPEG and PNG.

## Common Encoder Families

Several formats share useful option sets through common encoder base types:

- [`ImageEncoder`](xref:SixLabors.ImageSharp.Formats.ImageEncoder) exposes `SkipMetadata`.
- [`AlphaAwareImageEncoder`](xref:SixLabors.ImageSharp.Formats.AlphaAwareImageEncoder) adds `TransparentColorMode`.
- [`QuantizingImageEncoder`](xref:SixLabors.ImageSharp.Formats.QuantizingImageEncoder) adds `Quantizer` and `PixelSamplingStrategy`.
- [`AnimatedImageEncoder`](xref:SixLabors.ImageSharp.Formats.AnimatedImageEncoder) adds `RepeatCount`, `BackgroundColor`, and `AnimateRootFrame`.

Those inherited options are especially useful when working with GIF, APNG, and animated WebP.
For a format-agnostic guide to palettes and dithered output, see [Quantization, Palettes, and Dithering](quantization.md).

## Format Guides

Use the format-specific guides for the common cases:

- [JPEG](jpeg.md) for photographic output and quality-focused lossy compression.
- [PNG](png.md) for lossless output, transparency, and APNG metadata.
- [GIF](gif.md) for palette-based animation workflows.
- [WebP](webp.md) for lossy, lossless, transparent, and animated WebP output.
- [TIFF](tiff.md) for workflows where compression mode, pixel layout, and TIFF metadata matter.

The less commonly used built-in formats still have valid niches:

- BMP is simple and broadly understood, but usually much larger than modern alternatives.
- ICO stores Windows icon files, often with multiple embedded image sizes.
- CUR stores Windows cursor files and hotspot metadata.
- PBM is useful for Netpbm-family workflows and simple interchange scenarios.
- TGA appears most often in graphics and content-pipeline tooling.
- QOI is a fast, simple lossless format with a much smaller ecosystem than PNG or WebP.

## Custom Format Registration

Format detectors, decoders, and encoders are registered through ImageSharp configuration. See [Configuration](configuration.md) if you need to customize the set of supported formats for your application.

## Choosing the Right Encoder

The right encoder settings depend on the tradeoff you want to make between:

- Image file size
- Encoder speed
- Image quality

The format-specific pages below are the best place to start when you need to tune those tradeoffs.
