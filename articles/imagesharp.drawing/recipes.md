# Recipes

These pages are the quick-start side of the ImageSharp.Drawing docs. They focus on practical drawing tasks that combine canvas commands, brushes, pens, images, text, clipping, and processors.

Each recipe is intentionally complete enough to show the shape of a real workflow: create or load an image, set up reusable drawing objects outside the canvas callback, record the drawing commands, then save the result. After using a recipe, follow the related conceptual pages to understand the canvas state, lifetime, and composition behavior behind it.

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

## Related Topics

- [Canvas Drawing](canvas.md)
- [Brushes and Pens](brushesandpens.md)
- [Clipping, Regions, and Layers](clippingregionslayers.md)
- [Images, Masks, and Processing](imagesandprocessing.md)
- [Drawing Text](text.md)
