# Working with Pixel Buffers

### Setting individual pixels using indexers
A very basic and readable way for manipulating individual pixels is to use the indexer either on `Image<T>` or `ImageFrame<T>`:
```C#
using (Image<Rgba32> image = new Image<Rgba32>(400, 400))
{
    image[200, 200] = Rgba32.White; // also works on ImageFrame<T>
}
```

The idexer is much faster than the `.GetPixel(x, y)` and `.SetPixel(x,y)` methods of `System.Drawing` but, it's still quite slow.

### Efficient pixel manipulation
If you want to achieve killer speed in your own low-level pixel manipulation routines, you should utilize the per-row methods. These methods take advantage of the [brand-new `Span<T>`-based memory manipulation primitives](https://www.codemag.com/Article/1807051/Introducing-.NET-Core-2.1-Flagship-Types-Span-T-and-Memory-T) from [System.Memory](https://www.nuget.org/packages/System.Memory/), providing a fast, yet safe low-level solution to manipulate pixel data.

This is how you can implement efficient row-by-row pixel manipulation:

```C#
using SixLabors.ImageSharp.Advanced;

// ...

using (Image<Rgba32> image = new Image<Rgba32>(400, 400))
{
    for (int y = 0; y < image.Height; y++)
	{
		Span<Rgba32> pixelRowSpan = image.GetPixelRowSpan(y);
		for (int x = 0; x < image.Width; x++)
		{
			pixelRowSpan[x] = new Rgba32(x/255, y/255, 50, 255);
		}
	}
}

```

### `Span<T>` limitations
Please be aware that **`Span<T>` has a very specific limitation**: it is a stack-only type! Read the *Is There Anything Span Can’t Do?!* section in [this article](https://www.codemag.com/Article/1807051/Introducing-.NET-Core-2.1-Flagship-Types-Span-T-and-Memory-T) for more details.
A short summary of the limitations:
- Span can only live on the execution stack.
- Span cannot be boxed or put on the heap.
- Span cannot be used as a generic type argument.
- Span cannot be an instance field of a type that itself is not stack-only.
- Span cannot be used within asynchronous methods.

**Non-conformant code:**
```C#
Span<Rgba32> span = image.GetRowSpan(y);

await Task.Run(() =>
	{   
		// ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠
		// ☠☠☠ BANG! YOU HAVE CAPTURED A SPAN ON THE HEAP! ☠☠☠

		for (int i = 0; i < span.Length; i++)
		{
			span[i] = /* ... */;
		}
	});
```

### Exporting raw pixel data from an `Image<T>`
You can use @"SixLabors.ImageSharp.Image`1.TryGetSinglePixelSpan*" to access the whole contigous pixel buffer, eg. to copy the pixel data into an array. For large, multu-megapixel images, however, the data must be accessed and copied per row:
```C#
if(image.TryGetPixelSpan(out var pixelSpan))
{
    Rgba32[] pixelArray = pixelSpan.ToArray();
}
```

Or:
```C#
Rgba32[] pixelArray = /* your pixel buffer being reused */
if(image.TryGetPixelSpan(out var pixelSpan))
{
    pixelSpan().CopyTo(pixelArray);
}
```

Or:
```C#
if(image.TryGetPixelSpan(out var pixelSpan))
{
    byte[] rgbaBytes = MemoryMarshal.AsBytes(pixelSpan()).ToArray();
}
```

### Loading raw pixel data into an `Image<T>`

```C#
Rgba32[] rgbaData = GetMyRgbaArray();
using (var image = Image.LoadPixelData(rgbaData))
{
	// Work with the image
}
```

```C#
byte[] rgbaBytes = GetMyRgbaBytes();
using (var image = Image.LoadPixelData<Rgba32>(rgbaBytes))
{
	// Work with the image
}
```

