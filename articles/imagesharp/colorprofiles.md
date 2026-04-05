# Color Profiles and Color Conversion

Color management can feel intimidating at first because there are really two related topics hiding under one name: the profiles attached to image files, and the value-level color conversions you may apply in your own code. This page separates those concerns so it is easier to decide when you need metadata preservation, when you need actual color conversion, and when you need both.

ImageSharp exposes color management in two different layers:

- Embedded color metadata on decoded images, such as [`IccProfile`](xref:SixLabors.ImageSharp.Metadata.Profiles.Icc.IccProfile) and [`CicpProfile`](xref:SixLabors.ImageSharp.Metadata.Profiles.Cicp.CicpProfile).
- Value-level conversion APIs in [`SixLabors.ImageSharp.ColorProfiles`](xref:SixLabors.ImageSharp.ColorProfiles).

Those layers are related, but they are not the same thing. Preserving an embedded ICC profile does not automatically mean pixels were converted, and converting pixels does not automatically mean every output format can store the same profile metadata.

## Inspect Embedded Color Metadata

Embedded color metadata is available through [`ImageMetadata`](xref:SixLabors.ImageSharp.Metadata.ImageMetadata):

```csharp
using SixLabors.ImageSharp;

using Image image = Image.Load("input.jpg");

if (image.Metadata.IccProfile is not null)
{
    Console.WriteLine(image.Metadata.IccProfile.Header.ProfileConnectionSpace);
    Console.WriteLine(image.Metadata.IccProfile.Header.RenderingIntent);
}

if (image.Metadata.CicpProfile is not null)
{
    Console.WriteLine(image.Metadata.CicpProfile.ColorPrimaries);
    Console.WriteLine(image.Metadata.CicpProfile.TransferCharacteristics);
    Console.WriteLine(image.Metadata.CicpProfile.MatrixCoefficients);
    Console.WriteLine(image.Metadata.CicpProfile.FullRange);
}
```

[`IccProfile`](xref:SixLabors.ImageSharp.Metadata.Profiles.Icc.IccProfile) is the richer general-purpose color profile mechanism. [`CicpProfile`](xref:SixLabors.ImageSharp.Metadata.Profiles.Cicp.CicpProfile) carries standardized color signaling values such as primaries, transfer characteristics, matrix coefficients, and range information.

## Control ICC Handling During Decode

By default, [`DecoderOptions`](xref:SixLabors.ImageSharp.Formats.DecoderOptions) preserves embedded ICC profiles in metadata and does not transform the decoded pixels.

If you need different behavior, use [`DecoderOptions.ColorProfileHandling`](xref:SixLabors.ImageSharp.Formats.DecoderOptions.ColorProfileHandling):

- [`Preserve`](xref:SixLabors.ImageSharp.Formats.ColorProfileHandling.Preserve) keeps embedded ICC profiles intact.
- [`Compact`](xref:SixLabors.ImageSharp.Formats.ColorProfileHandling.Compact) removes canonical sRGB ICC profiles without changing the pixels.
- [`Convert`](xref:SixLabors.ImageSharp.Formats.ColorProfileHandling.Convert) converts decoded pixels to sRGB v4 and removes the original ICC profile.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;

DecoderOptions options = new()
{
    ColorProfileHandling = ColorProfileHandling.Convert
};

using Image image = Image.Load(options, "input-with-icc.jpg");
```

This is useful when you want a decode pipeline that normalizes images into a predictable sRGB output space up front.

## Color Profile Values Are Not `TPixel` Formats

The value types used by [`ColorProfileConverter`](xref:SixLabors.ImageSharp.ColorProfiles.ColorProfileConverter) are not the same thing as ImageSharp pixel formats.

Types such as [`Rgb`](xref:SixLabors.ImageSharp.ColorProfiles.Rgb), [`Cmyk`](xref:SixLabors.ImageSharp.ColorProfiles.Cmyk), [`Hsl`](xref:SixLabors.ImageSharp.ColorProfiles.Hsl), [`YCbCr`](xref:SixLabors.ImageSharp.ColorProfiles.YCbCr), [`CieLab`](xref:SixLabors.ImageSharp.ColorProfiles.CieLab), and [`CieXyz`](xref:SixLabors.ImageSharp.ColorProfiles.CieXyz) are value types used for color-space conversion. They participate in the [`ColorProfileConverter`](xref:SixLabors.ImageSharp.ColorProfiles.ColorProfileConverter) pipeline, but they are not [`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1) storage formats and do not implement [`IPixel<TSelf>`](xref:SixLabors.ImageSharp.PixelFormats.IPixel`1).

That distinction matters because ImageSharp image processing is built around pixel formats that can move efficiently through RGBA-oriented [`Vector4`](xref:System.Numerics.Vector4) conversion paths. Color profile types model color spaces and profile connection spaces instead.

## Convert Between Working Spaces

[`ColorProfileConverter`](xref:SixLabors.ImageSharp.ColorProfiles.ColorProfileConverter) converts color values and spans between supported profile types. For RGB-to-RGB conversions, the working spaces come from [`ColorConversionOptions`](xref:SixLabors.ImageSharp.ColorProfiles.ColorConversionOptions):

```csharp
using SixLabors.ImageSharp.ColorProfiles;

ColorProfileConverter converter = new(new ColorConversionOptions
{
    SourceRgbWorkingSpace = KnownRgbWorkingSpaces.SRgb,
    TargetRgbWorkingSpace = KnownRgbWorkingSpaces.AdobeRgb1998
});

Rgb source = new(0.25F, 0.5F, 0.75F);
Rgb converted = converter.Convert<Rgb, Rgb>(source);
```

The source and target value types are both [`Rgb`](xref:SixLabors.ImageSharp.ColorProfiles.Rgb) here, but the conversion still changes because the working-space definitions are different. This is value-level color conversion, not a change to the in-memory `TPixel` type of an [`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1).

## Choose Working Spaces Explicitly

[`KnownRgbWorkingSpaces`](xref:SixLabors.ImageSharp.ColorProfiles.KnownRgbWorkingSpaces) exposes the built-in RGB working spaces, including:

- [`SRgb`](xref:SixLabors.ImageSharp.ColorProfiles.KnownRgbWorkingSpaces.SRgb)
- [`Rec709`](xref:SixLabors.ImageSharp.ColorProfiles.KnownRgbWorkingSpaces.Rec709)
- [`Rec2020`](xref:SixLabors.ImageSharp.ColorProfiles.KnownRgbWorkingSpaces.Rec2020)
- [`AdobeRgb1998`](xref:SixLabors.ImageSharp.ColorProfiles.KnownRgbWorkingSpaces.AdobeRgb1998)
- [`ProPhotoRgb`](xref:SixLabors.ImageSharp.ColorProfiles.KnownRgbWorkingSpaces.ProPhotoRgb)
- [`WideGamutRgb`](xref:SixLabors.ImageSharp.ColorProfiles.KnownRgbWorkingSpaces.WideGamutRgb)

Choose the working spaces explicitly when you are doing color conversion outside the normal decode pipeline and need to be clear about the source and destination assumptions.

## Use ICC Profiles for Explicit Conversion

If you have actual ICC profiles for the source and destination, set [`ColorConversionOptions.SourceIccProfile`](xref:SixLabors.ImageSharp.ColorProfiles.ColorConversionOptions.SourceIccProfile) and [`ColorConversionOptions.TargetIccProfile`](xref:SixLabors.ImageSharp.ColorProfiles.ColorConversionOptions.TargetIccProfile). The same [`ColorProfileConverter`](xref:SixLabors.ImageSharp.ColorProfiles.ColorProfileConverter) API will then use the ICC-based conversion path instead of only the working-space defaults.

This is the right choice when the embedded or device-specific ICC data matters more than a generic named working space.

## Advanced Conversion Options

[`ColorConversionOptions`](xref:SixLabors.ImageSharp.ColorProfiles.ColorConversionOptions) also lets you tune lower-level conversion details:

- [`SourceWhitePoint`](xref:SixLabors.ImageSharp.ColorProfiles.ColorConversionOptions.SourceWhitePoint) and [`TargetWhitePoint`](xref:SixLabors.ImageSharp.ColorProfiles.ColorConversionOptions.TargetWhitePoint)
- [`AdaptationMatrix`](xref:SixLabors.ImageSharp.ColorProfiles.ColorConversionOptions.AdaptationMatrix), which defaults to [`KnownChromaticAdaptationMatrices.Bradford`](xref:SixLabors.ImageSharp.ColorProfiles.KnownChromaticAdaptationMatrices.Bradford)
- [`YCbCrTransform`](xref:SixLabors.ImageSharp.ColorProfiles.ColorConversionOptions.YCbCrTransform), which defaults to [`KnownYCbCrMatrices.BT601`](xref:SixLabors.ImageSharp.ColorProfiles.KnownYCbCrMatrices.BT601)

Most applications do not need to override those defaults, but they are available when you need tighter control over conversion behavior.

## Practical Guidance

- Preserve embedded ICC metadata when you need round-tripping or want the original profile to stay attached to the image.
- Use decode-time `ColorProfileHandling.Convert` when you want pixels normalized to sRGB as soon as the image is loaded.
- Use `Compact` when you want to remove redundant canonical sRGB ICC profiles without changing pixel values.
- Do not confuse metadata preservation with pixel conversion. They solve different problems.
- Do not confuse color profile value types with ImageSharp pixel formats. `ColorProfileConverter` works on color-space values, while `Image<TPixel>` works with `IPixel<TPixel>` storage types.

## Related Topics

- [Working with Metadata](metadata.md)
- [Loading, Identifying, and Saving](loadingandsaving.md)
- [Convert Between Formats](formatconversion.md)
- [Pixel Formats](pixelformats.md)
