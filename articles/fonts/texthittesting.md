# Hit Testing and Caret Movement

Once text has been laid out, applications usually need to translate between pixels, character positions, and editor commands. Fonts exposes a small set of types that own the bidi, grapheme, and hard-break rules so callers do not need to reimplement them: [`TextHit`](xref:SixLabors.Fonts.TextHit), [`CaretPosition`](xref:SixLabors.Fonts.CaretPosition), [`CaretPlacement`](xref:SixLabors.Fonts.CaretPlacement), and [`CaretMovement`](xref:SixLabors.Fonts.CaretMovement).

All positional values returned by these APIs are in pixel units.

### Get a measurement object

Hit testing, caret positioning, and caret movement all operate on a [`TextMetrics`](xref:SixLabors.Fonts.TextMetrics) (whole-block) or [`LineLayout`](xref:SixLabors.Fonts.LineLayout) (single line). Either come from [`TextMeasurer`](xref:SixLabors.Fonts.TextMeasurer) or from a prepared [`TextBlock`](xref:SixLabors.Fonts.TextBlock). See [Prepared Text with TextBlock](textblock.md) for when to prefer one over the other.

```csharp
using System.Numerics;
using SixLabors.Fonts;

Font font = SystemFonts.CreateFont("Segoe UI", 18);
TextOptions options = new(font)
{
    WrappingLength = 320,
    Origin = new Vector2(20, 30),
    TextInteractionMode = TextInteractionMode.Editor
};

TextMetrics metrics = TextMeasurer.Measure("Hello, world!", options);
```

### Choose paragraph or editor mode

[`TextOptions.TextInteractionMode`](xref:SixLabors.Fonts.TextOptions.TextInteractionMode) controls how trailing whitespace and terminal hard breaks behave for hit testing, caret movement, and selection.

- `TextInteractionMode.Paragraph` (the default) is the right fit for laid-out paragraphs and rendered text labels. Trailing breaking whitespace at the end of a line is trimmed from the layout, and a hard break that ends the text does not produce a caret stop on a trailing blank line. This matches the way browsers measure and paint static text.
- `TextInteractionMode.Editor` is the right fit for editable text surfaces. Ordinary trailing whitespace stays addressable so typed spaces continue to advance the caret, and a terminal `Enter` produces a blank line whose geometry the caret can land on.

Set this once on the `TextOptions` you measure with. Every interaction API on the resulting `TextMetrics` (and on each `LineLayout`) honors it automatically — there is no per-call switch.

If your application has both rendered paragraph regions and editable regions, use a different `TextOptions` instance for each, with the matching `TextInteractionMode` set on it.

### Hit-test a point

[`HitTest(point)`](xref:SixLabors.Fonts.TextMetrics.HitTest*) maps a pointer position to the nearest grapheme and returns a [`TextHit`](xref:SixLabors.Fonts.TextHit).

```csharp
using System.Numerics;
using SixLabors.Fonts;

TextHit hit = metrics.HitTest(new Vector2(mouseX, mouseY));

int line = hit.LineIndex;
int grapheme = hit.GraphemeIndex;
int stringIndex = hit.StringIndex;
bool trailing = hit.IsTrailing;
```

[`TextHit`](xref:SixLabors.Fonts.TextHit) is meant to be passed straight back into the interaction APIs — [`GetCaretPosition(hit)`](xref:SixLabors.Fonts.TextMetrics.GetCaretPosition*), [`GetSelectionBounds(anchor, focus)`](xref:SixLabors.Fonts.TextMetrics.GetSelectionBounds*), [`GetWordMetrics(hit)`](xref:SixLabors.Fonts.TextMetrics.GetWordMetrics*). Those overloads consume the hit directly and apply the trailing-side and bidi rules internally, so callers do not need to compute the visual side themselves.

The properties are exposed for diagnostics and for cases where you need to point back into your own text — for example, mapping the hit to a position in your source string. `GraphemeInsertionIndex` is the insertion position within the laid-out grapheme array; you rarely need to read it yourself.

### Position a caret

A [`CaretPosition`](xref:SixLabors.Fonts.CaretPosition) is both a drawable line and the navigation token used by the movement APIs.

```csharp
using SixLabors.Fonts;

CaretPosition caret = metrics.GetCaretPosition(hit);

DrawCaret(caret.Start, caret.End);

if (caret.HasSecondary)
{
    DrawSecondaryCaret(caret.SecondaryStart, caret.SecondaryEnd);
}
```

At bidi run boundaries, one logical insertion position has two visual edges. [`CaretPosition.HasSecondary`](xref:SixLabors.Fonts.CaretPosition.HasSecondary) indicates that case, and [`SecondaryStart`](xref:SixLabors.Fonts.CaretPosition.SecondaryStart) / [`SecondaryEnd`](xref:SixLabors.Fonts.CaretPosition.SecondaryEnd) give the second visual edge. Editor-style callers can choose how to present or navigate the boundary without recomputing bidi affinity.

When initializing a caret without a pointer hit (for example, for a freshly opened editor), use the placement overload:

```csharp
using SixLabors.Fonts;

CaretPosition start = metrics.GetCaret(CaretPlacement.Start);
CaretPosition end = metrics.GetCaret(CaretPlacement.End);
```

### Move a caret

[`MoveCaret(...)`](xref:SixLabors.Fonts.TextMetrics.MoveCaret*) applies an editor-style movement to a caret and returns the new caret. The library owns the grapheme, line, and hard-break rules; callers should not perform their own grapheme arithmetic.

```csharp
using SixLabors.Fonts;

CaretPosition caret = metrics.GetCaret(CaretPlacement.Start);

caret = metrics.MoveCaret(caret, CaretMovement.Next);
caret = metrics.MoveCaret(caret, CaretMovement.NextWord);
caret = metrics.MoveCaret(caret, CaretMovement.LineEnd);
caret = metrics.MoveCaret(caret, CaretMovement.TextStart);
```

[`CaretMovement`](xref:SixLabors.Fonts.CaretMovement) covers the standard editor commands:

- `Previous` and `Next` move through grapheme insertion positions.
- `PreviousWord` and `NextWord` move through Unicode word boundaries.
- `LineStart` and `LineEnd` are the Home/End-style operations.
- `TextStart` and `TextEnd` are the whole-block equivalents.
- `LineUp` and `LineDown` move to the previous or next visual line.

All movement operations work in logical order and the returned `CaretPosition` is placed at the correct visual edge for the resolved bidi layout. In a right-to-left run, `Next` advances the caret one grapheme forward in the source text — visually that lands on the *left* edge of the next glyph, matching how browsers and native text editors behave. `LineStart` and `LineEnd` resolve to the visual edges that match the line's text direction (logical start of an RTL paragraph is on the right). Callers should not adjust for direction themselves; pass the returned `CaretPosition` straight back into `MoveCaret(...)` and the library tracks the bidi state.

At bidi run boundaries one logical insertion position has two visual edges. `MoveCaret(...)` returns a `CaretPosition` with `HasSecondary == true` in that case so editor-style callers can present both edges or pick whichever fits the surrounding caret state.

`LineUp` and `LineDown` preserve the caret's original requested position on the line. Repeated vertical movement keeps that position even when an intermediate line is shorter and the visible caret has to clamp to that line's end.

```csharp
CaretPosition caret = metrics.GetCaret(CaretPlacement.Start);
caret = metrics.MoveCaret(caret, CaretMovement.LineEnd);

// Repeated LineDown remembers the original line position.
CaretPosition next = metrics.MoveCaret(caret, CaretMovement.LineDown);
CaretPosition after = metrics.MoveCaret(next, CaretMovement.LineDown);
```

This matches normal rich-text editor behavior: moving down through a short line does not permanently lose the user's original horizontal or vertical line position.

### Look up a word

For double-click or word-based selection, pass the hit (or caret) directly to [`GetWordMetrics(...)`](xref:SixLabors.Fonts.TextMetrics.GetWordMetrics*). This uses the grapheme that was hit, so clicking the trailing side of the final grapheme of a word still selects that word rather than the following separator segment.

```csharp
using SixLabors.Fonts;

TextHit hit = metrics.HitTest(doubleClickPosition);
WordMetrics word = metrics.GetWordMetrics(hit);
```

A Unicode word-boundary segment includes its separators. `can't stop` produces three segments: `can't`, the space, and `stop`. Higher-level editor commands can decide whether to stop on separator boundaries or skip over them.

### Per-line interaction

[`LineLayout`](xref:SixLabors.Fonts.LineLayout) mirrors the interaction surface for a single line. Use it when the caller already knows interaction is line-local; otherwise prefer [`TextMetrics`](xref:SixLabors.Fonts.TextMetrics) so cross-line behavior (such as `LineDown` or wrapping selection) works correctly.

```csharp
using SixLabors.Fonts;

ReadOnlyMemory<LineLayout> layouts = block.GetLineLayouts(320);

foreach (LineLayout line in layouts.Span)
{
    TextHit hit = line.HitTest(point);
    CaretPosition caret = line.GetCaretPosition(hit);
    WordMetrics word = line.GetWordMetrics(hit);
}
```

### Hard line breaks

Hard line breaks at the end of non-empty lines are trimmed with other trailing breaking whitespace. Hard line breaks that own a blank line remain in the metrics so source ranges, hit testing, caret movement, and selection painting still cover that line. Consumers that inspect graphemes individually can use `GraphemeMetrics.IsLineBreak` to identify these cases.

In `TextInteractionMode.Editor`, a terminal hard break also produces a blank line at the end of the text so the caret can land on it after the user types `Enter`. In `TextInteractionMode.Paragraph` that trailing blank line is omitted, matching paragraph-style layout.

For more on the underlying measurement model and the `TextMetrics` shape, see [Measuring Text](measuringtext.md). For the full selection API, see [Selection and Bidi Drag](caretsandselection.md).
