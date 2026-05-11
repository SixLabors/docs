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

Those profiles serve different purposes. EXIF often contains camera settings, timestamps, orientation, thumbnails, and sometimes GPS data. ICC profiles describe how color values should be interpreted. CICP metadata can carry color coding information used by some modern image and video workflows. IPTC and XMP often contain editorial, rights, authoring, and workflow data.

That means metadata policy is not simply "keep" or "strip." A public thumbnail service may want to apply orientation and remove personal data. A print or archival pipeline may need to preserve color profiles and selected descriptive metadata. A conversion tool may need to translate what the destination format can represent and drop what it cannot.

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

Frame metadata matters for animation. Delay, blend mode, disposal mode, frame dimensions, and format-specific values can change how a multi-frame image plays even when the decoded pixels look reasonable in isolation.

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

## Practical Guidance

Inspect metadata before decoding pixels when routing or validation only needs headers and profiles. Preserve ICC or CICP data when color interpretation matters, or convert to a known output profile before stripping it. Apply `AutoOrient()` before removing EXIF orientation if the visual orientation must remain correct. Treat metadata as user data in privacy-sensitive workflows; EXIF, IPTC, and XMP can contain identifying information.
