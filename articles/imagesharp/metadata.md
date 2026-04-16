# Working with Metadata

Metadata is where ImageSharp stores the information around the pixels: resolution, format details, EXIF, ICC profiles, and other auxiliary data. For newcomers, the key idea is that you can inspect or preserve this information without treating it as part of the pixel-processing pipeline itself.

ImageSharp exposes that data through [`ImageMetadata`](xref:SixLabors.ImageSharp.Metadata.ImageMetadata). You can access it from a fully decoded image through `image.Metadata`, or from [`ImageInfo`](xref:SixLabors.ImageSharp.ImageInfo) when using `Image.Identify()`.

## Read Metadata from a File

Use `Image.Identify()` when you only need metadata and dimensions:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Metadata;

ImageInfo imageInfo = Image.Identify("photo.jpg");
ImageMetadata metadata = imageInfo.Metadata;

Console.WriteLine(metadata.DecodedImageFormat?.Name);
Console.WriteLine(metadata.HorizontalResolution);
Console.WriteLine(metadata.VerticalResolution);
```

If you are already loading the image for processing, use `image.Metadata` instead.

## Common Metadata Profiles

Depending on the source format, `ImageMetadata` can expose several common profiles:

- `ExifProfile` for camera, orientation, and capture metadata.
- `IccProfile` for embedded color profile data.
- `IptcProfile` for editorial and descriptive metadata.
- `XmpProfile` for extensible structured metadata.
- `CicpProfile` for coding-independent code points metadata when present.

These profile properties are nullable because not every image carries every kind of metadata.

## Work with Format-Specific Metadata

In addition to the common profiles, ImageSharp exposes format-specific metadata helpers:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Jpeg;
using SixLabors.ImageSharp.Formats.Png;

using Image image = Image.Load("photo.jpg");

JpegMetadata jpegMetadata = image.Metadata.GetJpegMetadata();
PngMetadata pngMetadata = image.Metadata.GetPngMetadata();
```

Similar helpers exist for other built-in formats, including EXR, GIF, TIFF, and WebP.

## Access Frame Metadata

Multi-frame formats can also expose per-frame metadata:

```csharp
using SixLabors.ImageSharp;

ImageInfo imageInfo = Image.Identify("animation.webp");

Console.WriteLine($"Frame count: {imageInfo.FrameMetadataCollection.Count}");
```

This is useful when inspecting animated formats without decoding every frame into pixel memory.

## Strip Metadata Before Saving

If you do not want to preserve the original metadata, clear the profiles before saving:

```csharp
using SixLabors.ImageSharp;

using Image image = Image.Load("photo.jpg");

image.Metadata.ExifProfile = null;
image.Metadata.IccProfile = null;
image.Metadata.IptcProfile = null;
image.Metadata.XmpProfile = null;
image.Metadata.CicpProfile = null;

image.Save("photo-stripped.jpg");
```

This is a common step when reducing file size, removing personal data, or normalizing exported assets.

## Preserve Metadata Intentionally

ImageSharp preserves metadata by default when the decoder and encoder both support that metadata. If metadata is important to your workflow, keep these points in mind:

- `Image.Identify()` lets you inspect metadata without paying for a full decode.
- `DecodedImageFormat` tells you which encoded format was originally loaded.
- Saving to a different format may change which metadata can be represented in the output.

For deeper guidance on loading and saving workflows, see [Loading, Identifying, and Saving](loadingandsaving.md). For ICC and CICP-specific guidance, see [Color Profiles and Color Conversion](colorprofiles.md).
