# CUR

CUR is the Windows cursor format. It is closely related to ICO, but it carries cursor-specific hotspot information so the runtime knows which pixel is the active click point.

ImageSharp exposes CUR-specific APIs through [`CurEncoder`](xref:SixLabors.ImageSharp.Formats.Cur.CurEncoder), [`CurMetadata`](xref:SixLabors.ImageSharp.Formats.Cur.CurMetadata), and [`CurFrameMetadata`](xref:SixLabors.ImageSharp.Formats.Cur.CurFrameMetadata).

## Format Characteristics

CUR is best thought of as a cursor container rather than a normal image file format.

CUR shares much of the icon-container shape with ICO, but cursor files add hotspot coordinates. The hotspot is the active point of the cursor: for an arrow it is normally the tip; for a crosshair it may be the center. If the hotspot is wrong, the image can look correct while clicking and hit testing feel wrong.

Like ICO, a CUR file can contain multiple embedded images for different sizes. Consumers can choose a frame based on display scale or cursor size. Hotspot metadata is per frame, so every embedded cursor image needs correct hotspot coordinates.

A few practical implications:

- Existing CUR files can contain one or more cursor images.
- Cursor-specific metadata lives primarily on [`CurFrameMetadata`](xref:SixLabors.ImageSharp.Formats.Cur.CurFrameMetadata).
- `HotspotX` and `HotspotY` are the key extra values that distinguish cursor assets from icons.
- CUR is useful when you need Windows cursor output with hotspot metadata, not when you need a general-purpose image format.

## Save as CUR

Use [`CurEncoder`](xref:SixLabors.ImageSharp.Formats.Cur.CurEncoder) when you want Windows cursor output:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Cur;
using SixLabors.ImageSharp.PixelFormats;

using Image<Rgba32> image = Image.Load<Rgba32>("cursor-source.png");

CurFrameMetadata frameMetadata = image.Frames.RootFrame.Metadata.GetCurMetadata();
frameMetadata.HotspotX = 4;
frameMetadata.HotspotY = 4;

image.Save("pointer.cur", new CurEncoder());
```

## CUR Frame Metadata

The most useful CUR-specific values live on [`CurFrameMetadata`](xref:SixLabors.ImageSharp.Formats.Cur.CurFrameMetadata):

- `HotspotX` and `HotspotY` control the cursor hotspot coordinates.
- `EncodingWidth` and `EncodingHeight` describe the encoded cursor dimensions for that frame.
- `Compression` and `BmpBitsPerPixel` describe how the frame is stored.

[`CurMetadata`](xref:SixLabors.ImageSharp.Formats.Cur.CurMetadata) mirrors the root frame's compression, bit depth, and color-table information at the image level.

Treat hotspot coordinates as part of the user interaction contract. They should be chosen from the cursor design, not copied blindly from another size unless the coordinate scales correctly.

## Read CUR Metadata

Use `Image.Identify()` when you want cursor metadata without a full decode:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Cur;

ImageInfo info = Image.Identify("pointer.cur");

Console.WriteLine($"Embedded cursor images: {info.FrameMetadataCollection.Count}");

CurMetadata curMetadata = info.Metadata.GetCurMetadata();
CurFrameMetadata firstFrame = info.FrameMetadataCollection[0].GetCurMetadata();

Console.WriteLine(curMetadata.Compression);
Console.WriteLine(firstFrame.HotspotX);
Console.WriteLine(firstFrame.HotspotY);
```

## When to Use CUR

CUR is usually worth considering when:

- You need a Windows cursor file.
- The hotspot position is part of the asset contract.

CUR is usually a poor fit when:

- You are storing a normal image rather than a cursor asset.
- You want broad compatibility outside Windows cursor workflows.

For Windows icon assets without cursor hotspots, see [ICO](ico.md).

## Practical Guidance

- Treat hotspot coordinates as part of the cursor asset, not incidental metadata.
- Validate all embedded frames when generating multi-size cursor files.
- Use CUR only when the output is meant to behave as a cursor.
- Use ICO, PNG, or another ordinary image format when hotspot metadata is not required.
