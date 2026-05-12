# Recipes

These pages are the quick-start side of the ImageSharp.Drawing docs. They focus on practical drawing tasks that combine canvas commands, brushes, pens, images, text, clipping, and processors.

Each recipe is intentionally complete enough to show the shape of a real workflow: create or load an image, set up reusable drawing objects outside the canvas callback, record the drawing commands, then save the result. After using a recipe, follow the related conceptual pages to understand the canvas state, lifetime, and composition behavior behind it.

Drawing recipes are easiest to adapt when you keep three things separate: geometry, styling, and canvas state. Geometry decides where drawing can happen. Brushes, pens, and text options decide what is drawn. Canvas state decides which later commands are transformed, clipped, layered, or processed.

When adapting a recipe, change one of those layers at a time. If the layout is wrong, inspect the geometry and coordinate system before changing brushes. If the colors or texture are wrong, inspect the brush or pen before changing the shape. If later drawing is unexpectedly clipped, blurred, transformed, or transparent, inspect the canvas state scope around `Save(...)`, `Restore()`, `SaveLayer(...)`, and `Apply(...)`.

## Common Tasks

- [Add a Text Watermark](watermark.md) for anchored, semi-transparent text over an image.
- [Clip an Image to a Shape](clipimagetoshape.md) for avatar crops, badges, and shaped image fills.
- [Draw a Badge or Label](badge.md) for small generated graphics with shapes, strokes, and text.
- [Add Callouts and Annotations](annotations.md) for overlays, markers, outlines, and dashed guides.
- [Create a Soft Shadow](softshadow.md) for shadowed panels and grouped drawing effects.

## How to Adapt a Recipe

- Keep images, brushes, pens, fonts, and paths alive until the `Paint(...)` operation has completed.
- Create reusable geometry before the callback when more than one command needs the same shape.
- Use `Save(...)` and `Restore()` when a clip, transform, or drawing option should affect only part of the recipe.
- Put `Apply(...)` after the drawing commands that should be processed and before any crisp outlines or labels.
- Choose final output dimensions before positioning text, watermarks, badges, or annotations.
- Prefer `RichTextOptions` alignment and wrapping over manual string measurements.

## Practical Guidance

Drawing recipes become easier to maintain when the drawing model stays explicit. Keep source images, image brushes, fonts, paths, and retained backend scenes alive until canvas replay has completed. With `Paint(...)`, that means until the processing callback has finished; with manually-created canvases, it means until the root canvas is disposed.

Use state scopes to make composition readable. `Save(...)` is for clipping, transforms, and options that affect later commands. `SaveLayer(...)` is for a group that should blend back as one result. `Apply(...)` is a timeline barrier for ImageSharp processors, so place it after the pixels that should be processed and before crisp outlines or labels. Effects such as blur need expanded processing regions because the result spreads outside the original shape.

For text-heavy recipes, prefer layout options over guessed coordinates. Wrapping, horizontal alignment, vertical alignment, and text alignment keep examples robust when labels change, localize, or use fallback fonts.

## Related Topics

- [Canvas Drawing](canvas.md)
- [Brushes and Pens](brushesandpens.md)
- [Clipping, Regions, and Layers](clippingregionslayers.md)
- [Images, Masks, and Processing](imagesandprocessing.md)
- [Drawing Text](text.md)
