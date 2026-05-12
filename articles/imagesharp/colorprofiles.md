# Color Profiles and Color Conversion

Color management in ImageSharp has two related but separate parts:

- Embedded color metadata, such as [`IccProfile`](xref:SixLabors.ImageSharp.Metadata.Profiles.Icc.IccProfile) and [`CicpProfile`](xref:SixLabors.ImageSharp.Metadata.Profiles.Cicp.CicpProfile), which describes how encoded color values should be interpreted.
- Color conversion APIs in [`SixLabors.ImageSharp.ColorProfiles`](xref:SixLabors.ImageSharp.ColorProfiles), which convert color values between supported color spaces and profiles.

Preserving a profile is not the same thing as converting pixels. A profile can remain attached to an image as metadata without changing the decoded pixel values, and a conversion can change pixel values without preserving the original profile in the output file.

Most applications only need the first part: let ImageSharp decode the image and choose whether to preserve, compact, or convert embedded ICC profile data at the decode boundary. [`ColorProfileConverter`](xref:SixLabors.ImageSharp.ColorProfiles.ColorProfileConverter) is a lower-level API for code that is explicitly working with color values or custom color pipelines.

## What ICC Profiles Do

An ICC profile describes the color space of encoded image data. The same numeric pixel value can represent different visible colors depending on the profile attached to the file. A pixel value that looks correct as sRGB may look too saturated, too dull, or shifted if it is interpreted as Adobe RGB, ProPhoto RGB, a display profile, or a printer profile without conversion.

That means an ICC profile is not just descriptive trivia. It tells color-managed software how to interpret the numbers in the file and, when needed, how to convert those numbers into another color space while preserving the intended appearance.

There are two common outcomes:

- Preserve the profile and pixel values so another color-managed tool can interpret the image later.
- Convert the pixels into a known working space, usually sRGB, so the rest of your pipeline can treat loaded images consistently.

## What ImageSharp Does

By default, [`DecoderOptions`](xref:SixLabors.ImageSharp.Formats.DecoderOptions) preserves embedded ICC profiles in metadata and does not transform the decoded pixels.

Use [`DecoderOptions.ColorProfileHandling`](xref:SixLabors.ImageSharp.Formats.DecoderOptions.ColorProfileHandling) when your decode boundary needs a different policy:

- [`Preserve`](xref:SixLabors.ImageSharp.Formats.ColorProfileHandling.Preserve) leaves embedded ICC profiles intact.
- [`Compact`](xref:SixLabors.ImageSharp.Formats.ColorProfileHandling.Compact) removes embedded standard sRGB ICC profiles without transforming pixels.
- [`Convert`](xref:SixLabors.ImageSharp.Formats.ColorProfileHandling.Convert) transforms pixels from the embedded ICC profile to the sRGB v4 profile and removes the original profile.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;

DecoderOptions options = new()
{
    // Convert embedded ICC color data to sRGB during decode.
    ColorProfileHandling = ColorProfileHandling.Convert
};

using Image image = Image.Load(options, "input-with-icc.jpg");
```

`Convert` is useful when you want the rest of your pipeline to operate on normalized sRGB pixel values. `Preserve` is useful when the original profile should stay attached for round-tripping or later export. `Compact` is useful when you want to remove redundant standard sRGB profile data without changing pixel values.

## Inspect Embedded Color Metadata

Embedded color metadata is exposed through [`ImageMetadata`](xref:SixLabors.ImageSharp.Metadata.ImageMetadata):

```csharp
using SixLabors.ImageSharp;

using Image image = Image.Load("input.jpg");

// ICC and CICP are metadata profiles; reading them does not convert pixels.
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

[`IccProfile`](xref:SixLabors.ImageSharp.Metadata.Profiles.Icc.IccProfile) is the richer general-purpose profile format used by many image workflows. [`CicpProfile`](xref:SixLabors.ImageSharp.Metadata.Profiles.Cicp.CicpProfile) stores coding-independent color signaling values such as primaries, transfer characteristics, matrix coefficients, and range.

## Color Profile Types Are Not Pixel Formats

The value types used by [`ColorProfileConverter`](xref:SixLabors.ImageSharp.ColorProfiles.ColorProfileConverter) are not [`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1) storage formats.

Types such as [`Rgb`](xref:SixLabors.ImageSharp.ColorProfiles.Rgb), [`Cmyk`](xref:SixLabors.ImageSharp.ColorProfiles.Cmyk), [`Hsl`](xref:SixLabors.ImageSharp.ColorProfiles.Hsl), [`YCbCr`](xref:SixLabors.ImageSharp.ColorProfiles.YCbCr), [`CieLab`](xref:SixLabors.ImageSharp.ColorProfiles.CieLab), and [`CieXyz`](xref:SixLabors.ImageSharp.ColorProfiles.CieXyz) model color values for conversion. They are not general-purpose pixel formats and do not implement [`IPixel<TSelf>`](xref:SixLabors.ImageSharp.PixelFormats.IPixel`1).

That distinction matters because ImageSharp image processing is built around pixel formats that can move efficiently through RGBA-oriented [`Vector4`](xref:System.Numerics.Vector4) conversion paths. Color profile types model color spaces and profile connection spaces instead.

## Convert Color Values

Use [`ColorProfileConverter`](xref:SixLabors.ImageSharp.ColorProfiles.ColorProfileConverter) to convert individual color values or spans of values:

```csharp
using SixLabors.ImageSharp.ColorProfiles;

ColorProfileConverter converter = new();

Rgb rgb = new(0.25F, 0.5F, 0.75F);
CieLab lab = converter.Convert<Rgb, CieLab>(rgb);
```

The converter works with color-profile value types, not whole images. This is appropriate when your own code is calculating, sampling, comparing, or exporting color values directly.

## Convert Between RGB Working Spaces

RGB-to-RGB conversion can still change values when the source and destination working spaces are different. Set the working spaces through [`ColorConversionOptions`](xref:SixLabors.ImageSharp.ColorProfiles.ColorConversionOptions):

```csharp
using SixLabors.ImageSharp.ColorProfiles;

ColorProfileConverter converter = new(new ColorConversionOptions
{
    // The same Rgb value type can represent different RGB working spaces.
    SourceRgbWorkingSpace = KnownRgbWorkingSpaces.SRgb,
    TargetRgbWorkingSpace = KnownRgbWorkingSpaces.AdobeRgb1998
});

Rgb source = new(0.25F, 0.5F, 0.75F);
Rgb converted = converter.Convert<Rgb, Rgb>(source);
```

The source and target value types are both [`Rgb`](xref:SixLabors.ImageSharp.ColorProfiles.Rgb), but the working-space definitions are different. This is value-level color conversion, not a change to the in-memory `TPixel` type of an image.

[`KnownRgbWorkingSpaces`](xref:SixLabors.ImageSharp.ColorProfiles.KnownRgbWorkingSpaces) includes common built-in working spaces such as:

- [`SRgb`](xref:SixLabors.ImageSharp.ColorProfiles.KnownRgbWorkingSpaces.SRgb)
- [`Rec709`](xref:SixLabors.ImageSharp.ColorProfiles.KnownRgbWorkingSpaces.Rec709)
- [`Rec2020`](xref:SixLabors.ImageSharp.ColorProfiles.KnownRgbWorkingSpaces.Rec2020)
- [`AdobeRgb1998`](xref:SixLabors.ImageSharp.ColorProfiles.KnownRgbWorkingSpaces.AdobeRgb1998)
- [`ProPhotoRgb`](xref:SixLabors.ImageSharp.ColorProfiles.KnownRgbWorkingSpaces.ProPhotoRgb)
- [`WideGamutRgb`](xref:SixLabors.ImageSharp.ColorProfiles.KnownRgbWorkingSpaces.WideGamutRgb)

Choose the source and target working spaces explicitly when color values come from a known space outside the normal image decode path.

## Convert Using ICC Profiles

When you have actual source and destination ICC profiles, set [`SourceIccProfile`](xref:SixLabors.ImageSharp.ColorProfiles.ColorConversionOptions.SourceIccProfile) and [`TargetIccProfile`](xref:SixLabors.ImageSharp.ColorProfiles.ColorConversionOptions.TargetIccProfile):

```csharp
using System.IO;
using SixLabors.ImageSharp.ColorProfiles;
using SixLabors.ImageSharp.Metadata.Profiles.Icc;

IccProfile sourceProfile = new(File.ReadAllBytes("source.icc"));
IccProfile targetProfile = new(File.ReadAllBytes("target.icc"));

ColorProfileConverter converter = new(new ColorConversionOptions
{
    // Supplying both ICC profiles selects the ICC-based conversion path.
    SourceIccProfile = sourceProfile,
    TargetIccProfile = targetProfile
});

Rgb source = new(0.25F, 0.5F, 0.75F);
Rgb converted = converter.Convert<Rgb, Rgb>(source);
```

When both ICC profiles are supplied, the converter uses the ICC conversion path for supported source and destination color value types. Use this path when device-specific or embedded profile data matters more than a generic named working space.

## Advanced Conversion Options

[`ColorConversionOptions`](xref:SixLabors.ImageSharp.ColorProfiles.ColorConversionOptions) also exposes lower-level settings for specialized workflows:

- [`SourceWhitePoint`](xref:SixLabors.ImageSharp.ColorProfiles.ColorConversionOptions.SourceWhitePoint) and [`TargetWhitePoint`](xref:SixLabors.ImageSharp.ColorProfiles.ColorConversionOptions.TargetWhitePoint)
- [`AdaptationMatrix`](xref:SixLabors.ImageSharp.ColorProfiles.ColorConversionOptions.AdaptationMatrix), which defaults to [`KnownChromaticAdaptationMatrices.Bradford`](xref:SixLabors.ImageSharp.ColorProfiles.KnownChromaticAdaptationMatrices.Bradford)
- [`YCbCrTransform`](xref:SixLabors.ImageSharp.ColorProfiles.ColorConversionOptions.YCbCrTransform), which defaults to [`KnownYCbCrMatrices.BT601`](xref:SixLabors.ImageSharp.ColorProfiles.KnownYCbCrMatrices.BT601)

Most application code should leave these defaults alone. Change them only when your color pipeline has an explicit requirement for a different white point, chromatic adaptation matrix, or YCbCr transform.

## Practical Guidance

- Preserve embedded ICC metadata when the original profile should remain attached to the image.
- Use decode-time `ColorProfileHandling.Convert` when you want loaded images normalized to sRGB pixel values.
- Use `ColorProfileHandling.Compact` when you want to remove redundant standard sRGB profile data without changing pixels.
- Use `ColorProfileConverter` when you are converting color values in your own code rather than changing file metadata.
- Keep pixel format decisions separate from color profile decisions. `Image<Rgba32>` describes memory layout; ICC and CICP data describe color interpretation.

## Related Topics

- [Working with Metadata](metadata.md)
- [Loading, Identifying, and Saving](loadingandsaving.md)
- [Convert Between Formats](formatconversion.md)
- [Pixel Formats](pixelformats.md)
