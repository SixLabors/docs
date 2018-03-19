# Getting started with ImageSharp
So you've gone and added the ImageSharp packages and you've been left with the question "so what to I do now?" hopefully some of these snippets can answer that question for you, or at least get you started.

### Scaling a jpeg by half and save it again as a jpg
In this very basic example you are actually utilizing a bunch of ImageSharp features:
- [Pixel Formats](PixelFormats.md) by using `Rgba32`
- [Image Formats](ImageFormats.md) by loading and saving a jpeg image
- [Image Processors](Processing.md) by calling `Mutate()` and `Resize()`

```c#
using (Image<Rgba32> image = Image.Load("foo.jpg")) //open the file and detect the file type and decode it
{
 // image is now in a file format agnositic structure in memory as a series of Rgba32 pixels
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

### Why is [](xref:SixLabors.ImageSharp.Image`1?displayProperty=name) a generic class?
Check out the [Pixel Formats](PixelFormats.md) article for the answer!