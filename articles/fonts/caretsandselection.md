# Selection and Bidi Drag

Once you can hit-test a point and place a caret, the next step is painting selection ranges. Fonts returns selection geometry as a list of rectangles in visual order so editor-style UIs can paint browser-shaped selections without reimplementing bidi or line-box rules.

For the underlying types — [`TextHit`](xref:SixLabors.Fonts.TextHit), [`CaretPosition`](xref:SixLabors.Fonts.CaretPosition), [`CaretPlacement`](xref:SixLabors.Fonts.CaretPlacement), and [`CaretMovement`](xref:SixLabors.Fonts.CaretMovement) — see [Hit Testing and Caret Movement](texthittesting.md).

### The shape of a selection

[`GetSelectionBounds(...)`](xref:SixLabors.Fonts.TextMetrics.GetSelectionBounds*) returns `ReadOnlyMemory<FontRectangle>`. Use `.Span` when drawing, and store the memory itself if the selection needs to be retained alongside other layout state.

```csharp
using System;
using SixLabors.Fonts;

ReadOnlyMemory<FontRectangle> selection = metrics.GetSelectionBounds(anchor, focus);

foreach (FontRectangle rectangle in selection.Span)
{
    FillSelectionRectangle(rectangle);
}
```

A single logical selection can be visually discontinuous inside one line when it crosses bidi runs. Returning multiple rectangles allows browser-style selection where the unselected visual gap stays unpainted.

Do not sort, union, or merge the returned rectangles unless the UI explicitly wants a different visual.

### Pointer selection

For pointer drags, hit-test both endpoints and pass the hits to the selection API. The [`TextHit`](xref:SixLabors.Fonts.TextHit) overload converts both endpoints to logical insertion indices for you.

```csharp
using System.Numerics;
using SixLabors.Fonts;

TextHit anchor = metrics.HitTest(new Vector2(downX, downY));
TextHit focus = metrics.HitTest(new Vector2(moveX, moveY));

ReadOnlyMemory<FontRectangle> selection = metrics.GetSelectionBounds(anchor, focus);
```

This keeps trailing-edge and bidi handling inside the library.

### Keyboard selection

For keyboard selection, keep an anchor caret fixed and move the focus caret. Shift+Right-style behavior updates only the focus caret.

```csharp
using SixLabors.Fonts;

CaretPosition anchor = metrics.GetCaret(CaretPlacement.Start);
CaretPosition focus = anchor;

focus = metrics.MoveCaret(focus, CaretMovement.Next);

ReadOnlyMemory<FontRectangle> selection = metrics.GetSelectionBounds(anchor, focus);
```

Selecting whole words via keyboard is the same shape: move the focus by `NextWord` or `PreviousWord`.

### Word selection

For double-click word selection, find the word containing the hit and ask for its selection bounds.

```csharp
using SixLabors.Fonts;

TextHit hit = metrics.HitTest(doubleClickPosition);
WordMetrics word = metrics.GetWordMetrics(hit);

ReadOnlyMemory<FontRectangle> selection = metrics.GetSelectionBounds(word);
```

The [`GraphemeMetrics`](xref:SixLabors.Fonts.GraphemeMetrics) overload selects exactly one grapheme, which is useful for caret-region overlays:

```csharp
using SixLabors.Fonts;

GraphemeMetrics grapheme = metrics.GraphemeMetrics[index];
ReadOnlyMemory<FontRectangle> selection = metrics.GetSelectionBounds(grapheme);
```

### Bidi drag selection

Consider a left-to-right paragraph whose source text is:

```text
Tall שלום עرب
```

The right-to-left run can paint with Arabic before Hebrew. When a user drags from the left edge of `Tall` toward the Hebrew word, the visual selection can become split:

```text
[Tall ] עرب [שלום]
```

Application code should not manually decide which physical edge of the Hebrew glyph means "before" or "after". The hit-test result already carries the logical insertion index, and the selection result is already split into the visual rectangles that should be painted.

```csharp
using SixLabors.Fonts;

TextHit anchor = metrics.HitTest(mouseDown);
TextHit focus = metrics.HitTest(mouseMove);

ReadOnlyMemory<FontRectangle> rectangles = metrics.GetSelectionBounds(anchor, focus);
```

Just paint every rectangle. The library produces the correct visual gaps.

### Hard line breaks

Hard line breaks that end non-empty lines are trimmed with trailing breaking whitespace. Hard line breaks that own a blank line remain in the metrics and contribute their own selection rectangle so the blank line still highlights when the selection crosses it.

For text with two hard breaks in the middle:

```text
Tall عرب שלום

Small مرحبا שלום
```

A full selection paints three visual rows: the first text line, the blank line, and the second text line. The line break that ends a non-empty line does not add a separate painted box; the line break that owns the blank line does. Callers should not special-case this — paint the rectangles `GetSelectionBounds` returns.

Consumers that inspect individual graphemes can use [`GraphemeMetrics.IsLineBreak`](xref:SixLabors.Fonts.GraphemeMetrics.IsLineBreak) to identify the blank-line hard breaks that remain in the metrics.

In `TextInteractionMode.Editor`, a hard break that ends the text produces an additional blank line so a selection can extend past the final newline; `TextInteractionMode.Paragraph` omits that trailing blank line. See [Hit Testing and Caret Movement](texthittesting.md) for the full mode comparison.

### Per-line selection

[`LineLayout`](xref:SixLabors.Fonts.LineLayout) exposes the same selection overloads when the caller knows the selection is line-local:

```csharp
using SixLabors.Fonts;

LineLayout line = layouts.Span[lineIndex];

ReadOnlyMemory<FontRectangle> selection = line.GetSelectionBounds(anchor, focus);
ReadOnlyMemory<FontRectangle> wordSelection = line.GetSelectionBounds(word);
```

Use the full [`TextMetrics`](xref:SixLabors.Fonts.TextMetrics) overloads for selections that can cross line boundaries; use [`LineLayout`](xref:SixLabors.Fonts.LineLayout) only when interaction is bounded to one line.

### Stable line-box geometry

Per-line selection uses the line-box height rather than per-glyph height, which matches normal text editor and browser behavior: selecting mixed font sizes on the same line paints a consistent line-height rectangle rather than one rectangle per glyph height. The selection geometry stays visually stable across mixed fonts and font sizes.

For a wider tour of the measurement model and how line metrics are derived, see [Measuring Text](measuringtext.md).

### Practical guidance

- Paint the selection rectangles returned by the API instead of reconstructing selection geometry yourself.
- Keep anchor and focus as logical text positions; let the metrics map them into visual rectangles.
- Use editor interaction mode when selections must include terminal blank lines.
- Test mixed LTR/RTL selections with real strings, not only simple Latin text.
