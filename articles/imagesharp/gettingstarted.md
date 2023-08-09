# Getting Started

>[!NOTE]
>The official guide assumes intermediate level knowledge of C# and .NET. If you are totally new to .NET development, it might not be the best idea to jump right into a framework as your first step - grasp the basics then come back. Prior experience with other languages and frameworks helps, but is not required.

### ImageSharp Images

ImageSharp provides several classes for storing pixel data:

- @"SixLabors.ImageSharp.Image" A pixel format agnostic image container used for general processing operations.
- @"SixLabors.ImageSharp.Image`1" A generic image container that allows per-pixel access.

In addition there are classes available that represent individual image frames:

- @"SixLabors.ImageSharp.ImageFrame" A pixel format agnostic image frame container.
- @"SixLabors.ImageSharp.ImageFrame`1" A generic image frame container that allows per-pixel access.
- @"SixLabors.ImageSharp.IndexedImageFrame`1" A generic image frame used for indexed image pixel data where each pixel buffer value represents an index in a color palette.

For more information on pixel formats please see the following [documentation](pixelformats.md).

### Loading and Saving Images

ImageSharp provides several options for loading and saving images to cover different scenarios. The library automatically detects the source image format upon load and it is possible to dictate which image format to save an image pixel data to.  

```c#
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

// Open the file automatically detecting the file type to decode it.
// Our image is now in an uncompressed, file format agnostic, structure in-memory as
// a series of pixels.
// You can also specify the pixel format using a type parameter (e.g. Image<Rgba32> image = Image.Load<Rgba32>("foo.jpg"))
using (Image image = Image.Load("foo.jpg")) 
{
    // Resize the image in place and return it for chaining.
    // 'x' signifies the current image processing context.
    image.Mutate(x => x.Resize(image.Width / 2, image.Height / 2)); 

    // The library automatically picks an encoder based on the file extension then
    // encodes and write the data to disk.
    // You can optionally set the encoder to choose.
    image.Save("bar.jpg"); 
} // Dispose - releasing memory into a memory pool ready for the next image you wish to process.
```

In this very basic example you are actually utilizing several core ImageSharp features:
- [Image Formats](imageformats.md) by loading and saving an image.
- [Image Processors](processing.md) by calling `Mutate()` and `Resize()`

### Identify image

If you are only interested in the image dimensions or metadata of the image, you can achieve this with `Image.Identify`.
This will avoid decoding the complete image and therfore be much faster.

For example:

```c#
ImageInfo imageInfo = Image.Identify(@"image.jpg");
Console.WriteLine($"Width: {imageInfo.Width}");
Console.WriteLine($"Height: {imageInfo.Height}");
```

### Image metadata

To retrieve image metadata, either load an image with `Image.Load` or use `Image.Identify` (this will not decode the complete image, just the metadata). In both cases you will get the image dimensions and additional the the image
metadata in the `Metadata` property.

This will contain the following profiles, if present in the image:

- ExifProfile
- IccProfile
- IptcProfile
- XmpProfile

##### Format specific metadata

Further there are format specific metadata, which can be obtained for example like this:

```c#
Image image = Image.Load(@"image.jpg");
ImageMetadata imageMetaData = image.Metadata;

// Syntactic sugar for imageMetaData.GetFormatMetadata(JpegFormat.Instance)
JpegMetadata jpegData = imageMetaData.GetJpegMetadata();
```

And similar for the other supported formats.

### Initializing New Images

```c#
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

int width = 640;
int height = 480;

// Creates a new image with empty pixel data. 
using(Image<Rgba32> image = new(width, height)) 
{
  // Do your drawing in here...

} // Dispose - releasing memory into a memory pool ready for the next image you wish to process.
```
In this example you are utilizing the following core ImageSharp feature:
- [Pixel Formats](pixelformats.md) by using `Rgba32`

### API Cornerstones
The easiest way to work with ImageSharp is to utilize our extension methods:
- @"SixLabors.ImageSharp" for basic operations and primitives.
- @"SixLabors.ImageSharp.Processing" for `Mutate()` and `Clone()`. All the processing extensions (eg. `Resize(...)`) live within this namespace. 

### Performance
Achieving near-to-native performance is a major goal for the SixLabors team, and thanks to the improvements brought by the RyuJIT runtime, it's no longer mission impossible. We have made great progress and are constantly working on improvements.

At the moment it's pretty hard to define fair benchmarks comparing GDI+ (aka. `System.Drawing` on Windows) and ImageSharp, because of the differences between the algorithms being used. Generally speaking, we are faster and more feature rich, producing better quality output.

If you are experiencing a significant performance gap between System.Drawing and ImageSharp for basic use-cases, there is a high chance that essential SIMD optimizations are not utilized. 

A few troubleshooting steps to try:

- Check the value of [Vector.IsHardwareAccelerated](https://docs.microsoft.com/en-us/dotnet/api/system.numerics.vector.ishardwareaccelerated?view=netcore-2.1&viewFallbackFrom=netstandard-2.0#System_Numerics_Vector_IsHardwareAccelerated). If the output is false, it means there is no SIMD support in your runtime!
