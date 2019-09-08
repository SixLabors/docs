# Resizing Images

Resizing an image is probably the most common processing operation that applications use. ImageSharp offers an incredibly flexible collection of resize options that allow developers to choose sizing algorithms, sampling algorithms, and gamma handling as well as other options.

### The Basics

Resizing an image involves the process of creating and iterating through the pixels of a target image and sampling areas of a source image to choose what color to implement for each pixel. The sampling algorithm chosen affects the target color and can dramatically alter the result. Different samplers are usually chosen based upon the use case - For example `NearestNeigbor` is often used for fast, low quality thumbnail generation, `Lanczos3` for high quality thumbnails due to it's sharpening effect, and `Spline` for high quality enlargment due to it's smoothing effect.

With ImageSharp we default to `Bicubic` as it is a very robust algorithm offering good quality output when both reducing and enlarging images but you can easily set the algorithm when processing.

A full list of supported sampling algorithms can be found [here](xref:SixLabors.ImageSharp.Processing.KnownResamplers):

**Resize the given image using the default `Bicubic` sampler.**

```c#
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using (Image image = Image.Load(inStream))
{
    int width = image.Width / 2;
    int height = image.Height / 2;
    image.Mutate(x => x.Resize(width, height));

    image.Save(outStream);
}
```

**Resize the given image using the `Lanczos3` sampler:**

```c#
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using (Image image = Image.Load(inStream))
{
    int width = image.Width / 2;
    int height = image.Height / 2;
    image.Mutate(x => x.Resize(width, height, KnownResamplers.Lanczos3));

    image.Save(outStream);
}
```

> [!NOTE]
> If you pass `0` as any of the values for `width` and `height` dimensions then ImageSharp will automatically determine the correct opposite dimensions size to preserve the original aspect ratio.

### Advanced Resizing

In addition to basic resizing operations ImageSharp also offers more advanced features.

TODO: Add advanced description and code examples.
