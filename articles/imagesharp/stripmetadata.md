# Strip Metadata

Removing metadata is usually about one of three goals: smaller files, less personal information, or a cleaner normalized export. ImageSharp makes that straightforward, but it helps to be clear about whether you want the encoder to skip metadata on write or whether you want to clear profiles in memory first.

The choice matters because metadata is not one thing. EXIF can contain camera settings, timestamps, thumbnails, orientation, and GPS data. ICC and CICP data affect color interpretation. XMP and IPTC often contain authoring, rights, caption, and workflow information. Stripping everything is correct for privacy-sensitive exports, but not always correct for archival, print, or color-managed workflows.

## Strip Metadata with the Encoder

The simplest approach, when you control the output encoder, is to set [`ImageEncoder.SkipMetadata`](xref:SixLabors.ImageSharp.Formats.ImageEncoder.SkipMetadata) to `true`:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Jpeg;

using Image image = Image.Load("input.jpg");

image.Save("output.jpg", new JpegEncoder
{
    Quality = 85,
    SkipMetadata = true
});
```

The same pattern works with other encoders that derive from `ImageEncoder`, such as `PngEncoder` and `WebpEncoder`.

## Clear Common Metadata Profiles Manually

If you want to clear metadata directly on the decoded image before saving, remove the common profiles from `image.Metadata`:

```csharp
using SixLabors.ImageSharp;

using Image image = Image.Load("input.jpg");

image.Metadata.ExifProfile = null;
image.Metadata.IccProfile = null;
image.Metadata.IptcProfile = null;
image.Metadata.XmpProfile = null;
image.Metadata.CicpProfile = null;

image.Save("output.jpg");
```

This approach is useful when you want to inspect or edit metadata before deciding what to keep.

## Notes

- `SkipMetadata = true` is usually the easiest option when you are already choosing an explicit encoder.
- Manual profile clearing gives you more control over which metadata survives.
- Saving to a different format can also change which metadata can be represented in the output.
- If color fidelity matters, think carefully before removing ICC or CICP metadata. Convert to an intended working/output color space first when the source profile is meaningful.
- If orientation matters, call `AutoOrient()` before stripping EXIF orientation metadata so the pixels are physically normalized.

For more detail, see [Working with Metadata](metadata.md).

## Practical Guidance

- Use encoder-level `SkipMetadata` when the output should simply omit metadata.
- Clear profiles manually when you need to inspect, keep, or remove specific metadata groups.
- Convert or preserve color profiles intentionally before stripping ICC or CICP data.
- Apply `AutoOrient()` before stripping EXIF orientation metadata when display orientation matters.
