# Pixel Formats

[`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1) is generic because the in-memory pixel type is part of the image contract. An [`Image<Rgba32>`](xref:SixLabors.ImageSharp.Image`1) and an [`Image<L8>`](xref:SixLabors.ImageSharp.Image`1) can represent the same picture, but they differ in channel layout, precision, memory usage, and what direct pixel access means for your code.

Image memory is usually treated as discontiguous, even though smaller images may fit in a single backing buffer. See [Memory Management](memorymanagement.md) for more detail on how ImageSharp stores large images efficiently.

For multi-frame images, the individual bitmaps live in `image.Frames` as [`ImageFrame<TPixel>`](xref:SixLabors.ImageSharp.ImageFrame`1) instances.

## What Counts as a Pixel Format

A pixel format in ImageSharp is not just any color-related struct. To be used as `TPixel`, a type must implement [`IPixel<TSelf>`](xref:SixLabors.ImageSharp.PixelFormats.IPixel`1).

That contract includes conversion members such as:

- [`ToRgba32()`](xref:SixLabors.ImageSharp.PixelFormats.IPixel.ToRgba32)
- [`ToScaledVector4()`](xref:SixLabors.ImageSharp.PixelFormats.IPixel.ToScaledVector4)
- [`ToVector4()`](xref:SixLabors.ImageSharp.PixelFormats.IPixel.ToVector4)
- `FromScaledVector4(...)`
- `FromVector4(...)`
- conversions to and from canonical pixel types such as [`Rgba32`](xref:SixLabors.ImageSharp.PixelFormats.Rgba32), [`Rgb24`](xref:SixLabors.ImageSharp.PixelFormats.Rgb24), [`Bgra32`](xref:SixLabors.ImageSharp.PixelFormats.Bgra32), [`L8`](xref:SixLabors.ImageSharp.PixelFormats.L8), and [`Rgba64`](xref:SixLabors.ImageSharp.PixelFormats.Rgba64)

This is what keeps the image processing pipeline practical. Many operations and batched conversion paths assume pixels can move efficiently through RGBA-oriented [`Vector4`](xref:System.Numerics.Vector4) representations, and some optimized paths are specifically designed for [`Rgba32`](xref:SixLabors.ImageSharp.PixelFormats.Rgba32)-compatible pixel types where `ToVector4()` and `FromVector4(...)` are not expensive.

## Pixel Formats Are Not Color Profile Types

This is separate from the color-profile conversion APIs described in [Color Profiles and Color Conversion](colorprofiles.md).

Types such as [`Rgb`](xref:SixLabors.ImageSharp.ColorProfiles.Rgb), [`Cmyk`](xref:SixLabors.ImageSharp.ColorProfiles.Cmyk), [`Hsl`](xref:SixLabors.ImageSharp.ColorProfiles.Hsl), [`YCbCr`](xref:SixLabors.ImageSharp.ColorProfiles.YCbCr), [`CieLab`](xref:SixLabors.ImageSharp.ColorProfiles.CieLab), and [`CieXyz`](xref:SixLabors.ImageSharp.ColorProfiles.CieXyz) are color value types used by [`ColorProfileConverter`](xref:SixLabors.ImageSharp.ColorProfiles.ColorProfileConverter). They are not `TPixel` implementations for [`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1).

That means ImageSharp can convert color values between spaces like RGB, CMYK, Lab, and XYZ without treating those color models as general-purpose in-memory image storage formats. ImageSharp pixel formats are intentionally limited to types that fit the RGBA-oriented processing pipeline without expensive per-pixel translation on every operation.

## Choosing Pixel Formats

Choose a `TPixel` based on the kind of in-memory work you need to do:

- Use [`Rgba32`](xref:SixLabors.ImageSharp.PixelFormats.Rgba32) as the general-purpose default.
- Use lower-memory formats such as [`Rgb24`](xref:SixLabors.ImageSharp.PixelFormats.Rgb24) or [`L8`](xref:SixLabors.ImageSharp.PixelFormats.L8) when you know you do not need the extra channels or precision.
- Use higher-precision formats such as [`Rgb48`](xref:SixLabors.ImageSharp.PixelFormats.Rgb48), [`Rgba64`](xref:SixLabors.ImageSharp.PixelFormats.Rgba64), or [`RgbaVector`](xref:SixLabors.ImageSharp.PixelFormats.RgbaVector) when your pipeline benefits from more precision.

If you want to inspect pixel characteristics before a full decode, [`ImageInfo.PixelType`](xref:SixLabors.ImageSharp.ImageInfo.PixelType) exposes [`PixelTypeInfo`](xref:SixLabors.ImageSharp.PixelFormats.PixelTypeInfo). See [Read Image Info Without Decoding](identify.md) for more on that workflow.

## Defining Custom Pixel Formats

You can define a custom pixel format by creating a struct that implements [`IPixel<TSelf>`](xref:SixLabors.ImageSharp.PixelFormats.IPixel`1) and using it as the generic argument for [`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1).

Baseline batched conversion primitives are provided by [`PixelOperations<TPixel>`](xref:SixLabors.ImageSharp.PixelFormats.PixelOperations`1), and you can override those implementations if you have a more efficient specialization.

In practice, custom `TPixel` types should still fit the same RGBA-compatible conversion model as the built-in formats. Many of the packed and vector-style pixel types are deliberately in the same family as graphics-oriented packed color representations, and [`IPackedVector<TPacked>`](xref:SixLabors.ImageSharp.PixelFormats.IPackedVector`1) follows the same packed-value shape used by MonoGame and XNA types, which allows signature compatibility with them.

## Single-Bit Monochrome Pixels

ImageSharp does not currently support sub-byte `TPixel` formats such as a true 1-bit pixel type. That trade-off keeps the processing model and API surface much simpler, and it avoids paying a heavy CPU cost across the rest of the pipeline for a niche storage optimization.
