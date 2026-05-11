# Recipes

These pages are the fast path through the ImageSharp docs. They skip most of the background explanation and focus on the handful of workflows people reach for over and over again, while linking back to the deeper guides when you need more context.

Use recipes when you already know the outcome you want: "make thumbnails", "convert this upload", "remove metadata", or "inspect before loading". Use the conceptual pages when you need to choose architecture, tune memory, handle untrusted input, or understand why a format behaves differently from another format.

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

## Practical Guidance

The recipe examples show the core workflow, but production image pipelines need policy around the workflow. For untrusted images, put limits around request size, decoded pixel budget, and frame count before you decode the full image. Use `Identify(...)` to make those decisions cheaply when possible, then load only the images your application is willing to process.

Normalize orientation before generating user-visible derivatives such as thumbnails, crops, or social cards. Decide what happens to metadata and color profiles before export: some workflows need privacy-focused stripping, while others need ICC conversion or preservation. Public output should usually use explicit encoders so format, quality, compression, and metadata behavior do not drift because of a file extension or default setting.

## Related Topics

- [Loading, Identifying, and Saving](loadingandsaving.md)
- [Working with Metadata](metadata.md)
- [Image Formats](imageformats.md)
- [Processing Images](processing.md)
