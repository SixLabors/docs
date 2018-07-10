# Getting started with ImageSharp
So you've gone and added the ImageSharp packages and you've been left with the question "so what to I do now?" hopefully some of these snippets can answer that question for you, or at least get you started.

### Scaling a jpeg by half and save it again as a jpg
In this very basic example you are actually utilizing a bunch of core ImageSharp features:
- [Pixel Formats](PixelFormats.md) by using `Rgba32`
- [Image Formats](ImageFormats.md) by loading and saving a jpeg image
- [Image Processors](Processing.md) by calling `Mutate()` and `Resize()`

```c#
using (Image<Rgba32> image = Image.Load("foo.jpg")) //open the file and detect the file type and decode it
{
 // image is now in a file format agnostic structure in memory as a series of Rgba32 pixels
 image.Mutate(ctx=>ctx.Resize(image.Width / 2, image.Height / 2)); // resize the image in place and return it for chaining
 image.Save("bar.jpg"); // based on the file extension pick an encoder then encode and write the data to disk
} // dispose - releasing memory into a memory pool ready for the next image you wish to process
```

### How do I create a blank image for drawing on?
```c#
int width = 640;
int height = 480;
using(Image<Rgba32> image = new Image<Rgba32>(width, height)) // creates a new image with all the pixels set as transparent 
{
 // do your drawing in here...
} // dispose - releasing memory into a memory pool ready for the next image you wish to process
```

### API Style
The easiest way to work with ImageSharp is to utilize our extension methods:
- @"SixLabors.ImageSharp.ImageExtensions" for basic stuff
- @"SixLabors.ImageSharp.Processing.ProcessingExtensions" for `Mutate()` and `Clone()` 
- All the processing extensions (eg. `Resize(...)`) are living within the @"SixLabors.ImageSharp.Processing" namespace. 
If you want to do image processing work, make sure you are `using` this namespace in your code!

### Why is [](xref:SixLabors.ImageSharp.Image`1?displayProperty=name) a generic class?
An image is essentially a **generic 2D array of pixels** stored in a contiguous memory block. Check out the [Pixel Formats](PixelFormats.md) article for more details!

### Performance
Achieving near-to-native performance is a major goal for the SixLabors team, and thanks to the improvements brought by the RyuJIT runtime, it's no longer mission impossible. We are constantly working on improvements.

At the moment it's pretty hard to define fair benchmarks comparing GDI+ (aka. `System.Drawing` on Windows) and ImageSharp, because of the differences between the algorithms being used. Generally speaking, we are more feature rich, producing better quality. We hope we can match the corresponging algorithm parameters, and present some very specific benchmark results soon.

If you are experienceing a significant performance gap between System.Drawing and ImageSharp for basic use-cases, there is a high chance that essential SIMD optimizations are not utilized. 

A few troubleshooting steps to try:

- Check the value of [Vector.IsHardwareAccelerated](https://docs.microsoft.com/en-us/dotnet/api/system.numerics.vector.ishardwareaccelerated?view=netcore-2.1&viewFallbackFrom=netstandard-2.0#System_Numerics_Vector_IsHardwareAccelerated). If the output is false, it means there is no SIMD support in your runtime!
- Make sure your code runs on 64bit! Older .NET Framework versions are using the legacy runtime on 32 bits, having no built-in SIMD support.