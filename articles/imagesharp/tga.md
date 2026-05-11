# TGA

TGA, or Truevision TGA, is a straightforward raster format that still shows up in graphics tooling and content pipelines. It is less about delivery to browsers and more about simple pixel storage with familiar bit-depth and compression choices.

ImageSharp exposes TGA-specific APIs through [`TgaEncoder`](xref:SixLabors.ImageSharp.Formats.Tga.TgaEncoder) and [`TgaMetadata`](xref:SixLabors.ImageSharp.Formats.Tga.TgaMetadata).

## Format Characteristics

TGA is best thought of as a simple raster format for tooling and interchange.

TGA is common in graphics pipelines because it is straightforward and historically supported by many tools. It can store 8, 16, 24, or 32-bit output, and the alpha-channel bit count is part of the metadata story. That makes it useful when an asset pipeline expects a simple raster file with predictable channel layout.

Run-length encoding can reduce file size for images with repeated runs of pixels, such as flat-color artwork or masks. It is much less useful for noisy images or photographs. Choose compression based on the assets being exchanged and the expectations of the consuming tool.

A few practical implications:

- ImageSharp can write TGA output at 8, 16, 24, or 32 bits per pixel.
- ImageSharp supports uncompressed output or run-length encoded output through `TgaCompression`.
- `TgaMetadata` exposes encoded bit depth and alpha-channel bit information.
- TGA is often useful in asset pipelines, but it is rarely the best choice for browser-facing delivery.

## Save as TGA

Use [`TgaEncoder`](xref:SixLabors.ImageSharp.Formats.Tga.TgaEncoder) when you want explicit TGA bit-depth and compression control:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Tga;

using Image image = Image.Load("input.png");

image.Save("output.tga", new TgaEncoder
{
    BitsPerPixel = TgaBitsPerPixel.Bit32,
    Compression = TgaCompression.RunLength
});
```

## Key TGA Encoder Options

The most commonly used `TgaEncoder` options are:

- `BitsPerPixel` controls the encoded TGA bit depth.
- `Compression` switches between uncompressed and run-length encoded output.

Bit depth controls more than file size. A 32-bit TGA can carry alpha, while lower bit depths may not represent the same source data. Check `AlphaChannelBits` when moving assets through tools that care about alpha channels.

## Read TGA Metadata

Use `GetTgaMetadata()` to inspect TGA-specific metadata:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Tga;

using Image image = Image.Load("input.tga");

TgaMetadata tgaMetadata = image.Metadata.GetTgaMetadata();

Console.WriteLine(tgaMetadata.BitsPerPixel);
Console.WriteLine(tgaMetadata.AlphaChannelBits);
```

`TgaMetadata` includes values such as:

- `BitsPerPixel`
- `AlphaChannelBits`

## When to Use TGA

TGA is usually worth considering when:

- You are working with graphics or content-pipeline tooling that expects TGA.
- You want a simple raster format with predictable bit-depth choices.

TGA is usually a poor fit when:

- The output is primarily intended for browsers or compact delivery.
- You need richer metadata or broader ecosystem support.

For ordinary web or application output, [PNG](png.md), [JPEG](jpeg.md), and [WebP](webp.md) are usually better starting points.

## Practical Guidance

- Use TGA when an asset pipeline or graphics toolchain explicitly expects it.
- Check alpha-channel bit depth when moving assets between tools.
- Keep an editable source format alongside generated TGA assets.
- Prefer PNG, JPEG, or WebP for application and web delivery.
