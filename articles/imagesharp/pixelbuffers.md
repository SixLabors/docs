# Working with Pixel Buffers

### Setting individual pixels using indexers
A very basic and readable way for manipulating individual pixels is to use the indexer either on `Image<T>` or `ImageFrame<T>`:
```C#
using (Image<Rgba32> image = new Image<Rgba32>(400, 400))
{
    image[200, 200] = Rgba32.White; // also works on ImageFrame<T>
}
```

The indexer is an order of magnitude faster than the `.GetPixel(x, y)` and `.SetPixel(x,y)` methods of `System.Drawing` but there's still room for improvement.

### Efficient pixel manipulation
If you want to achieve killer speed in your own low-level pixel manipulation routines, you should utilize the per-row methods. These methods take advantage of the [brand-new `Span<T>`-based memory manipulation primitives](https://www.codemag.com/Article/1807051/Introducing-.NET-Core-2.1-Flagship-Types-Span-T-and-Memory-T) from [System.Memory](https://www.nuget.org/packages/System.Memory/), providing a fast, yet safe low-level solution to manipulate pixel data.

This is how you can implement efficient row-by-row pixel manipulation. This API receives a @"SixLabors.ImageSharp.PixelAccessor`1" which ensures that the span is never [transferred to the heap](#spant-limitations) making the operation safe.

```C#
using SixLabors.ImageSharp;

// ...
using Image<Rgba32> image = new(400, 400);
image.ProcessPixelRows(accessor =>
{
    Rgba32 rgba32 = default;
    Rgba32 transparent = Color.Transparent;
    for (int y = 0; y < accessor.Height; y++)
    {
        Span<TPixel> span = accessor.GetRowSpan(y);
        for (int x = 0; x < accessor.Width; x++)
        {
            span[x].ToRgba32(ref rgba32);

            if (rgba32.A == 0)
            {
                span[x].FromRgba32(transparent);
            }
        }
    }
});
```

### Parallel, pixel-format agnostic image manipulation
There is a way to process image data that is even faster than using the approach mentioned before, and that also has the advantage of working on images of any underlying pixel-format, in a completely transparent way: using the @"SixLabors.ImageSharp.Processing.PixelRowDelegateExtensions.ProcessPixelRowsAsVector4(SixLabors.ImageSharp.Processing.IImageProcessingContext,SixLabors.ImageSharp.Processing.PixelRowOperation)" APIs.

This is how you can use this extension to manipulate an image:

```C#
// ...

image.Mutate(c => c.ProcessPixelRowsAsVector4(row =>
{
    for (int x = 0; x < row.Length; x++)
    {
        // We can apply any custom processing logic here
        row[x] = Vector4.SquareRoot(row[x]);
    }
}));
```

This API receives a @"SixLabors.ImageSharp.Processing.PixelRowOperation" instance as input, and uses it to modify the pixel data of the target image. It does so by automatically executing the input operation in parallel, on multiple pixel rows at the same time, to fully leverage the power of modern multi-core CPUs. The `ProcessPixelRowsAsVector4` extension also takes care of converting the pixel data to/from the `Vector4` format, which means the same operation can be used to easily process images of any existing pixel-format, without having to implement the processing logic again for each of them.

This extension offers the fastest, easiest and most flexible way to implement custom image processors in ImageSharp.

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
Span<Rgba32> span = imageFrame.PixelBuffer.DangerousGetRowSpan(y);

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
You can use @"SixLabors.ImageSharp.Image`1.CopyPixelDataTo*" to access the whole contiguous pixel buffer, for example, to copy the pixel data into an array. For large, multi-megapixel images, however, the data must be accessed and copied per row:
```C#
Rgb32[] pixelArray = new Rgba32[image.Width * image.Height]
image.CopyPixelDataTo(pixelArray);
```

Or:
```C#
byte[] pixelBytes = new byte[image.Width * image.Height * Unsafe.SizeOf<Rgba32>()]
image.CopyPixelDataTo(pixelBytes);
```

### Loading raw pixel data into an `Image<T>`

```C#
int width = ...;
int height = ...;
Rgba32[] rgbaData = GetMyRgbaArray();
using (var image = Image.LoadPixelData(rgbaData, width, height))
{
	// Work with the image
}
```

```C#
int width = ...;
int height = ...;
byte[] rgbaBytes = GetMyRgbaBytes();
using (var image = Image.LoadPixelData<Rgba32>(rgbaBytes, width, height))
{
	// Work with the image
}
```

