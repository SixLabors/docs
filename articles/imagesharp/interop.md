# Interop and Raw Memory

ImageSharp supports both copy-based and zero-copy workflows for raw pixel data. Which API you choose depends on who owns the memory and whether you need ImageSharp to keep its own copy.

## Choose the Right API

| Need | API | Copies pixel data? | Who owns the memory? |
|---|---|---|---|
| Import raw pixels into a normal ImageSharp-owned image | `Image.LoadPixelData(...)` | Yes | ImageSharp |
| Export pixels from an image | `CopyPixelDataTo(...)` | Yes | Caller |
| Wrap existing managed memory | `Image.WrapMemory(...)` with `Memory<T>` or `Memory<byte>` | No | Caller |
| Wrap an owned buffer and transfer disposal to ImageSharp | `Image.WrapMemory(...)` with `IMemoryOwner<T>` or `IMemoryOwner<byte>` | No | ImageSharp |
| Wrap unmanaged or pinned memory | `Image.WrapMemory(...)` pointer overloads | No | Caller |

## `WrapMemory(...)` Creates a View, Not a Copy

[`Image.WrapMemory(...)`](xref:SixLabors.ImageSharp.Image.WrapMemory*) does not decode, convert, or clone the source pixels. It creates an [`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1) view over memory you already have.

That makes it ideal for zero-copy interop, but it also means:

- the wrapped memory must already match the chosen `TPixel` layout;
- the source buffer lifetime rules still matter;
- the image is tied to the shape and stride of that existing buffer.

## Import Raw Pixels with `LoadPixelData(...)`

Use `LoadPixelData(...)` when you want ImageSharp to create a normal owned image from existing pixels:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

byte[] rgba = GetRgbaBytes();
using Image<Rgba32> image = Image.LoadPixelData<Rgba32>(rgba, width, height);
```

There are overloads for:

- `ReadOnlySpan<TPixel>`
- `ReadOnlySpan<byte>`
- stride-aware pixel input
- stride-aware byte input

This is the safest choice when you do not need zero-copy behavior.

## Export Raw Pixels with `CopyPixelDataTo(...)`

Use `CopyPixelDataTo(...)` when you want a flattened copy of the root frame pixels:

```csharp
using SixLabors.ImageSharp.PixelFormats;

Rgba32[] pixels = new Rgba32[image.Width * image.Height];
image.CopyPixelDataTo(pixels);
```

There is also a `Span<byte>` overload if you need raw bytes instead of `TPixel` values.

If you need frame-specific access, the same API is available on [`ImageFrame<TPixel>`](xref:SixLabors.ImageSharp.ImageFrame`1).

## Wrap Existing Managed Memory Without Copying

Use `Image.WrapMemory(...)` when you already have raw memory and want ImageSharp to view it in place:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

byte[] bgra = GetBgraBytes();
using Image<Bgra32> image = Image.WrapMemory<Bgra32>(bgra, width, height, rowStrideInBytes);
```

Important ownership rule:

- If you pass [`Memory<T>`](xref:System.Memory`1) or `Memory<byte>`, ownership stays with you.
- The underlying buffer must remain valid for the entire lifetime of the image.

That makes `WrapMemory(...)` a good fit for shared buffers, pinned arrays, and memory you already control.

All `WrapMemory(...)` families also have overloads that accept [`Configuration`](xref:SixLabors.ImageSharp.Configuration) and [`ImageMetadata`](xref:SixLabors.ImageSharp.Metadata.ImageMetadata), so you can attach metadata or use a non-default configuration while still keeping the zero-copy behavior.

## Choose the Right `WrapMemory(...)` Overload

Within the `WrapMemory(...)` family, the main choice is what kind of source memory you have:

- use `Memory<TPixel>` when you already have typed pixel data;
- use `Memory<byte>` when the source buffer is raw bytes in a known `TPixel` layout;
- use `IMemoryOwner<TPixel>` or `IMemoryOwner<byte>` when you want the wrapped image to take ownership and dispose the backing owner;
- use pointer overloads only for unmanaged or pinned memory that cannot be expressed more safely as `Memory<T>` or `Memory<byte>`.

If the source buffer has row padding, use the stride-aware overload:

- `rowStride` for typed pixel memory;
- `rowStrideInBytes` for byte or pointer memory.

## Transfer Ownership with `IMemoryOwner<T>`

If you want ImageSharp to dispose the wrapped buffer together with the image, use an [`IMemoryOwner<T>`](xref:System.Buffers.IMemoryOwner`1) overload:

```csharp
using System.Buffers;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

IMemoryOwner<byte> owner = MemoryPool<byte>.Shared.Rent(bufferSize);
using Image<Bgra32> image = Image.WrapMemory<Bgra32>(owner, width, height, rowStrideInBytes);
```

In that form, the ownership of `owner` is transferred to the image. Do not dispose it yourself after wrapping.

## Packed vs Strided Wrapped Buffers

Wrapped buffers can be either tightly packed or strided.

A packed wrapper uses one logical row immediately after the previous one. A strided wrapper uses extra elements or bytes between row starts, which is common when working with foreign image APIs.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

Rgba32[] source = new Rgba32[8];

using Image<Rgba32> image = Image.WrapMemory(
    source.AsMemory(),
    width: 3,
    height: 2,
    rowStride: 4);

bool contiguous = image.DangerousTryGetSinglePixelMemory(out _); // false
```

Important consequences of a strided wrapper:

- [`DangerousTryGetSinglePixelMemory(...)`](xref:SixLabors.ImageSharp.Image`1.DangerousTryGetSinglePixelMemory*) will usually return `false`;
- [`CopyPixelDataTo(...)`](xref:SixLabors.ImageSharp.Image`1.CopyPixelDataTo*) uses the backing row layout, so destination length must account for stride, not only `width * height`;
- row padding belongs to the wrapped view contract, so make sure the caller and callee agree on it.

## Work with Native or Pinned Memory

`Image.WrapMemory(...)` also has pointer overloads for unmanaged or manually pinned buffers. Those overloads are intended for advanced interop scenarios where you already have a stable pointer and buffer length.

Use them carefully:

- The pointer must remain valid for the full lifetime of the wrapped image.
- The buffer size and row stride must match the image dimensions.
- If you have `Memory<T>` or `Memory<byte>`, prefer those overloads instead because they are much easier to reason about safely.

## Wrapped Images Are Best for Fixed-Size Work

`WrapMemory(...)` is best when you want ImageSharp to operate on an existing fixed-size buffer.

That means in-place pixel work, analysis, format conversion, and encode/decode bridges are good fits. Operations that need to replace the backing buffer, especially dimension-changing processors like `Resize()`, are not a good fit for a wrapped image and may throw.

If you need to resize, crop into a new image, pad, or otherwise move into a normal ImageSharp-owned lifecycle, clone first:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Bgra32> wrapped = Image.WrapMemory<Bgra32>(bgra, width, height, rowStrideInBytes);
using Image<Rgba32> owned = wrapped.CloneAs<Rgba32>();

owned.Mutate(x => x.Resize(width / 2, height / 2));
```

## Get a Contiguous Buffer from an ImageSharp Image

If you need to hand ImageSharp-owned pixels to native code, ask for contiguous allocation up front and then call `DangerousTryGetSinglePixelMemory(...)`:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

Configuration config = Configuration.Default.Clone();
config.PreferContiguousImageBuffers = true;

using Image<Rgba32> image = new(config, width, height);

if (!image.DangerousTryGetSinglePixelMemory(out Memory<Rgba32> pixels))
{
    throw new InvalidOperationException("The image is not backed by one contiguous buffer.");
}
```

From there, you can pin the returned [`Memory<T>`](xref:System.Memory`1) if your native API requires an address. Keep the image alive for the full duration of that native access.

## Stride Matters

Several interop APIs take a row stride:

- `rowStride` for pixel-count-based overloads
- `rowStrideInBytes` for byte-count-based overloads

Use the stride-aware overloads whenever your source buffer contains padding between rows. Do not assume every foreign buffer is tightly packed.

## Make a Normal Owned Copy When Needed

If you wrapped foreign memory only as a temporary bridge, you can switch back to a normal ImageSharp-owned image with `Clone()` or `CloneAs<TPixel>()`:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

using Image<Bgra32> wrapped = Image.WrapMemory<Bgra32>(bgra, width, height, rowStrideInBytes);
using Image<Rgba32> owned = wrapped.CloneAs<Rgba32>();
```

That is often the right move if the wrapped buffer has awkward lifetime rules, if you want a different working pixel format, or if the next processing steps may need a different backing buffer shape.

## Related Topics

- [Working with Pixel Buffers](pixelbuffers.md)
- [Memory Management](memorymanagement.md)
- [Troubleshooting](troubleshooting.md)
- [Migrating from System.Drawing](migratingfromsystemdrawing.md)
