# Fit Text to a Target Width

Fitting text into a fixed width is one of those jobs that sounds simple until you decide how aggressively you want to shrink, wrap, or restyle it. This recipe covers the straightforward single-line measurement loop many apps start with.

For single-line text, the usual pattern is:

1. start with a candidate font size
2. measure with [`TextMeasurer.MeasureAdvance(...)`](xref:SixLabors.Fonts.TextMeasurer.MeasureAdvance*)
3. reduce the size until the width fits

```csharp
using SixLabors.Fonts;

const string text = "SixLabors.Fonts";
const float targetWidth = 240;

FontFamily family = SystemFonts.Get("Segoe UI");
float fontSize = 32;
FontRectangle bounds = default;

while (fontSize > 6)
{
    Font font = family.CreateFont(fontSize, FontStyle.Bold);
    TextOptions options = new(font)
    {
        WrappingLength = -1
    };

    bounds = TextMeasurer.MeasureAdvance(text, options);
    if (bounds.Width <= targetWidth)
    {
        break;
    }

    fontSize -= 1;
}

Font fittedFont = family.CreateFont(fontSize, FontStyle.Bold);
```

This is a simple and predictable approach for titles and short labels. If you need more control, you can reduce in larger steps first and then refine more precisely near the final size.

For multiline text, also set `WrappingLength` and measure with the same layout options you plan to render with.

The important rule is that fitting and rendering must use the same layout inputs. Font family, style, size, DPI, culture, wrapping length, fallback fonts, OpenType features, and text direction can all affect measured advance. If any of those differ between the fitting pass and the final drawing pass, the text can still overflow or wrap differently.

For interactive systems, consider a two-stage search: probe coarse sizes first, then refine around the best candidate. That keeps the recipe easy to adapt without turning every label fit into a long linear measurement loop.

>[!NOTE]
>This example is intentionally naive. It remeasures from scratch on each iteration to keep the recipe easy to follow. Production layout engines would usually cache measurements, font instances, or intermediate fit results instead of doing a full linear probe every time.

See [Measuring Text](measuringtext.md) and [Text Layout and Options](textlayout.md) for the fuller discussion.

### Practical guidance

- Fit with the same options you will use to render.
- Define a minimum readable size before starting the search.
- Use wrapping or truncation when shrinking would make the text unusable.
- Cache fit results when the same string, font family, and target width repeat often.
