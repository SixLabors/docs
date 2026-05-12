# Drawing Text

ImageSharp.Drawing exposes a high-performance text drawing API that is unusually rich for a 2D image library. It combines the text engine from SixLabors.Fonts with the canvas drawing model, so shaped text, fallback fonts, color fonts, bidirectional layout, wrapping, alignment, rich runs, filled glyphs, stroked glyphs, decorations, path text, and glyph geometry all flow through `DrawingCanvas.DrawText(...)`.

Use the [Fonts](../fonts/index.md) docs for font loading and text-layout details. This page focuses on placing that text onto an image.

At the simple end, text is one call. At the advanced end, the same model can draw a multilingual paragraph with per-run fonts, brushes, pens, decorations, and layout options, or turn glyphs into paths for clipping and compositing.

## Draw Simple Text

Simple text drawing still uses the full Fonts shaping pipeline. The text is shaped, positioned from `RichTextOptions.Origin`, and then painted through the same brush and pen model as other canvas drawing. Pass a brush to fill glyphs, a pen to outline glyphs, or both when the text needs a filled face and a stroked edge.

```csharp
using SixLabors.Fonts;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(640, 240, Color.White.ToPixel<Rgba32>());

Font font = SystemFonts.CreateFont("Arial", 46);
RichTextOptions options = new(font)
{
    Origin = new(48, 72)
};

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.DrawText(options, "Hello from ImageSharp.Drawing", Brushes.Solid(Color.Black), pen: null);
}));
```

Even in simple examples, treat `RichTextOptions` as part of the drawing contract. If you later measure the same string, use the same font, wrapping, alignment, culture, fallback, and feature settings so the measured layout matches the rendered pixels.

## Draw Rich Text

`RichTextOptions.TextRuns` lets one string carry multiple visual styles without manually splitting and positioning each span. Runs can change font, brush, pen, decorations, and other text features while the layout engine still wraps and aligns the text as one paragraph.

```csharp
using SixLabors.Fonts;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(760, 260, Color.White.ToPixel<Rgba32>());

Font body = SystemFonts.CreateFont("Arial", 34);
Font emphasis = SystemFonts.CreateFont("Arial", 40, FontStyle.Bold);
const string text = "Rich text can mix fill, outline, and decoration in one layout.";

RichTextOptions options = new(body)
{
    Origin = new(48, 48),
    WrappingLength = 664,
    LineSpacing = 1.15F,
    TextRuns =
    [
        new RichTextRun
        {
            Start = 0,
            End = 9,
            Font = emphasis,
            Brush = Brushes.Solid(Color.MidnightBlue),
            Pen = Pens.Solid(Color.Gold, 1.5F)
        },

        new RichTextRun
        {
            Start = 18,
            End = 22,
            Brush = Brushes.Solid(Color.DarkRed),
            TextDecorations = TextDecorations.Underline,
            UnderlinePen = Pens.Solid(Color.DarkRed, 2)
        },

        new RichTextRun
        {
            Start = 24,
            End = 31,
            Brush = Brushes.Solid(Color.DarkGreen),
            Pen = Pens.Solid(Color.LightGreen, 1)
        },

        new RichTextRun
        {
            Start = 37,
            End = 47,
            Brush = Brushes.Solid(Color.DarkGoldenrod),
            TextDecorations = TextDecorations.Overline,
            OverlinePen = Pens.Solid(Color.DarkGoldenrod, 2)
        }
    ]
};

image.Mutate(ctx => ctx.Paint(canvas =>
{

    // Runs style spans; DrawText still shapes, wraps, and aligns the paragraph as one layout.
    canvas.DrawText(options, text, Brushes.Solid(Color.Black), pen: null);
}));
```

Run indices are counted in grapheme clusters, not UTF-16 code units. `Start` is inclusive and `End` is exclusive, so each run covers the `[Start, End)` grapheme range. For plain ASCII those values match character positions; for emoji, combining marks, and complex scripts, count grapheme clusters as shown in the [Fonts Unicode docs](../fonts/unicode.md).

## Draw Prepared Text

Use [TextBlock](../fonts/textblock.md) when the same text will be measured, wrapped, inspected, or drawn more than once. [`TextBlock`](xref:SixLabors.Fonts.TextBlock) keeps the prepared text layout work in the Fonts layer, and [`DrawingCanvas.DrawText(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.DrawText*) places that prepared block onto the canvas.

```csharp
using SixLabors.Fonts;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(640, 260, Color.White.ToPixel<Rgba32>());

Font font = SystemFonts.CreateFont("Arial", 32);
RichTextOptions options = new(font)
{
    Origin = new(0, 0),
    HorizontalAlignment = HorizontalAlignment.Center,
    LineSpacing = 1.15F
};

TextBlock block = new("Prepared text can be measured and drawn with the same shaping.", options);
TextMetrics metrics = block.Measure(wrappingLength: 520);
Rectangle layoutBox = new(60, 48, 520, (int)MathF.Ceiling(metrics.Advance.Height + 24));

image.Mutate(ctx => ctx.Paint(canvas =>
{

    // TextBlock owns shaping and text options; DrawText supplies canvas placement and wrapping.
    canvas.Draw(Pens.Solid(Color.LightGray, 1), layoutBox);
    canvas.DrawText(block, new PointF(60, 60), 520, Brushes.Solid(Color.DarkSlateBlue), pen: null);
}));
```

For manual line flow, choose the [`TextBlock`](xref:SixLabors.Fonts.TextBlock) API based on the coordinate space you want to draw from:

- Use `TextBlock.GetLineLayouts(...)` when the text still behaves as one stacked block. Each returned `LineLayout` is positioned in block coordinates, including the cumulative advance of the lines before it, so it is ready to draw relative to the block origin.
- Use `TextBlock.EnumerateLineLayouts()` when each line is placed independently. Each `LineLayout` is line-local, as if it were the first line in the block, and the caller supplies the final canvas position or path when calling `DrawingCanvas.DrawText(...)`.

The line-local enumerator is the right fit for text that flows through different columns, separate frames, or different paths. See [Prepared Text with TextBlock](../fonts/textblock.md) for the Fonts-side coordinate model.

## Wrap and Align Text

[`RichTextOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.RichTextOptions) inherits the core Fonts text options and adds ImageSharp.Drawing-specific rich text behavior.

Wrapping and alignment happen before pixels are drawn. `WrappingLength` determines where line breaking can happen. `TextAlignment` aligns lines within the paragraph. `HorizontalAlignment` and `VerticalAlignment` position the laid-out paragraph relative to `Origin`. Keeping those roles separate avoids the common mistake of manually subtracting measured widths and then fighting wrapped or fallback text.

```csharp
using SixLabors.Fonts;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(640, 260, Color.White.ToPixel<Rgba32>());

Font font = SystemFonts.CreateFont("Arial", 34);
RichTextOptions options = new(font)
{
    Origin = new(48, 42),
    WrappingLength = 544,
    HorizontalAlignment = HorizontalAlignment.Center,
    LineSpacing = 1.15F
};

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.DrawText(
        options,
        "Wrapped text can be measured and rendered with the same options.",
        Brushes.Solid(Color.MidnightBlue),
        pen: null);
}));
```

## Center Text in a Region

Use `WrappingLength`, `HorizontalAlignment`, and `VerticalAlignment` when text should align within a known layout region. For centered alignment, `Origin` is the center anchor for the laid-out text, and `WrappingLength` sets the width used for line breaking.

```csharp
using SixLabors.Fonts;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(520, 220, Color.White.ToPixel<Rgba32>());

Font font = SystemFonts.CreateFont("Arial", 36);
Rectangle layoutBounds = new(40, 56, 440, 108);
PointF layoutCenter = new(
    layoutBounds.Left + (layoutBounds.Width / 2F),
    layoutBounds.Top + (layoutBounds.Height / 2F));

RichTextOptions options = new(font)
{
    Origin = layoutCenter,
    WrappingLength = layoutBounds.Width,
    HorizontalAlignment = HorizontalAlignment.Center,
    VerticalAlignment = VerticalAlignment.Center,
    TextAlignment = TextAlignment.Center
};

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Draw(Pens.Solid(Color.LightGray, 1), layoutBounds);

    // The origin is the center anchor because both horizontal and vertical alignment are centered.
    canvas.DrawLine(Pens.Dash(Color.Gray, 1), new PointF(layoutCenter.X, layoutBounds.Top), new PointF(layoutCenter.X, layoutBounds.Bottom));
    canvas.DrawLine(Pens.Dash(Color.Gray, 1), new PointF(layoutBounds.Left, layoutCenter.Y), new PointF(layoutBounds.Right, layoutCenter.Y));
    canvas.DrawText(options, "Centered by layout options", Brushes.Solid(Color.Black), pen: null);
}));
```

## Draw Text Along a Path

Text can also follow an [`IPath`](xref:SixLabors.ImageSharp.Drawing.IPath). In this mode the path acts as the text baseline, so path direction matters: reversing the path reverses the flow direction. Use open paths for natural baselines. Closed shapes can work, but they should be chosen deliberately because the baseline continues around the contour.

Path text is still shaped text. The font, runs, fallback, culture, and decoration options come from the text options; the path only changes where the shaped glyphs are placed.

```csharp
using SixLabors.Fonts;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(640, 260, Color.White.ToPixel<Rgba32>());

Font font = SystemFonts.CreateFont("Arial", 30);
RichTextOptions options = new(font)
{
    Origin = new(0, 0)
};

PathBuilder builder = new();
builder.AddCubicBezier(
    new(52, 168),
    new(186, 42),
    new(420, 44),
    new(588, 172));

IPath path = builder.Build();

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Draw(Pens.Dot(Color.LightGray, 2), path);
    canvas.DrawText(options, "Text can follow path geometry", path, Brushes.Solid(Color.DarkSlateBlue), pen: null);
}));
```

## Use Text as Geometry

Use `TextBuilder.GeneratePaths(...)` when the glyph outlines themselves should become drawing geometry. The returned paths can be filled, stroked, used as clips, or combined with image drawing.

Generating paths changes the problem from text layout to geometry. Once glyph outlines become paths, they can be clipped, filled with image brushes, stroked with pens, transformed, or combined with other paths. Use this when text is part of a graphic effect or mask. Use `DrawText(...)` when you simply want text rendered as text.

```csharp
using SixLabors.Fonts;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Drawing.Text;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> source = Image.Load<Rgba32>("photo.jpg");
using Image<Rgba32> image = new(640, 240, Color.White.ToPixel<Rgba32>());

RectangleF imageArea = new(0, 0, image.Width, image.Height);
Font font = SystemFonts.CreateFont("Arial", 104, FontStyle.Bold);
TextOptions glyphOptions = new(font)
{
    Origin = new(42, 150)
};

IPathCollection letters = TextBuilder.GeneratePaths("MASK", glyphOptions);
IPath[] glyphClips = [.. letters];
DrawingOptions clipOptions = new()
{
    ShapeOptions = new()
    {
        BooleanOperation = BooleanOperation.Intersection
    }
};

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.DarkSlateBlue));
    canvas.Save(clipOptions, glyphClips);

    // The generated glyph paths clip the photo to the visible letter shapes.
    canvas.DrawImage(source, source.Bounds, imageArea, KnownResamplers.Bicubic);
    canvas.Restore();

    canvas.Draw(Pens.Solid(Color.White, 2), letters);
}));
```

## Practical Guidance

Use `RichTextOptions` as the drawing contract for canvas text. If text is measured before it is drawn, the measurement and drawing passes should use the same font, origin model, wrapping length, alignment, culture, fallback, feature tags, and text runs. Otherwise the final pixels can differ from the measured result even when the string is identical.

Prefer the layout options over manual coordinate math. Centering text in a region is a layout problem: set the origin to the region anchor, specify wrapping, and use horizontal, vertical, and text alignment so the layout engine accounts for line height, wrapping, shaping, and fallback metrics. Manual width subtraction is fragile as soon as the string localizes, wraps, or uses a fallback face.

Style ranges and placeholders use grapheme-indexed `[start, end)` ranges. This matters for emoji, combining marks, complex scripts, and any text where one visible unit is not one UTF-16 `char`. Use `TextBlock` when the same shaped text needs to be measured, inspected, hit-tested, or rendered repeatedly. Use generated text paths when text becomes geometry for fills, clips, strokes, or masks.
