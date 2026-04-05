# Color and Effects

ImageSharp includes a wide range of processors for tonal adjustment, color transforms, and simple stylistic effects. Common entry points include `Grayscale()`, `Sepia()`, `Brightness()`, `Contrast()`, `Hue()`, `Saturate()`, and `Opacity()`. Under the hood, many of these effects are expressed as a [`ColorMatrix`](xref:SixLabors.ImageSharp.ColorMatrix) and applied with [`Filter()`](xref:SixLabors.ImageSharp.Processing.FilterExtensions.Filter*).

## Convert to Grayscale

Use `Grayscale()` to remove color information:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x.Grayscale());
```

ImageSharp also supports [`GrayscaleMode`](xref:SixLabors.ImageSharp.Processing.GrayscaleMode) when you need a specific conversion mode.

## Apply a Sepia Tone

Use `Sepia()` for a classic warm-tone effect:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x.Sepia());
```

## Adjust Brightness and Contrast

Use `Brightness()` and `Contrast()` to tune exposure and punch:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x
    .Brightness(1.1F)
    .Contrast(1.2F));
```

Values greater than `1` increase the effect. Values less than `1` reduce it.

## Shift Hue and Saturation

Use `Hue()` and `Saturate()` when you want to push color balance or intensity:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x
    .Hue(30)
    .Saturate(1.25F));
```

## Adjust Opacity

Use `Opacity()` to reduce alpha values across the image:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.png");

image.Mutate(x => x.Opacity(0.5F));
```

This is most useful when working with images that already include transparency.

## Use ColorMatrix for Custom Filters

[`ColorMatrix`](xref:SixLabors.ImageSharp.ColorMatrix) is the low-level type for custom channel transforms. It is a 5x4 matrix over the color and alpha channels, and [`Filter()`](xref:SixLabors.ImageSharp.Processing.FilterExtensions.Filter*) applies that matrix to the image.

That makes `ColorMatrix` the right tool when the built-in processors are close to what you need but not quite exact. The diagonal fields such as `M11`, `M22`, `M33`, and `M44` scale channels, while the last-row fields such as `M51`, `M52`, and `M53` add channel bias.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

ColorMatrix warmTone = new()
{
    M11 = 1.08F,
    M22 = 1.00F,
    M33 = 0.92F,
    M44 = 1F,
    M51 = 0.02F
};

image.Mutate(x => x.Filter(warmTone));
```

## Reuse Known Filter Matrices

If you want matrix-based control without building every matrix by hand, use [`KnownFilterMatrices`](xref:SixLabors.ImageSharp.Processing.KnownFilterMatrices). The built-in brightness, contrast, grayscale, hue, saturation, opacity, sepia, and preset camera-look filters all come from this API surface.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

ColorMatrix matrix =
    KnownFilterMatrices.CreateHueFilter(20F)
    * KnownFilterMatrices.CreateSaturateFilter(1.15F);

image.Mutate(x => x.Filter(matrix));
```

You can also use the predefined matrices directly for stylized looks such as [`KodachromeFilter`](xref:SixLabors.ImageSharp.Processing.KnownFilterMatrices.KodachromeFilter) and [`PolaroidFilter`](xref:SixLabors.ImageSharp.Processing.KnownFilterMatrices.PolaroidFilter).

## Chain Effects in a Single Pipeline

These processors are designed to compose cleanly:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x
    .AutoOrient()
    .Resize(800, 800)
    .Brightness(1.05F)
    .Contrast(1.1F)
    .Saturate(1.15F));
```

As with other processors, order matters when combining effects.

## Related Topics

- [Processing Images](processing.md)
- [Rotate, Flip, and Auto-Orient](orientation.md)
- [Crop, Pad, and Canvas](cropandcanvas.md)
