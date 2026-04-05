# Strip Metadata

Stripping metadata is useful when reducing file size, removing personal information, or normalizing exported assets.

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

For more detail, see [Working with Metadata](metadata.md).
