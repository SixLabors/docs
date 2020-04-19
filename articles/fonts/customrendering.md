# Custom Rendering

>[!WARNING]
>Fonts is still considered BETA quality and we still reserve the rights to change the API shapes. We are yet to priorities performance in our font loading and layout APIs.

>[!NOTE]
>ImageSharp.Drawing already implements the glyph rendering for you unless you are rendering on other platforms we would recommend using the version provided by that library.. This is a more advanced topic.

### Implementing a glyph renderer

The abstraction used by `Fonts` to allow implementing glyph rendering is the `IGlyphRenderer` and its brother `IColoredGlypheRenderer` (for colored emoji support).


```c#
 // `IColoredGlyphRenderer` implements `IGlyphRenderer` so if you don't want colored font support just implement `IGlyphRenderer`.
public class CustomGlyphRenderer : IColoredGlyphRenderer 
{

    /// <summary>
    /// Called before any glyphs have been rendered.
    /// </summary>
    /// <param name="bounds">The bounds the text will be rendered at and at whats size.</param>
    void IGlyphRenderer.BeginText(FontRectangle bounds)
    {
        // called before any thing else to provide access to the total required size to redner the text
    }

    /// <summary>
    /// Begins the glyph.
    /// </summary>
    /// <param name="bounds">The bounds the glyph will be rendered at and at what size.</param>
    /// <param name="paramaters">The set of paramaters that uniquely represents a version of a glyph in at particular font size, font family, font style and DPI.</param>
    /// <returns>Returns true if the glyph should be rendered othersie it returns false.</returns>
    bool IGlyphRenderer.BeginGlyph(FontRectangle bounds, GlyphRendererParameters paramaters)
    {
        // called before each glyph/glyph layer is rendered.
        // The paramaters can be used to detect the exact details
        // of the glyph so that duplicate glyphs could optionally 
        // be cached to reduce processing.

        // You can return false to skip all the figures within the glyph (if you return false EndGlyph will still be called)
    }

    /// <summary>
    /// Sets the color to use for the current glyph.
    /// </summary>
    /// <param name="color">The color to override the renders brush with.</param>
    void IColorGlyphRenderer.SetColor(GlyphColor color)
    {
        // from the IColorGlyphRenderer version, onlt called if the current glyph should override the forgound color of current glyph/layer        
    }

    /// <summary>
    /// Begins the figure.
    /// </summary>
    void IGlyphRenderer.BeginFigure()
    {
        // called at the start of the figure within the single glyph/layer
        // glyphs are rendered as a serise of arcs, lines and movements 
        // which together describe a complex shape.
    }

    /// <summary>
    /// Sets a new start point to draw lines from
    /// </summary>
    /// <param name="point">The point.</param>
    void IGlyphRenderer.MoveTo(Vector2 point)
    {
        // move current point to location marked by point without describing a line;
    }

    /// <summary>
    /// Draw a quadratic bezier curve connecting the previous point to <paramref name="point"/>.
    /// </summary>
    /// <param name="secondControlPoint">The second control point.</param>
    /// <param name="point">The point.</param>
    void IGlyphRenderer.QuadraticBezierTo(Vector2 secondControlPoint, Vector2 point)
    {
        // describes Quadratic Bezier curve from the 'current point' using the 
        // 'second control point' and final 'point' leaving the 'current point'
        // at 'point'
    }

    /// <summary>
    /// Draw a Cubics bezier curve connecting the previous point to <paramref name="point"/>.
    /// </summary>
    /// <param name="secondControlPoint">The second control point.</param>
    /// <param name="thirdControlPoint">The third control point.</param>
    /// <param name="point">The point.</param>
    void IGlyphRenderer.CubicBezierTo(Vector2 secondControlPoint, Vector2 thirdControlPoint, Vector2 point)
    {
        // describes Cubic Bezier curve from the 'current point' using the 
        // 'second control point', 'third control point' and final 'point' 
        // leaving the 'current point' at 'point'
    }

    /// <summary>
    /// Draw a straight line connecting the previous point to <paramref name="point"/>.
    /// </summary>
    /// <param name="point">The point.</param>
    void IGlyphRenderer.LineTo(Vector2 point)
    {
        // describes straight line from the 'current point' to the final 'point' 
        // leaving the 'current point' at 'point'
    }

    /// <summary>
    /// Ends the figure.
    /// </summary>
    void IGlyphRenderer.EndFigure()
    {
        // Called after the figure has completed denoting a straight line should 
        // be drawn from the current point to the first point
    }

    /// <summary>
    /// Ends the glyph.
    /// </summary>
    void IGlyphRenderer.EndGlyph()
    {
        // says the all figures have completed for the current glyph/layer.
        // NOTE this will be called even if BeginGlyph return false.
    }


    /// <summary>
    /// Called once all glyphs have completed rendering
    /// </summary>
    void IGlyphRenderer.EndText()
    {
        //once all glyphs/layers have been drawn this is called.
    }
}
```
