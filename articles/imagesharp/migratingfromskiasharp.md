# Migrating from SkiaSharp

If you are coming from SkiaSharp, the biggest adjustment is separating core image work from drawing work. ImageSharp owns loading, saving, metadata, pixel buffers, color conversion, and processing pipelines. ImageSharp.Drawing owns vector drawing, text, paths, and canvas composition.

This page focuses on core ImageSharp workflows. For canvas, brush, pen, path, transform, and text migration examples, see the ImageSharp.Drawing [Migrating from SkiaSharp](../imagesharp.drawing/migratingfromskiasharp.md) guide.

## Core Type Mapping

| SkiaSharp concept | ImageSharp equivalent |
|---|---|
| `SKBitmap` / `SKPixmap` | [`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1), pixel buffers, or row access APIs |
| `SKImage` | [`Image`](xref:SixLabors.ImageSharp.Image) or [`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1) |
| `SKColor` | [`Color`](xref:SixLabors.ImageSharp.Color), or a concrete pixel type such as [`Rgba32`](xref:SixLabors.ImageSharp.PixelFormats.Rgba32) |
| `SKColorType` / `SKAlphaType` | generic `TPixel` plus [`PixelTypeInfo`](xref:SixLabors.ImageSharp.PixelFormats.PixelTypeInfo) |
| `SKBitmap.Decode(...)` | `Image.Load(...)` or `Image.Load<TPixel>(...)` |
| `SKImage.Encode(...)` | `Save(...)`, `SaveAsJpeg(...)`, `SaveAsPng(...)`, or explicit encoder types |
| `SKPixmap.GetPixelColor(...)` | indexers or `ProcessPixelRows(...)` |
| `SKPixmap` / `InstallPixels(...)` | `LoadPixelData(...)`, `WrapMemory(...)`, `CopyPixelDataTo(...)`, or `ProcessPixelRows(...)` |

## Loading, Processing, and Saving

A typical SkiaSharp decode, resize, and encode flow maps to ImageSharp loading, mutation, and saving.

SkiaSharp:

```csharp
using SkiaSharp;

using SKBitmap source = SKBitmap.Decode("input.jpg");
using SKBitmap output = source.Resize(new SKImageInfo(400, 300), SKFilterQuality.High);
using SKImage image = SKImage.FromBitmap(output);
using SKData data = image.Encode(SKEncodedImageFormat.Png, 100);

using FileStream stream = File.OpenWrite("output.png");
data.SaveTo(stream);
```

ImageSharp:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(context => context.Resize(400, 300));
image.SaveAsPng("output.png");
```

ImageSharp processors run through `Mutate(...)` for in-place updates or `Clone(...)` when you want a separate output image.

## Pixels: Prefer Row Access Over Per-Pixel APIs

If your SkiaSharp code reads or writes individual pixels, the closest ImageSharp equivalent is the image indexer.

SkiaSharp:

```csharp
using SkiaSharp;

SKColor pixel = bitmap.GetPixel(10, 20);
bitmap.SetPixel(10, 20, SKColors.White);
```

ImageSharp:

```csharp
using SixLabors.ImageSharp.PixelFormats;

Rgba32 pixel = image[10, 20];
image[10, 20] = Rgba32.White;
```

For real throughput, move to row access instead of per-pixel calls.

SkiaSharp:

```csharp
using SkiaSharp;

for (int y = 0; y < bitmap.Height; y++)
{
    for (int x = 0; x < bitmap.Width / 2; x++)
    {
        SKColor left = bitmap.GetPixel(x, y);
        SKColor right = bitmap.GetPixel(bitmap.Width - x - 1, y);

        bitmap.SetPixel(x, y, right);
        bitmap.SetPixel(bitmap.Width - x - 1, y, left);
    }
}
```

ImageSharp:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

using Image<Rgba32> image = Image.Load<Rgba32>("input.png");

image.ProcessPixelRows(accessor =>
{
    for (int y = 0; y < accessor.Height; y++)
    {
        Span<Rgba32> row = accessor.GetRowSpan(y);
        row.Reverse();
    }
});
```

## Color and Pixel Format

SkiaSharp often carries pixel layout through `SKImageInfo`, `SKColorType`, and `SKAlphaType`. ImageSharp makes the working pixel format explicit through `Image<TPixel>`.

SkiaSharp:

```csharp
using SkiaSharp;

SKImageInfo info = new(640, 360, SKColorType.Rgba8888, SKAlphaType.Unpremul);
using SKBitmap bitmap = new(info);
```

ImageSharp:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

using Image<Rgba32> image = new(640, 360);
```

Use [`Color`](xref:SixLabors.ImageSharp.Color) when you want a pixel-agnostic color value, and use a concrete pixel type such as [`Rgba32`](xref:SixLabors.ImageSharp.PixelFormats.Rgba32) when the memory layout matters.

## Raw Pixel Buffers

SkiaSharp code that installs or peeks pixel memory usually maps to one of ImageSharp's explicit raw-memory APIs.

SkiaSharp:

```csharp
using SkiaSharp;

SKImageInfo info = new(320, 200, SKColorType.Rgba8888, SKAlphaType.Unpremul);
using SKBitmap bitmap = new();

bitmap.InstallPixels(info, pixels, info.RowBytes);
```

ImageSharp:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

using Image<Rgba32> image = Image.LoadPixelData<Rgba32>(pixels, 320, 200);
```

Use `LoadPixelData(...)` when ImageSharp should own a normal image copy. Use `WrapMemory(...)` when you need ImageSharp to operate over existing memory without copying. Use `CopyPixelDataTo(...)` when you need to export pixels.

## Drawing APIs

If your SkiaSharp code mainly uses `SKCanvas`, `SKPaint`, `SKPath`, or text drawing, use the ImageSharp.Drawing migration guide:

- [Migrating from SkiaSharp in ImageSharp.Drawing](../imagesharp.drawing/migratingfromskiasharp.md)

## Practical Migration Strategy

For most SkiaSharp image migrations:

1. Replace decode and encode code with `Image.Load(...)` and `Save(...)` or format-specific save methods.
2. Replace `SKBitmap` pixel storage with `Image<TPixel>`.
3. Replace `SKColorType` and `SKAlphaType` branching with explicit `TPixel` choices.
4. Replace per-pixel loops with `ProcessPixelRows(...)`.
5. Replace raw memory interop with `LoadPixelData(...)`, `WrapMemory(...)`, or `CopyPixelDataTo(...)`.
6. Move canvas drawing code to ImageSharp.Drawing rather than mixing it into the core image migration.

## Related Topics

- [Getting Started](gettingstarted.md)
- [Processing Images](processing.md)
- [Working with Pixel Buffers](pixelbuffers.md)
- [Interop and Raw Memory](interop.md)
- [Migrating from SkiaSharp in ImageSharp.Drawing](../imagesharp.drawing/migratingfromskiasharp.md)
