# Recipes

These pages are the fast path through the ImageSharp docs. They skip most of the background explanation and focus on the handful of workflows people reach for over and over again, while linking back to the deeper guides when you need more context.

## Common Tasks

- [Generate Thumbnails](thumbnails.md) for fit-within-box and square-crop thumbnail workflows.
- [Convert Between Formats](formatconversion.md) for common re-encode scenarios such as PNG to JPEG or JPEG to WebP.
- [Strip Metadata](stripmetadata.md) for removing EXIF, ICC, IPTC, XMP, and related metadata before export.
- [Read Image Info Without Decoding](identify.md) for dimensions, frame count, pixel info, and format detection without a full decode.

## How to Adapt a Recipe

- Use `Identify(...)` before decoding when routing decisions only need dimensions, metadata, or format detection.
- Use `Mutate(...)` when changing an existing image and `Clone(...)` when the original image must be preserved.
- Choose encoder options deliberately when file size, quality, metadata retention, or color profile behavior matters.
- Keep stream ownership clear: load from streams that stay readable for the load call, then save to streams you control.

## Related Topics

- [Loading, Identifying, and Saving](loadingandsaving.md)
- [Working with Metadata](metadata.md)
- [Image Formats](imageformats.md)
- [Processing Images](processing.md)
