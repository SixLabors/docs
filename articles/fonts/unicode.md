# Unicode, Code Points, and Graphemes

Text handling gets easier once you stop treating every `char` as a whole character. Fonts exposes the text-unit levels it actually uses during layout so you can reason about indexing, fallback, shaping, and glyph coverage with the same vocabulary as the library.

### The text-unit levels

- `char`: a single UTF-16 code unit in a .NET `string`
- [`CodePoint`](xref:SixLabors.Fonts.Unicode.CodePoint): a Unicode scalar value
- grapheme: a user-perceived text element, represented by a `ReadOnlySpan<char>` returned from [`SpanGraphemeEnumerator`](xref:SixLabors.Fonts.Unicode.SpanGraphemeEnumerator)

In everyday text, those levels often line up for simple ASCII. Once you move beyond that, they diverge quickly.

### What is a `char`?

In .NET, `string` is UTF-16. That means a single `char` is just one UTF-16 code unit.

A `char` is not always a full Unicode character:

- BMP scalars such as `A` fit in one `char`
- supplementary-plane scalars such as many emoji use two `char` values as a surrogate pair
- combining sequences can use multiple `char` values to represent what a user sees as one text element

So if you index raw `char` positions, you are working at the storage level, not the text-semantics level.

### What is a `CodePoint`?

In strict Unicode terminology:

- a code point is any value in the range `U+0000` through `U+10FFFF`
- a Unicode scalar value is any code point except the surrogate range `U+D800` through `U+DFFF`

<xref:SixLabors.Fonts.Unicode.CodePoint> represents Unicode scalar values. Despite the type name, it intentionally excludes standalone surrogate code points because those are UTF-16 encoding artifacts, not meaningful text values to shape or render.

That makes it the right unit when you want to talk about valid Unicode text values directly.

Useful [`CodePoint`](xref:SixLabors.Fonts.Unicode.CodePoint) members include:

- `Value`
- `Utf16SequenceLength`
- `Utf8SequenceLength`
- `IsAscii`
- `IsBmp`
- `Plane`
- `ReplacementChar`

This is also the unit used by glyph-probing APIs such as [`Font.TryGetGlyphs(...)`](xref:SixLabors.Fonts.Font.TryGetGlyphs*).

### What is a grapheme?

A grapheme cluster is the closest thing to a user-perceived text element.

Examples:

- `A` is one grapheme
- `A` followed by a combining acute accent is still one grapheme
- many emoji sequences joined with zero-width joiners are one grapheme
- a flag emoji made from two regional indicators is one grapheme

Fonts exposes grapheme enumeration through [`SpanGraphemeEnumerator`](xref:SixLabors.Fonts.Unicode.SpanGraphemeEnumerator), which implements the Unicode grapheme cluster algorithm from UAX #29.

This is why [`TextRun.Start`](xref:SixLabors.Fonts.TextRun.Start) and [`TextRun.End`](xref:SixLabors.Fonts.TextRun.End) are grapheme indices rather than raw `char` indices.

### Enumerate `CodePoint` values

The Unicode enumeration helpers live in `SixLabors.Fonts.Unicode`.

```csharp
using System;
using SixLabors.Fonts.Unicode;

// 'A' + combining acute accent (U+0301) renders as a single accented A grapheme,
// followed by a space and the grinning-face emoji (U+1F600).
string text = "Á 😀";

foreach (CodePoint codePoint in text.AsSpan().EnumerateCodePoints())
{
    Console.WriteLine(
        $"U+{codePoint.Value:X}: UTF-16 length {codePoint.Utf16SequenceLength}");
}
```

[`EnumerateCodePoints()`](xref:SixLabors.Fonts.Unicode.MemoryExtensions.EnumerateCodePoints*) returns a [`SpanCodePointEnumerator`](xref:SixLabors.Fonts.Unicode.SpanCodePointEnumerator). It yields [`CodePoint`](xref:SixLabors.Fonts.Unicode.CodePoint) values, which means the enumeration surface is Unicode scalar values. Invalid UTF-16 sequences are surfaced as [`CodePoint.ReplacementChar`](xref:SixLabors.Fonts.Unicode.CodePoint.ReplacementChar).

Count helpers are also available:

```csharp
using SixLabors.Fonts.Unicode;

// 'A' + combining acute (U+0301), space, grinning-face emoji (U+1F600).
// 4 code points: 'A', U+0301, ' ', U+1F600.
int count = "Á 😀".GetCodePointCount();
```

### Enumerate graphemes

Use grapheme enumeration when you need units that better match what a reader sees.

```csharp
using System;
using SixLabors.Fonts.Unicode;

// Same text as before, but graphemes group the accented A into one cluster.
string text = "Á 😀";
int index = 0;

foreach (ReadOnlySpan<char> grapheme in text.AsSpan().EnumerateGraphemes())
{
    Console.WriteLine($"{index++}: {grapheme.ToString()}");
}
```

[`EnumerateGraphemes()`](xref:SixLabors.Fonts.Unicode.MemoryExtensions.EnumerateGraphemes*) returns a [`SpanGraphemeEnumerator`](xref:SixLabors.Fonts.Unicode.SpanGraphemeEnumerator).

Count helpers are available here too:

```csharp
using SixLabors.Fonts.Unicode;

// 3 graphemes: the accented A, the space, and the emoji.
int count = "Á 😀".GetGraphemeCount();
```

### Enumerate word-boundary segments

Use word enumeration when the surface needs to reason about whole words — caret movement that jumps a word at a time, double-click word selection, search-as-you-type tokenization. Word segmentation follows the Unicode Word Boundary Algorithm in UAX #29.

```csharp
using System;
using SixLabors.Fonts.Unicode;

string text = "Don't stop.";

foreach (WordSegment word in text.AsSpan().EnumerateWordSegments())
{
    Console.WriteLine(
        $"[{word.Utf16Offset}..{word.Utf16Offset + word.Utf16Length}] '{word.Span.ToString()}'");
}
```

The output for the example above is:

```text
[0..5] 'Don't'
[5..6] ' '
[6..10] 'stop'
[10..11] '.'
```

UAX #29 segments include separators — the space between `Don't` and `stop` is its own segment, and the trailing `.` is another. Higher-level editor commands can decide whether to stop on those segments or skip past them; the raw enumerator stays aligned with the standard.

[`EnumerateWordSegments()`](xref:SixLabors.Fonts.Unicode.MemoryExtensions.EnumerateWordSegments*) returns a [`SpanWordEnumerator`](xref:SixLabors.Fonts.Unicode.SpanWordEnumerator). Each [`WordSegment`](xref:SixLabors.Fonts.Unicode.WordSegment) exposes:

- `Span` — the UTF-16 slice of the segment.
- `Utf16Offset` and `Utf16Length` — UTF-16 indices into the original text.
- `CodePointOffset` and `CodePointCount` — code-point indices into the original text.

This is the same Unicode word-boundary model used by [`TextMetrics.WordMetrics`](xref:SixLabors.Fonts.TextMetrics.WordMetrics), [`MoveCaret(CaretMovement.NextWord)`](xref:SixLabors.Fonts.TextMetrics.MoveCaret*), and [`GetWordMetrics(hit)`](xref:SixLabors.Fonts.TextMetrics.GetWordMetrics*). Use the enumerator when you need word boundaries against raw text without going through a full layout pass; use the metrics APIs when you need positioned word geometry as well. See [Hit Testing and Caret Movement](texthittesting.md) for the layout-aware side.

### Which unit should you use?

Use `char` when:

- you are working with raw .NET string storage
- you truly need UTF-16 code-unit offsets

Use `CodePoint` when:

- you are inspecting Unicode scalar values
- you are probing glyph availability with [`TryGetGlyphs(...)`](xref:SixLabors.Fonts.Font.TryGetGlyphs*)
- you care about Unicode values, planes, or encoded sequence lengths

Use graphemes when:

- you are slicing visible text ranges
- you are working with [`TextRun.Start`](xref:SixLabors.Fonts.TextRun.Start) and [`TextRun.End`](xref:SixLabors.Fonts.TextRun.End)
- you want indices that align better with user-visible text elements

### Relation to layout

Fonts uses additional Unicode logic internally during layout, including line-breaking and script/shaping data. But the public text-unit APIs you will use most often are:

- `EnumerateCodePoints()`
- `EnumerateGraphemes()`
- `GetCodePointCount()`
- `GetGraphemeCount()`
- `CodePoint`

If you are debugging a `TextRun` range, a missing glyph, or a mismatch between visible text and string indices, start by checking whether you are reasoning in `char`, `CodePoint`, or grapheme units.
