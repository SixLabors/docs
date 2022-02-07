# Getting Started

>[!WARNING]
>Fonts is still considered BETA quality and we still reserve the rights to change the API shapes.

>[!NOTE]
>The official guide assumes intermediate level knowledge of C# and .NET. If you are totally new to .NET development, it might not be the best idea to jump right into a framework as your first step - grasp the basics then come back. Prior experience with other languages and frameworks helps, but is not required.

### Fonts

Fonts provides the core to your text layout and loading subsystems.

- `SixLabors.Fonts.FontCollection` is the root type you will configure and load up with all the TrueType/OpenType/Woff/Woff2 fonts. (Font loading is deemed expensive and should be done once and shared across multiple rasterizations)
- `SixLabors.Fonts.Font` is our currying type for passing information about your chosen font face.

### Loading Fonts

Fonts provides several options for loading fonts, you can load then from a streams or files, we also support loading collections out of `.ttc` files and well as single variants from individual `.ttf` files. We also support loading `.woff`, and `.woff2` files.

#### Minimal Example

```c#
using SixLabors.Fonts;

FontCollection collection = new();
FontFamily family = collection.Add("path/to/font.ttf");
Font font = family.CreateFont(12, FontStyle.Italic);

// "font" can now be used in calls to DrawText from our ImageSharp.Drawing library.

```

#### Expanded Example 

```c#
using SixLabors.Fonts;

FontCollection collection = new();
collection.Add("path/to/font.ttf");
collection.Add("path/to/font2.ttf");
collection.Add("path/to/emojiFont.ttf");
collection.AddCollection("path/to/font.ttc");

if(collection.TryFind("Font Name", out FontFamily family))
if(collection.TryFind("Emoji Font Name", out FontFamily emojiFamily))
{
    // family will not be null here
    Font font = family.CreateFont(12, FontStyle.Italic);

    // TextOptions provides comprehensive customization options support
    TextOptions options = new(font)
    {
        // Will be used if a particular code point doesn't exist in the font passed into the constructor. (e.g. emoji)
        FallbackFontFamilies  = new [] { emojiFamily }
    };

    FontRectangle rect = TextMeasurer.Measure("Text to measure", options);
}
```