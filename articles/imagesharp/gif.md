# GIF

GIF is one of the oldest formats ImageSharp supports, and it comes with tradeoffs that matter more than many newcomers expect. It is still useful for simple animation and very broad compatibility, but because it is palette based, color reduction and frame metadata are part of the story from the start.

In ImageSharp, GIF encoding is built on a quantizing animated encoder, which means palette generation and frame metadata are both important parts of the workflow.

## Format Characteristics

GIF is fundamentally a palette format. Each frame is limited to indexed colors rather than storing full true-color pixel data, which is why quantization and palette choice matter so much.

GIF stores each pixel as an index into a color table. A frame can use a global color table shared by the animation or a local color table for that frame. That design keeps the format simple and compatible, but it means full-color source images must be reduced to a limited palette before they can be written.

Transparency in GIF is also index based. A palette entry can be treated as transparent, but GIF does not have smooth per-pixel alpha like PNG or WebP. Soft edges, shadows, and semitransparent UI elements can therefore look jagged or require a matte color baked into the pixels.

Animation behavior is controlled by frame metadata. Frame delay, disposal mode, transparency index, repeat count, and color table mode all affect how the animation plays. When a converted GIF looks wrong, the issue is often frame metadata rather than the pixels alone.

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

using Image<Rgba32> gif = new(120, 120, Color.Black.ToPixel<Rgba32>());

gif.Metadata.GetGifMetadata().RepeatCount = 0;
gif.Frames.RootFrame.Metadata.GetGifMetadata().FrameDelay = 10;

using Image<Rgba32> frame = new(120, 120, Color.Orange.ToPixel<Rgba32>());
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

A global palette can keep animation output more consistent and can reduce overhead when frames share a similar color set. Local palettes can improve quality when frames differ significantly, but they can increase file size and make palette behavior harder to reason about. Choose based on the animation, not as a fixed rule.

`RepeatCount` controls looping. A value of `0` represents infinite looping in normal GIF usage. Frame delays are stored on frame metadata, so set them on the frames whose timing matters rather than assuming the encoder will infer the intended animation speed.

## Quantization and Palette Control

Every GIF encode in ImageSharp is a quantization step, because GIF stores indexed palette entries rather than full true-color pixels. If you do nothing, ImageSharp will still build a palette for you, but for gradients, photographic frames, UI art, or brand colors it is often worth controlling the quantizer explicitly.

The main knobs are:

- [`Quantizer`](xref:SixLabors.ImageSharp.Formats.QuantizingImageEncoder.Quantizer) to choose the palette-generation algorithm.
- [`PixelSamplingStrategy`](xref:SixLabors.ImageSharp.Formats.QuantizingImageEncoder.PixelSamplingStrategy) to control how source pixels are sampled while building the palette.
- [`TransparentColorMode`](xref:SixLabors.ImageSharp.Formats.AlphaAwareImageEncoder.TransparentColorMode) to control how transparent pixels are treated during quantization.

Common choices include:

- [`HexadecatreeQuantizer`](xref:SixLabors.ImageSharp.Processing.Processors.Quantization.HexadecatreeQuantizer) for a solid general-purpose adaptive palette.
- [`WuQuantizer`](xref:SixLabors.ImageSharp.Processing.Processors.Quantization.WuQuantizer) when you want a high-quality adaptive palette with configurable [`QuantizerOptions`](xref:SixLabors.ImageSharp.Processing.Processors.Quantization.QuantizerOptions).
- [`PaletteQuantizer`](xref:SixLabors.ImageSharp.Processing.Processors.Quantization.PaletteQuantizer) when you need to lock output to a known palette.

`QuantizerOptions` also exposes [`ColorMatchingMode`](xref:SixLabors.ImageSharp.Processing.Processors.Quantization.ColorMatchingMode) with the simplified `Coarse` and `Exact` choices for palette matching.

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

For a step-by-step multi-frame workflow, see [Working with Animations](animations.md). For a more modern animated format, see [WebP](webp.md).

## Practical Guidance

Use GIF for compatibility. It remains useful for simple looping animations and legacy-friendly workflows, but it is palette-constrained and rarely the most efficient modern animated format.

Control quantization deliberately because GIF quality depends heavily on palette choice. Gradients, photos, and subtle color changes can degrade quickly if the palette is poorly matched. Dithering can hide banding, but it can also add visible texture.

When converting existing animations, inspect frame delay, disposal mode, transparency, and repeat count. Those values define the animation behavior just as much as the pixels do. Prefer animated WebP or APNG when modern compression, alpha behavior, or color quality matters more than legacy support.
