# Processing

The ImageSharp processing API is imperative. This means that the order in which you supply the individual processing operations is the order in which they are are compiled and applied. This allows the API to be very flexible, allowing you to combine processes in any order.

Processing operations are implemented using one of two available method calls. 
[`Mutate`](xref:SixLabors.ImageSharp.Processing.ProcessingExtensions.Mutate*?displayProperty=name) and [`Clone`](xref:SixLabors.ImageSharp.Processing.ProcessingExtensions.Clone*?displayProperty=name)

The difference being that the former applies the given processing operations to the current image whereas the latter applies the operations to a deep copy of the original image.

For example:

**Mutate**

```c#
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using (Image image = Image.Load(inStream)) 
{
    // Resize the given image in place and return it for chaining.
    // 'x' signifies the current image processing context.
    image.Mutate(x => x.Resize(image.Width / 2, image.Height / 2)); 

    image.Save(outStream); 
} // Dispose - releasing memory into a memory pool ready for the next image you wish to process.
```

**Clone**

```c#
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using (Image image = Image.Load(inStream)) 
{
    // Create a deep copy of the given image, resize it, and return it for chaining.
   using (Image copy = image.Clone(x => x.Resize(image.Width / 2, image.Height / 2)))
   {
       copy.Save(outStream); 
   }
} // Dispose - releasing memory into a memory pool ready for the next image you wish to process.
```

### Common Examples

Examples of common operations can be found in the following documentation pages.

- [Resizing](Resize.md) images using different options.
