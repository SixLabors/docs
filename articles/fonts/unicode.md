# Unicode, Code Points, and Graphemes

Fonts works with several different levels of text units. It is important to keep them separate, because they are not interchangeable.

### The text-unit levels

- `char`: a single UTF-16 code unit in a .NET `string`
- `CodePoint`: a Unicode scalar value, represented by <xref:SixLabors.Fonts.Unicode.CodePoint>
- grapheme: a user-perceived text element, represented by a `ReadOnlySpan<char>` returned from `SpanGraphemeEnumerator`

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

Useful `CodePoint` members include:

- `Value`
- `Utf16SequenceLength`
- `Utf8SequenceLength`
- `IsAscii`
- `IsBmp`
- `Plane`
- `ReplacementChar`

This is also the unit used by glyph-probing APIs such as `Font.TryGetGlyphs(...)`.

### What is a grapheme?

A grapheme cluster is the closest thing to a user-perceived text element.

Examples:

- `A` is one grapheme
- `A` followed by a combining acute accent is still one grapheme
- many emoji sequences joined with zero-width joiners are one grapheme
- a flag emoji made from two regional indicators is one grapheme

Fonts exposes grapheme enumeration through `SpanGraphemeEnumerator`, which implements the Unicode grapheme cluster algorithm from UAX #29.

This is why `TextRun.Start` and `TextRun.End` are grapheme indices rather than raw `char` indices.

### Enumerate `CodePoint` values

The Unicode enumeration helpers live in `SixLabors.Fonts.Unicode`.

```csharp
using System;
using SixLabors.Fonts.Unicode;

string text = "A\u0301 \U0001F600";

foreach (CodePoint codePoint in text.AsSpan().EnumerateCodePoints())
{
    Console.WriteLine(
        $"U+{codePoint.Value:X}: UTF-16 length {codePoint.Utf16SequenceLength}");
}
```

`EnumerateCodePoints()` returns a <xref:SixLabors.Fonts.Unicode.SpanCodePointEnumerator>. It yields `CodePoint` values, which means the enumeration surface is Unicode scalar values. Invalid UTF-16 sequences are surfaced as `CodePoint.ReplacementChar`.

Count helpers are also available:

```csharp
using SixLabors.Fonts.Unicode;

int count = "A\u0301 \U0001F600".GetCodePointCount();
```

### Enumerate graphemes

Use grapheme enumeration when you need units that better match what a reader sees.

```csharp
using System;
using SixLabors.Fonts.Unicode;

string text = "A\u0301 \U0001F600";
int index = 0;

foreach (ReadOnlySpan<char> grapheme in text.AsSpan().EnumerateGraphemes())
{
    Console.WriteLine($"{index++}: {grapheme.ToString()}");
}
```

`EnumerateGraphemes()` returns a <xref:SixLabors.Fonts.Unicode.SpanGraphemeEnumerator>.

Count helpers are available here too:

```csharp
using SixLabors.Fonts.Unicode;

int count = "A\u0301 \U0001F600".GetGraphemeCount();
```

### Which unit should you use?

Use `char` when:

- you are working with raw .NET string storage
- you truly need UTF-16 code-unit offsets

Use `CodePoint` when:

- you are inspecting Unicode scalar values
- you are probing glyph availability with `TryGetGlyphs(...)`
- you care about Unicode values, planes, or encoded sequence lengths

Use graphemes when:

- you are slicing visible text ranges
- you are working with `TextRun.Start` and `TextRun.End`
- you want indices that align better with user-visible text elements

### Relation to layout

Fonts uses additional Unicode logic internally during layout, including line-breaking and script/shaping data. But the public text-unit APIs you will use most often are:

- `EnumerateCodePoints()`
- `EnumerateGraphemes()`
- `GetCodePointCount()`
- `GetGraphemeCount()`
- `CodePoint`

If you are debugging a `TextRun` range, a missing glyph, or a mismatch between visible text and string indices, start by checking whether you are reasoning in `char`, `CodePoint`, or grapheme units.
