# ANI

ANI is the Windows animated cursor format. It is a RIFF container that stores a sequence of embedded CUR, ICO, or BMP resources together with animation timing and ordering data.

ImageSharp exposes ANI-specific APIs through [`AniEncoder`](xref:SixLabors.ImageSharp.Formats.Ani.AniEncoder), [`AniMetadata`](xref:SixLabors.ImageSharp.Formats.Ani.AniMetadata), and [`AniFrameMetadata`](xref:SixLabors.ImageSharp.Formats.Ani.AniFrameMetadata).

## Format Characteristics

ANI is best thought of as an animation container over cursor resources rather than a normal image file format.

Each frame resource is a complete embedded file, most commonly a Windows cursor. A `seq ` chunk can map animation steps to frame resources, so one resource can appear at several points in the animation. A `rate` chunk can give each step its own display time. Timing is measured in sixtieths of a second, sometimes called jiffies.

A few practical implications:

- One frame resource can contain multiple sizes, exactly like ICO and CUR files.
- Frame timing lives per step, with a file-level default display rate.
- Cursor hotspot coordinates apply per frame, exactly as in CUR.
- ANI is useful when you need Windows animated cursor output, not when you need a general-purpose animation format.

## Decoding Behavior

When ImageSharp decodes an ANI file, each animation step becomes one or more frames in the decoded image:

- If the file contains a `seq ` chunk, the decoder follows it to project steps onto frame resources. Without one, the resources play in storage order.
- Every image inside the referenced resource becomes a frame on a shared canvas sized to the largest resource. The encoded dimensions of each variant are preserved in the frame metadata.
- Frames decoded from the same animation step share a [`SequenceNumber`](xref:SixLabors.ImageSharp.Formats.Ani.AniFrameMetadata.SequenceNumber), which groups them as resolution variants of one step.
- Each step's display time comes from the `rate` chunk when present, or from the header's default display rate.

## Save as ANI

Use [`AniEncoder`](xref:SixLabors.ImageSharp.Formats.Ani.AniEncoder) or `image.SaveAsAni(...)` when you want Windows animated cursor output:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Ani;
using SixLabors.ImageSharp.PixelFormats;

using Image<Rgba32> image = Image.Load<Rgba32>("frame-source.png");

AniFrameMetadata frameMetadata = image.Frames.RootFrame.Metadata.GetAniMetadata();
frameMetadata.FrameDelay = 10; // Sixtieths of a second.
frameMetadata.HotspotX = 4;
frameMetadata.HotspotY = 4;

image.SaveAsAni("pointer.ani");
```

The encoder derives one animation step per frame by default. Give adjacent frames the same positive [`SequenceNumber`](xref:SixLabors.ImageSharp.Formats.Ani.AniFrameMetadata.SequenceNumber) to group them as resolution variants of a single step. A non-positive value encodes the frame as its own animation step.

[`AniEncoder`](xref:SixLabors.ImageSharp.Formats.Ani.AniEncoder) inherits the quantizer and pixel sampling options of [`QuantizingImageEncoder`](xref:SixLabors.ImageSharp.Formats.QuantizingImageEncoder). These options are passed through to the embedded CUR, ICO, or BMP encoders.

## ANI Metadata

Image-level values live on [`AniMetadata`](xref:SixLabors.ImageSharp.Formats.Ani.AniMetadata):

- `DisplayRate` is the default frame display time in sixtieths of a second.
- `Flags` records whether frame resources are ICO/CUR or BMP data, and whether the file carries a sequence chunk.
- `Name` and `Artist` carry the animation title and author when present.
- `Width`, `Height`, `BitCount`, and `Planes` mirror the ANI header. Icon-based files commonly store zero here because each embedded resource declares its own dimensions and pixel layout.

The most useful frame-level values live on [`AniFrameMetadata`](xref:SixLabors.ImageSharp.Formats.Ani.AniFrameMetadata):

- `FrameDelay` is the display time for the frame's step in sixtieths of a second.
- `SequenceNumber` groups adjacent frames as resolution variants of one animation step.
- `FrameFormat` records whether the frame came from a CUR, ICO, or BMP resource.
- `HotspotX` and `HotspotY` control the cursor hotspot coordinates.
- `EncodingWidth`, `EncodingHeight`, `Compression`, `BmpBitsPerPixel`, and `ColorTable` describe how the frame is stored, exactly as in ICO and CUR.

## Read ANI Metadata

Use `Image.Identify()` when you want animation metadata without a full decode:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Ani;

ImageInfo info = Image.Identify("pointer.ani");

Console.WriteLine($"Frames: {info.FrameMetadataCollection.Count}");

AniMetadata aniMetadata = info.Metadata.GetAniMetadata();
AniFrameMetadata firstFrame = info.FrameMetadataCollection[0].GetAniMetadata();

Console.WriteLine(aniMetadata.DisplayRate);
Console.WriteLine(firstFrame.FrameDelay);
Console.WriteLine(firstFrame.HotspotX);
```

## When to Use ANI

ANI is usually worth considering when:

- You need a Windows animated cursor file.
- Hotspot position and per-step timing are part of the asset contract.

ANI is usually a poor fit when:

- You need a general-purpose animation format. Use GIF, animated PNG, or animated WebP instead.
- You want broad compatibility outside Windows cursor workflows.

For static Windows cursor assets, see [CUR](cur.md). For Windows icon assets, see [ICO](ico.md).

## Practical Guidance

- Treat hotspot coordinates and step timing as part of the cursor asset, not incidental metadata.
- Use `SequenceNumber` to group resolution variants, and validate every embedded size.
- Use ANI only when the output is meant to behave as an animated cursor.
- Use GIF, animated PNG, or animated WebP for ordinary animation output.
