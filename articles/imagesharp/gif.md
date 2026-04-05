# GIF and Animation

GIF is one of the oldest formats ImageSharp supports, and it comes with tradeoffs that matter more than many newcomers expect. It is still useful for simple animation and very broad compatibility, but because it is palette based, color reduction and frame metadata are part of the story from the start.

In ImageSharp, GIF encoding is built on a quantizing animated encoder, which means palette generation and frame metadata are both important parts of the workflow.

## Format Characteristics

GIF is fundamentally a palette format. Each frame is limited to indexed colors rather than storing full true-color pixel data, which is why quantization and palette choice matter so much.

A few practical implications:

- GIF is well known and widely compatible for simple animations.
- GIF is limited compared to modern formats for photographic or high-color imagery.
- GIF transparency is palette/index based rather than full alpha blending.
- GIF is usually chosen for compatibility or simplicity rather than compression efficiency.

## Save as GIF

Use [`GifEncoder`](xref:SixLabors.ImageSharp.Formats.Gif.GifEncoder) when you want to control GIF output:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;
using SixLabors.ImageSharp.Formats.Gif;
using SixLabors.ImageSharp.PixelFormats;

using Image<Rgba32> gif = new(120, 120, Color.Black);

gif.Metadata.GetGifMetadata().RepeatCount = 0;
gif.Frames.RootFrame.Metadata.GetGifMetadata().FrameDelay = 10;

using Image<Rgba32> frame = new(120, 120, Color.Orange);
frame.Frames.RootFrame.Metadata.GetGifMetadata().FrameDelay = 10;

gif.Frames.AddFrame(frame.Frames.RootFrame);

gif.Save("output.gif", new GifEncoder
{
    ColorTableMode = FrameColorTableMode.Global
});
```

## Key GIF Encoder Options

The main `GifEncoder` option is `ColorTableMode`, which controls whether frames use a shared global palette or per-frame local palettes.

Because `GifEncoder` inherits from [`QuantizingAnimatedImageEncoder`](xref:SixLabors.ImageSharp.Formats.QuantizingAnimatedImageEncoder), it also supports:

- `RepeatCount`
- `BackgroundColor`
- `AnimateRootFrame`
- `Quantizer`
- `PixelSamplingStrategy`
- `TransparentColorMode`

## Quantization and Palette Control

Every GIF encode in ImageSharp is a quantization step, because GIF stores indexed palette entries rather than full true-color pixels. If you do nothing, ImageSharp will still build a palette for you, but for gradients, photographic frames, UI art, or brand colors it is often worth controlling the quantizer explicitly.

The main knobs are:

- [`Quantizer`](xref:SixLabors.ImageSharp.Formats.QuantizingImageEncoder.Quantizer) to choose the palette-generation algorithm.
- [`PixelSamplingStrategy`](xref:SixLabors.ImageSharp.Formats.QuantizingImageEncoder.PixelSamplingStrategy) to control how source pixels are sampled while building the palette.
- [`TransparentColorMode`](xref:SixLabors.ImageSharp.Formats.AlphaAwareImageEncoder.TransparentColorMode) to control how transparent pixels are treated during quantization.

Common choices include:

- [`OctreeQuantizer`](xref:SixLabors.ImageSharp.Processing.Processors.Quantization.OctreeQuantizer) for a solid general-purpose adaptive palette.
- [`WuQuantizer`](xref:SixLabors.ImageSharp.Processing.Processors.Quantization.WuQuantizer) when you want a high-quality adaptive palette with configurable [`QuantizerOptions`](xref:SixLabors.ImageSharp.Processing.Processors.Quantization.QuantizerOptions).
- [`PaletteQuantizer`](xref:SixLabors.ImageSharp.Processing.Processors.Quantization.PaletteQuantizer) when you need to lock output to a known palette.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;
using SixLabors.ImageSharp.Formats.Gif;
using SixLabors.ImageSharp.Processing.Processors.Quantization;

using Image image = Image.Load("input.gif");

image.Save("output.gif", new GifEncoder
{
    ColorTableMode = FrameColorTableMode.Global,
    Quantizer = new WuQuantizer(new QuantizerOptions
    {
        MaxColors = 128,
        Dither = null,
        TransparentColorMode = TransparentColorMode.Preserve
    })
});
```

Reducing `MaxColors` can shrink files, but it also makes banding and contouring more likely. Dithering can hide some of that, at the cost of more visible texture.

## GIF Metadata

Use `GetGifMetadata()` to inspect or modify GIF-level metadata:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Gif;

using Image image = Image.Load("input.gif");

GifMetadata gifMetadata = image.Metadata.GetGifMetadata();
```

`GifMetadata` includes values such as `RepeatCount`, `ColorTableMode`, and the global color table.

Per-frame metadata is available through [`GifFrameMetadata`](xref:SixLabors.ImageSharp.Formats.Gif.GifFrameMetadata), including:

- `FrameDelay`
- `DisposalMode`
- `ColorTableMode`
- `HasTransparency`
- `TransparencyIndex`

## GIF Tradeoffs

GIF is best suited to simple animation and palette-based content. It is usually not the best fit for photographic imagery because the format is palette-constrained and heavily depends on quantization.

GIF is usually a good fit when:

- You need a simple looping animation format with broad legacy support.
- The content uses relatively few colors.
- You are comfortable with palette-based tradeoffs.

GIF is usually a poor fit when:

- The animation contains gradients, photos, or subtle color transitions.
- You want efficient compression.
- You need modern transparency behavior.

For a step-by-step recipe, see [Create an animated GIF](animatedgif.md). For a more modern animated format, see [WebP](webp.md).
