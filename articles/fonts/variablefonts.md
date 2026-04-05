# Variable Fonts

Variable fonts expose one or more design axes, such as weight, width, slant, or optical size, from a single font file. Fonts models those axes with `FontVariation`.

### Create a variable-font instance

Use `FontFamily.CreateFont(...)` with one or more `FontVariation` values.

```csharp
using SixLabors.Fonts;

FontCollection collection = new();
FontFamily family = collection.Add("fonts/RobotoFlex.ttf");

Font font = family.CreateFont(
    16,
    new FontVariation(KnownVariationAxes.Weight, 700),
    new FontVariation(KnownVariationAxes.Width, 85),
    new FontVariation(KnownVariationAxes.OpticalSize, 16));
```

The tag must be exactly four characters. Common registered axis tags are available in `KnownVariationAxes`, but custom axes can also be addressed directly.

### Use a prototype font

If you already have a base `Font`, you can derive a new instance from it.

```csharp
using SixLabors.Fonts;

FontCollection collection = new();
FontFamily family = collection.Add("fonts/RobotoFlex.ttf");

Font baseFont = family.CreateFont(16);
Font bolderFont = new(
    baseFont,
    new FontVariation(KnownVariationAxes.Weight, 700));
```

This is useful when you want to keep the same family, size, and requested style while changing only the variation coordinates.

### Inspect supported axes

You can query the variable axes exposed by the current font through `FontMetrics.TryGetVariationAxes(...)`.

```csharp
using System;
using SixLabors.Fonts;
using SixLabors.Fonts.Tables.AdvancedTypographic.Variations;

FontCollection collection = new();
FontFamily family = collection.Add("fonts/RobotoFlex.ttf");
Font font = family.CreateFont(16);

if (font.FontMetrics.TryGetVariationAxes(out VariationAxis[] axes))
{
    foreach (VariationAxis axis in axes)
    {
        Console.WriteLine($"{axis.Tag}: {axis.Min}..{axis.Max} (default {axis.Default})");
    }
}
```

Each `VariationAxis` exposes:

- `Name`
- `Tag`
- `Min`
- `Max`
- `Default`

That makes it possible to build UI controls or configuration validation based on the actual font rather than on hard-coded assumptions.

### Registered and custom axes

`KnownVariationAxes` includes the registered tags most users expect:

- `Weight` (`wght`)
- `Width` (`wdth`)
- `OpticalSize` (`opsz`)
- `Italic` (`ital`)
- `Slant` (`slnt`)

Fonts also supports arbitrary four-character axis tags:

```csharp
using SixLabors.Fonts;

FontCollection collection = new();
FontFamily family = collection.Add("fonts/SomeVariableFont.ttf");

Font font = family.CreateFont(
    16,
    new FontVariation("GRAD", 50),
    new FontVariation("XTRA", 420));
```

### How values behave

`FontVariation` follows CSS `font-variation-settings` semantics. Variation values are clamped to the axis range defined by the font.

That means:

- valid tags must be four characters long
- out-of-range values are constrained by the font
- different fonts can expose different axis sets and ranges

### Non-variable fonts

Applying `FontVariation` values to a non-variable font is harmless but has no effect. If you need to know whether a font is actually variable, check `TryGetVariationAxes(...)` before building variation-driven UI or configuration.

### When to use variable fonts

Variable fonts are especially useful when you want to:

- tune weight or width continuously instead of switching discrete files
- match optical size to the rendered point size
- reduce the number of separate font files you need to ship
- keep a single family while exploring many design-space instances

If you run into unexpected results, see [Troubleshooting](troubleshooting.md).
