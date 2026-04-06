# Working with Animations

ImageSharp treats animation as a multi-frame [`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1). The authoring model is the same whether you save as GIF, animated PNG (APNG), or animated WebP: build the frame collection, set image-level animation metadata, set per-frame metadata, then save with the encoder for the format you want.

You still work with full-size frames in memory, but ImageSharp's animated encoders optimize the output by de-duplicating unchanged pixels between frames and writing only the differing region for later frames where the format supports it.

For format-specific background, palette, and compression tradeoffs, see [GIF](gif.md), [PNG](png.md), and [WebP](webp.md). This page focuses on the shared multi-frame workflow.

## Build a Multi-Frame Animation

The root frame is the first animation frame. Additional frames are appended through [`ImageFrameCollection.AddFrame()`](xref:SixLabors.ImageSharp.ImageFrameCollection.AddFrame(SixLabors.ImageSharp.ImageFrame)), which clones the source frame. In ImageSharp, animation frames must always match the image dimensions.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

Color[] colors =
{
    Color.Orange,
    Color.DeepSkyBlue,
    Color.MediumSeaGreen
};

using Image<Rgba32> animation = new(120, 120, colors[0].ToPixel<Rgba32>());

for (int i = 1; i < colors.Length; i++)
{
    using Image<Rgba32> frameImage = new(120, 120, colors[i].ToPixel<Rgba32>());
    animation.Frames.AddFrame(frameImage.Frames.RootFrame);
}
```

When you start from [`Color`](xref:SixLabors.ImageSharp.Color) values, convert them to the target pixel type with `ToPixel<TPixel>()` before passing them to generic image constructors.

## ImageSharp Optimizes Later Frames

When encoding GIF, APNG, or animated WebP, ImageSharp compares later frames with the previous composited result and trims unchanged pixels from the encoded output. In practice, that means you usually author full-canvas frames, but the encoder writes only the changed bounds for later frames when that produces an equivalent animation.

This is especially helpful for sprite, UI, and cursor-style animations where only a small region changes from one frame to the next.

## Configure GIF Metadata

Use [`GifMetadata`](xref:SixLabors.ImageSharp.Formats.Gif.GifMetadata) and [`GifFrameMetadata`](xref:SixLabors.ImageSharp.Formats.Gif.GifFrameMetadata) when you are saving palette-based animation:

- [`RepeatCount`](xref:SixLabors.ImageSharp.Formats.Gif.GifMetadata.RepeatCount) controls looping. `0` means loop indefinitely.
- [`FrameDelay`](xref:SixLabors.ImageSharp.Formats.Gif.GifFrameMetadata.FrameDelay) is measured in hundredths of a second.
- [`DisposalMode`](xref:SixLabors.ImageSharp.Formats.Gif.GifFrameMetadata.DisposalMode) controls how the previous composited frame is treated before the next frame is shown.

Starting from an existing `Image<Rgba32> animation`:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;
using SixLabors.ImageSharp.Formats.Gif;
using SixLabors.ImageSharp.PixelFormats;

GifMetadata gifMetadata = animation.Metadata.GetGifMetadata();
gifMetadata.RepeatCount = 0;

foreach (ImageFrame<Rgba32> frame in animation.Frames)
{
    GifFrameMetadata frameMetadata = frame.Metadata.GetGifMetadata();
    frameMetadata.FrameDelay = 10;
    frameMetadata.DisposalMode = FrameDisposalMode.RestoreToBackground;
}

animation.Save("output.gif", new GifEncoder
{
    ColorTableMode = FrameColorTableMode.Global
});
```

GIF is always palette-based, so palette selection still matters. See [GIF](gif.md) and [Quantization, Palettes, and Dithering](quantization.md) for the full quantization story.

## Configure APNG Metadata

Use [`PngMetadata`](xref:SixLabors.ImageSharp.Formats.Png.PngMetadata) and [`PngFrameMetadata`](xref:SixLabors.ImageSharp.Formats.Png.PngFrameMetadata) when you want animated PNG output:

- [`RepeatCount`](xref:SixLabors.ImageSharp.Formats.Png.PngMetadata.RepeatCount) controls looping.
- [`AnimateRootFrame`](xref:SixLabors.ImageSharp.Formats.Png.PngMetadata.AnimateRootFrame) controls whether the root frame participates in the animation.
- [`FrameDelay`](xref:SixLabors.ImageSharp.Formats.Png.PngFrameMetadata.FrameDelay) is stored as a `Rational`.
- [`DisposalMode`](xref:SixLabors.ImageSharp.Formats.Png.PngFrameMetadata.DisposalMode) and [`BlendMode`](xref:SixLabors.ImageSharp.Formats.Png.PngFrameMetadata.BlendMode) control how frames compose.

Continuing from the same `Image<Rgba32> animation`:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;
using SixLabors.ImageSharp.Formats.Png;
using SixLabors.ImageSharp.PixelFormats;

PngMetadata pngMetadata = animation.Metadata.GetPngMetadata();
pngMetadata.RepeatCount = 0;
pngMetadata.AnimateRootFrame = true;

foreach (ImageFrame<Rgba32> frame in animation.Frames)
{
    PngFrameMetadata frameMetadata = frame.Metadata.GetPngMetadata();
    frameMetadata.FrameDelay = new Rational(1, 10);
    frameMetadata.DisposalMode = FrameDisposalMode.DoNotDispose;
    frameMetadata.BlendMode = FrameBlendMode.Over;
}

animation.Save("output.png", new PngEncoder());
```

## Configure Animated WebP Metadata

Use [`WebpMetadata`](xref:SixLabors.ImageSharp.Formats.Webp.WebpMetadata) and [`WebpFrameMetadata`](xref:SixLabors.ImageSharp.Formats.Webp.WebpFrameMetadata) when you want animated WebP output:

- [`RepeatCount`](xref:SixLabors.ImageSharp.Formats.Webp.WebpMetadata.RepeatCount) controls looping.
- [`BackgroundColor`](xref:SixLabors.ImageSharp.Formats.Webp.WebpMetadata.BackgroundColor) is used by the format and matters when a frame uses `RestoreToBackground`.
- [`FrameDelay`](xref:SixLabors.ImageSharp.Formats.Webp.WebpFrameMetadata.FrameDelay) is measured in milliseconds.
- [`DisposalMode`](xref:SixLabors.ImageSharp.Formats.Webp.WebpFrameMetadata.DisposalMode) and [`BlendMode`](xref:SixLabors.ImageSharp.Formats.Webp.WebpFrameMetadata.BlendMode) control how frames compose.

Continuing from the same `Image<Rgba32> animation`:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;
using SixLabors.ImageSharp.Formats.Webp;
using SixLabors.ImageSharp.PixelFormats;

WebpMetadata webpMetadata = animation.Metadata.GetWebpMetadata();
webpMetadata.RepeatCount = 0;
webpMetadata.BackgroundColor = Color.Transparent;

foreach (ImageFrame<Rgba32> frame in animation.Frames)
{
    WebpFrameMetadata frameMetadata = frame.Metadata.GetWebpMetadata();
    frameMetadata.FrameDelay = 100;
    frameMetadata.DisposalMode = FrameDisposalMode.DoNotDispose;
    frameMetadata.BlendMode = FrameBlendMode.Over;
}

animation.Save("output.webp", new WebpEncoder());
```

## Practical Guidance

- ImageSharp animation frames must always be the same size as the animation canvas.
- Set timing and disposal or blend metadata on every frame you care about rather than relying on defaults.
- Choose GIF when broad legacy compatibility matters more than palette and compression tradeoffs.
- Choose APNG when you want PNG-style lossless color and alpha with explicit frame blending and disposal.
- Choose WebP when you want a modern animated format with flexible compression behavior.
