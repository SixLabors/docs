# ICO

ICO is the Windows icon container format. It is designed to carry icon image data rather than act as a general-purpose picture format, and ImageSharp exposes both image-level and frame-level ICO metadata because individual embedded icon images can vary.

ImageSharp exposes ICO-specific APIs through [`IcoEncoder`](xref:SixLabors.ImageSharp.Formats.Ico.IcoEncoder), [`IcoMetadata`](xref:SixLabors.ImageSharp.Formats.Ico.IcoMetadata), and [`IcoFrameMetadata`](xref:SixLabors.ImageSharp.Formats.Ico.IcoFrameMetadata).

## Format Characteristics

ICO is best thought of as a container for one or more icon images.

A few practical implications:

- Existing ICO files can contain one or more embedded icon images.
- ImageSharp exposes per-frame icon details such as `Compression`, `BmpBitsPerPixel`, `EncodingWidth`, and `EncodingHeight`.
- Frame compression is represented through [`IconFrameCompression`](xref:SixLabors.ImageSharp.Formats.Icon.IconFrameCompression).
- ICO is a Windows asset format, not a general interchange format for ordinary images.

## Save as ICO

Use [`IcoEncoder`](xref:SixLabors.ImageSharp.Formats.Ico.IcoEncoder) when you want Windows icon output:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Ico;
using SixLabors.ImageSharp.Formats.Icon;
using SixLabors.ImageSharp.PixelFormats;

using Image<Rgba32> image = Image.Load<Rgba32>("icon-source.png");

IcoFrameMetadata frameMetadata = image.Frames.RootFrame.Metadata.GetIcoMetadata();
frameMetadata.Compression = IconFrameCompression.Png;
frameMetadata.EncodingWidth = 64;
frameMetadata.EncodingHeight = 64;

image.Save("app.ico", new IcoEncoder());
```

## ICO Frame Metadata

The most useful ICO-specific values live on [`IcoFrameMetadata`](xref:SixLabors.ImageSharp.Formats.Ico.IcoFrameMetadata):

- `Compression` controls whether the encoded frame uses BMP or PNG storage.
- `BmpBitsPerPixel` controls the BMP bit depth when the frame is stored as BMP.
- `EncodingWidth` and `EncodingHeight` describe the encoded icon dimensions for that frame.

[`IcoMetadata`](xref:SixLabors.ImageSharp.Formats.Ico.IcoMetadata) mirrors the root frame's compression, bit depth, and color-table information at the image level.

## Read ICO Metadata

Use `Image.Identify()` when you want to inspect the icon container without decoding every embedded image:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Ico;

ImageInfo info = Image.Identify("app.ico");

Console.WriteLine($"Embedded images: {info.FrameMetadataCollection.Count}");

IcoMetadata icoMetadata = info.Metadata.GetIcoMetadata();
IcoFrameMetadata firstFrame = info.FrameMetadataCollection[0].GetIcoMetadata();

Console.WriteLine(icoMetadata.Compression);
Console.WriteLine(firstFrame.EncodingWidth);
Console.WriteLine(firstFrame.EncodingHeight);
```

## When to Use ICO

ICO is usually worth considering when:

- You need a Windows icon file.
- You care about icon-specific frame metadata such as encoded icon dimensions or frame compression.

ICO is usually a poor fit when:

- You are storing ordinary images rather than icons.
- You want a broadly portable web or application image format.

For ordinary image delivery or storage, [PNG](png.md), [WebP](webp.md), and [JPEG](jpeg.md) are usually better choices.
