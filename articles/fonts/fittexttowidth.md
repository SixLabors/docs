# Fit Text to a Target Width

This recipe is useful when you need a heading, label, or short line of text to fit inside a fixed width.

For single-line text, the usual pattern is:

1. start with a candidate font size
2. measure with `TextMeasurer.MeasureAdvance(...)`
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

>[!NOTE]
>This example is intentionally naive. It remeasures from scratch on each iteration to keep the recipe easy to follow. Production layout engines would usually cache measurements, font instances, or intermediate fit results instead of doing a full linear probe every time.

See [Measuring Text](measuringtext.md) and [Text Layout and Options](textlayout.md) for the fuller discussion.
