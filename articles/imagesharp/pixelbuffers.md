# Working with Pixel Buffers

When you first start with ImageSharp, the indexer is often enough. As soon as performance, reuse across pixel formats, or interop enter the picture, it helps to know the other buffer-access patterns the library offers and why they exist.

This page is the map for that lower-level work.

## Choose the Right Access Pattern

Use:

- indexers for occasional pixel reads or writes;
- `ProcessPixelRows(...)` for fast row-by-row work in a known `TPixel`;
- `ProcessPixelRowsAsVector4(...)` for reusable pixel-format-agnostic processing;
- `CopyPixelDataTo(...)`, `LoadPixelData(...)`, and `WrapMemory(...)` when exchanging raw data with other systems.

## Use Indexers for Simple Cases

If you only need to touch a few pixels, the indexer is the simplest option:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

using Image<Rgba32> image = new(400, 400);
image[200, 200] = Rgba32.White;
```

That is fine for small amounts of work, but repeated random pixel access has more overhead than processing full rows.

## Use `ProcessPixelRows(...)` for Fast Known-Format Access

[`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1) and [`ImageFrame<TPixel>`](xref:SixLabors.ImageSharp.ImageFrame`1) expose `ProcessPixelRows(...)` so you can work with row spans directly:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

using Image<Rgba32> image = Image.Load<Rgba32>("input.png");

image.ProcessPixelRows(accessor =>
{
    for (int y = 0; y < accessor.Height; y++)
    {
        Span<Rgba32> row = accessor.GetRowSpan(y);

        for (int x = 0; x < row.Length; x++)
        {
            ref Rgba32 pixel = ref row[x];
            if (pixel.A == 0)
            {
                pixel = Rgba32.Transparent;
            }
        }
    }
});
```

This is the usual replacement for `LockBits`-style workflows when your algorithm already knows the working pixel format.

## Process Multiple Images Row by Row

There are overloads for processing multiple images together:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

using Image<Rgba32> source = Image.Load<Rgba32>("source.png");
using Image<Rgba32> target = new(source.Width, source.Height);

source.ProcessPixelRows(target, (sourceAccessor, targetAccessor) =>
{
    for (int y = 0; y < sourceAccessor.Height; y++)
    {
        Span<Rgba32> sourceRow = sourceAccessor.GetRowSpan(y);
        Span<Rgba32> targetRow = targetAccessor.GetRowSpan(y);
        sourceRow.CopyTo(targetRow);
    }
});
```

This is a good fit for compositing, comparisons, or custom copy/merge logic.

## Use `ProcessPixelRowsAsVector4(...)` for Pixel-Format-Agnostic Logic

If you want one processor that can run on many `TPixel` formats, use `ProcessPixelRowsAsVector4(...)`:

```csharp
using System.Numerics;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

image.Mutate(context => context.ProcessPixelRowsAsVector4(row =>
{
    for (int x = 0; x < row.Length; x++)
    {
        row[x] = Vector4.SquareRoot(row[x]);
    }
}));
```

This is extremely useful for reusable processing logic, but remember that it introduces conversion work to and from `Vector4`. It is often a great tradeoff for flexibility, but it is not always the fastest possible path for a hot server-side workload.

## Convert to a Working Pixel Format

Sometimes the cleanest approach is to convert the image into a known working format first:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

using Image source = Image.Load("input.tiff");
using Image<Rgba32> working = source.CloneAs<Rgba32>();
```

[`CloneAs<TPixel>()`](xref:SixLabors.ImageSharp.Image.CloneAs*) is especially useful when you want to standardize a pipeline on [`Rgba32`](xref:SixLabors.ImageSharp.PixelFormats.Rgba32), [`Bgra32`](xref:SixLabors.ImageSharp.PixelFormats.Bgra32), or another specific working format.

## Copy Raw Pixels In and Out

Use `CopyPixelDataTo(...)` when you need a flattened copy of the root frame pixel buffer:

```csharp
using SixLabors.ImageSharp.PixelFormats;

Rgba32[] pixels = new Rgba32[image.Width * image.Height];
image.CopyPixelDataTo(pixels);
```

Use `LoadPixelData(...)` when you want ImageSharp to create an owned image from raw input:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

byte[] rgba = GetRgbaBytes();
using Image<Rgba32> image = Image.LoadPixelData<Rgba32>(rgba, width, height);
```

There are stride-aware overloads for both pixel and byte input. For zero-copy interop, see [Interop and Raw Memory](interop.md).

## `Span<T>` Rules Still Apply

The row spans you get from pixel accessors are [`Span<T>`](xref:System.Span`1) values. That means they are stack-only:

- They cannot be stored on the heap.
- They cannot cross `await` boundaries.
- They cannot be captured and used after the callback returns.

Keep all row work inside the callback that received the accessor.

## Related Topics

- [Pixel Formats](pixelformats.md)
- [Interop and Raw Memory](interop.md)
- [Memory Management](memorymanagement.md)
- [Migrating from System.Drawing](migratingfromsystemdrawing.md)

## Practical Guidance

- Prefer row access over per-pixel indexers for non-trivial work.
- Keep span usage inside the callback that supplied the row accessor.
- Use `ProcessPixelRowsAsVector4(...)` when logic should be pixel-format agnostic.
- Convert to a known working pixel format when the algorithm benefits from simpler direct access.
