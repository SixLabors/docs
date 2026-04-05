# Custom Rendering

>[!NOTE]
>If you want to draw text onto images, [ImageSharp.Drawing](../imagesharp.drawing/index.md) already provides the rendering layer for you. This page is for cases where you want to render glyphs to your own surface or extract geometry for another system.

Custom rendering in Fonts is built around `IGlyphRenderer`. `TextRenderer.RenderTextTo(...)` performs layout and shaping, then sends the result to your renderer as glyphs, layers, figures, and path commands.

### When to use it

Custom rendering is useful when you want to:

- draw text into a game engine or UI toolkit
- export outlines to SVG, PDF, or another vector format
- capture glyph geometry for hit testing or diagnostics
- consume color-font layers and paints yourself

### Rendering flow

The callbacks are delivered in this order:

1. `BeginText(...)`
2. `BeginGlyph(...)`
3. `BeginLayer(...)`
4. `BeginFigure()`, `MoveTo(...)`, `LineTo(...)`, `QuadraticBezierTo(...)`, `CubicBezierTo(...)`, `ArcTo(...)`, `EndFigure()`
5. `EndLayer()`
6. `EndGlyph()`
7. `SetDecoration(...)` for any decorations requested by `EnabledDecorations()`
8. `EndText()`

`BeginGlyph(...)` receives `GlyphRendererParameters`, which identify the glyph instance being rendered, including the glyph ID, the glyph's `CodePoint` value, font style, point size, DPI, layout mode, and active `TextRun`. Return `false` from `BeginGlyph(...)` if you want to skip rendering that glyph.

### A minimal renderer

```csharp
using System.Collections.Generic;
using System.Numerics;
using SixLabors.Fonts;
using SixLabors.Fonts.Rendering;

public sealed class RecordingGlyphRenderer : IGlyphRenderer
{
    public List<Vector2> Points { get; } = new();

    public void BeginText(in FontRectangle bounds)
    {
    }

    public void EndText()
    {
    }

    public bool BeginGlyph(in FontRectangle bounds, in GlyphRendererParameters parameters) => true;

    public void EndGlyph()
    {
    }

    public void BeginLayer(Paint? paint, FillRule fillRule, ClipQuad? clipBounds)
    {
    }

    public void EndLayer()
    {
    }

    public void BeginFigure()
    {
    }

    public void MoveTo(Vector2 point) => this.Points.Add(point);

    public void LineTo(Vector2 point) => this.Points.Add(point);

    public void QuadraticBezierTo(Vector2 secondControlPoint, Vector2 point)
    {
        this.Points.Add(secondControlPoint);
        this.Points.Add(point);
    }

    public void CubicBezierTo(Vector2 secondControlPoint, Vector2 thirdControlPoint, Vector2 point)
    {
        this.Points.Add(secondControlPoint);
        this.Points.Add(thirdControlPoint);
        this.Points.Add(point);
    }

    public void ArcTo(float radiusX, float radiusY, float rotation, bool largeArc, bool sweep, Vector2 point)
        => this.Points.Add(point);

    public void EndFigure()
    {
    }

    public TextDecorations EnabledDecorations() => TextDecorations.None;

    public void SetDecoration(TextDecorations textDecorations, Vector2 start, Vector2 end, float thickness)
    {
    }
}
```

Render text to that surface with `TextRenderer`.

```csharp
using SixLabors.Fonts;
using SixLabors.Fonts.Rendering;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    ColorFontSupport = ColorFontSupport.ColrV1 | ColorFontSupport.Svg
};

RecordingGlyphRenderer renderer = new();
TextRenderer.RenderTextTo(renderer, "Hello world", options);
```

Replace `"Segoe UI"` with any installed family that exists on your machine.

### Layers, paints, and color fonts

`BeginLayer(...)` is where Fonts communicates how the current glyph layer should be filled:

- `paint` may be `null` for outline-only content
- `SolidPaint` represents a single color
- `LinearGradientPaint`, `RadialGradientPaint`, and `SweepGradientPaint` are used for richer color-font layers
- `fillRule` tells you how the path should be filled
- `clipBounds` provides an optional clip quad for the layer

If your renderer only supports monochrome output, you can ignore `paint` and render every layer with your own brush. If you want color-font output, honor both `ColorFontSupport` in `TextOptions` and the `Paint` information delivered to `BeginLayer(...)`.

See [Color Fonts](colorfonts.md) for a fuller guide to `ColorFontSupport`, painted glyphs, and the different color-font technologies that Fonts can surface.

### Decorations

Decorations are opt-in. Return the decorations you care about from `EnabledDecorations()`, and Fonts will call `SetDecoration(...)` after the glyph geometry has been emitted.

```csharp
public TextDecorations EnabledDecorations()
    => TextDecorations.Underline | TextDecorations.Strikeout;
```

This makes it possible to render underline, overline, or strikeout using the same backend as the glyph outlines.
