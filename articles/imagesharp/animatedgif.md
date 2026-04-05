# Create an Animated GIF

Creating an animated GIF in ImageSharp is really about building a multi-frame image on purpose. Once that mental model is in place, the rest of the API starts to feel straightforward: create frames, set per-frame metadata, configure the animation metadata, then save with the encoder you want.

ImageSharp builds animated GIFs by creating a multi-frame [`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1), configuring GIF metadata, and then saving with [`GifEncoder`](xref:SixLabors.ImageSharp.Formats.Gif.GifEncoder) when you need encoder-specific control. When you start from [`Color`](xref:SixLabors.ImageSharp.Color) values, convert them to the target pixel type with `ToPixel<TPixel>()` before passing them to generic image constructors.

For format background and palette tradeoffs, see [GIF and Animation](gif.md). This page focuses on the actual authoring workflow.

## Build a Multi-Frame GIF

The root frame is the first animation frame. Additional frames are appended through [`ImageFrameCollection.AddFrame()`](xref:SixLabors.ImageSharp.ImageFrameCollection.AddFrame(SixLabors.ImageSharp.ImageFrame)), which clones the source frame and requires it to match the image dimensions.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;
using SixLabors.ImageSharp.Formats.Gif;
using SixLabors.ImageSharp.PixelFormats;

Color[] colors =
{
    Color.Orange,
    Color.DeepSkyBlue,
    Color.MediumSeaGreen
};

using Image<Rgba32> gif = new(120, 120, colors[0].ToPixel<Rgba32>());

GifMetadata gifMetadata = gif.Metadata.GetGifMetadata();
gifMetadata.RepeatCount = 0;

GifFrameMetadata rootFrameMetadata = gif.Frames.RootFrame.Metadata.GetGifMetadata();
rootFrameMetadata.FrameDelay = 10;
rootFrameMetadata.DisposalMode = FrameDisposalMode.RestoreToBackground;

for (int i = 1; i < colors.Length; i++)
{
    using Image<Rgba32> frameImage = new(120, 120, colors[i].ToPixel<Rgba32>());

    GifFrameMetadata frameMetadata = frameImage.Frames.RootFrame.Metadata.GetGifMetadata();
    frameMetadata.FrameDelay = 10;
    frameMetadata.DisposalMode = FrameDisposalMode.RestoreToBackground;

    gif.Frames.AddFrame(frameImage.Frames.RootFrame);
}

gif.SaveAsGif("output.gif", new GifEncoder
{
    ColorTableMode = FrameColorTableMode.Global
});
```

## Control Looping and Frame Timing

[`GifMetadata`](xref:SixLabors.ImageSharp.Formats.Gif.GifMetadata) stores image-level animation settings:

- [`RepeatCount`](xref:SixLabors.ImageSharp.Formats.Gif.GifMetadata.RepeatCount) controls looping. `0` means loop indefinitely.
- [`ColorTableMode`](xref:SixLabors.ImageSharp.Formats.Gif.GifMetadata.ColorTableMode) describes whether the animation uses a global or local palette layout.

[`GifFrameMetadata`](xref:SixLabors.ImageSharp.Formats.Gif.GifFrameMetadata) stores per-frame settings:

- [`FrameDelay`](xref:SixLabors.ImageSharp.Formats.Gif.GifFrameMetadata.FrameDelay) is measured in hundredths of a second.
- [`DisposalMode`](xref:SixLabors.ImageSharp.Formats.Gif.GifFrameMetadata.DisposalMode) controls how the previous frame is treated before the next frame is drawn.
- [`ColorTableMode`](xref:SixLabors.ImageSharp.Formats.Gif.GifFrameMetadata.ColorTableMode) can override palette behavior for an individual frame.

The most important disposal modes are:

- [`DoNotDispose`](xref:SixLabors.ImageSharp.Formats.FrameDisposalMode.DoNotDispose) when later frames should draw over earlier content.
- [`RestoreToBackground`](xref:SixLabors.ImageSharp.Formats.FrameDisposalMode.RestoreToBackground) when a frame should be cleared before the next frame is shown.
- [`RestoreToPrevious`](xref:SixLabors.ImageSharp.Formats.FrameDisposalMode.RestoreToPrevious) when the previous composited state should be restored.

## Palette Choice Still Matters

GIF is always palette-based, so saving an animation is always a quantization step. [`GifEncoder`](xref:SixLabors.ImageSharp.Formats.Gif.GifEncoder) inherits the quantization controls exposed by [`QuantizingImageEncoder`](xref:SixLabors.ImageSharp.Formats.QuantizingImageEncoder):

- [`Quantizer`](xref:SixLabors.ImageSharp.Formats.QuantizingImageEncoder.Quantizer)
- [`PixelSamplingStrategy`](xref:SixLabors.ImageSharp.Formats.QuantizingImageEncoder.PixelSamplingStrategy)
- [`TransparentColorMode`](xref:SixLabors.ImageSharp.Formats.AlphaAwareImageEncoder.TransparentColorMode)

In practice:

- Use [`FrameColorTableMode.Global`](xref:SixLabors.ImageSharp.Formats.FrameColorTableMode.Global) when you want one shared palette across the animation, often for smaller files and more consistent colors across frames.
- Use [`FrameColorTableMode.Local`](xref:SixLabors.ImageSharp.Formats.FrameColorTableMode.Local) when frames differ enough that per-frame palettes produce better results.
- Choose an explicit quantizer when gradients, UI art, or brand colors matter.

See [Quantization, Palettes, and Dithering](quantization.md) for the full quantization story.

## Practical Guidance

- Keep frame dimensions consistent with the GIF canvas size before adding them.
- Set `FrameDelay` and `DisposalMode` on every frame you care about rather than relying on defaults.
- Prefer a global palette for simple flat-color or UI-style animations.
- Consider [WebP](webp.md) instead of GIF when you need better compression or more modern animation behavior.
