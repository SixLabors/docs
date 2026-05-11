# Recipes

These pages are the quick-start side of the Fonts docs. They are meant for the moment when you know roughly what you want to do and would rather start from a short working example than read the full conceptual guide first.

Each recipe focuses on one common decision: sizing text to fit, choosing fonts, inspecting font assets, enabling OpenType features, or checking glyph coverage before rendering. Use them as starting points, then follow the linked conceptual articles when you need to understand layout coordinates, Unicode behavior, fallback, shaping, or custom rendering in more detail.

Text recipes are especially sensitive to hidden inputs. The font file, culture, DPI, fallback list, OpenType features, wrapping length, and text direction are all part of the layout. If a recipe measures text and your application later renders with different options, the result can be wider, taller, or shaped differently.

- [Fit Text to a Target Width](fittexttowidth.md)
- [Inspect Font Files and Collections](inspectfontfiles.md)
- [List System Fonts and Resolve by Culture](listsystemfonts.md)
- [Use OpenType Features for Numbers and Fractions](useopentypefeatures.md)
- [Check Glyph Coverage Before Choosing Fallbacks](checkglyphcoverage.md)

## How to Adapt a Recipe

- Keep font loading separate from per-text measurement or rendering work when the same font is reused.
- Treat text indexes as grapheme-aware unless a page explicitly discusses code points or UTF-16 units.
- Use `TextOptions` for layout decisions such as origin, wrapping, alignment, DPI, culture, and fallback fonts.
- Use `TextBlock` when you need prepared layout, line inspection, hit testing, caret movement, or selection.

## Practical Guidance

Text output is only stable when the font assets and layout inputs are stable. If output must match across developer machines, CI, containers, and production servers, ship the required fonts and load them into a private `FontCollection` instead of relying on system fonts. Use the same `TextOptions` for measurement, hit testing, and rendering so the layout engine answers every question from the same contract.

Fallback and shaping should be tested with the actual content your product supports: localized strings, emoji sequences, RTL text, CJK text, combining marks, and OpenType features. Cache font collections and prepared text at boundaries where the font files and layout options are known not to change; stale layout state is worse than no cache because it can look correct for simple strings and fail on real content.

Use the conceptual guides when you need the bigger picture. Use these recipes when you want a practical starting point quickly.
