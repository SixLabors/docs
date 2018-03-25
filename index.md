# Welcome to Six Labors documentation!

We aim to provide modern, incredibly powerful yet beautifully simple cross-platform graphics libraries. Built against .NET Standard, our libraries can be used in device, cloud, and embedded/IoT scenarios. You can find tutorials, examples and API details covering all Six Labors projects.

### [Articles](articles/intro.md)
Examples, quick-start guides and FAQ-s about our API. **This is the recommended place to go for newcomers.**

### [API documentation](api/index.md)
Detailed documentation for the entire API available across our projects.

### [Examples repository](https://github.com/SixLabors/Samples)
We have implemented short self-contained sample projects for a few specific use cases, including:
1. [Avatar with rounded corners](https://github.com/SixLabors/Samples/tree/master/ImageSharp/AvatarWithRoundedCorner)<br/>
  Crops rounded corners of a source image leaving a nice rounded avatar.
2. [Draw watermark on image](https://github.com/SixLabors/Samples/tree/master/ImageSharp/DrawWaterMarkOnImage)<br/>
  Draw water mark over an image automaticaly scaling the font size to fill the avalible space.
3. [Change default encoder options](https://github.com/SixLabors/Samples/tree/master/ImageSharp/ChangeDefaultEncoderOptions)<br/>
  Provides an example on how you go about switching out the registered encoder for a file format and changing its default options in the process.
4. [Draw text along a path](https://github.com/SixLabors/Samples/tree/master/ImageSharp/DrawingTextAlongAPath)<br/>
  Draw some text following the contours of a path.

# SixLabors Projects
Our graphics libraries are split into different projects. They cover different concerns separately, but there is strong cohesion in order to provide the best developer experience.

### [SixLabors.Core](https://github.com/SixLabors/Core)
Common classes and structs used across our projects including [](xref:SixLabors.Primitives).

### [SixLabors.ImageSharp](https://github.com/SixLabors/ImageSharp)
- Contains the generic [](xref:SixLabirs.Image`1?displayProperty=name) class, PixelFormats, Configuration, and other core functionality.
- The [](xref:SixLabors.ImageSharp.Formats.IImageFormat?displayProperty=name) interface, Jpeg, Png, Bmp, and Gif formats.
- The image processor infrastructure, `.Mutate()` and `.Clone()`
  - Transform methods like Resize, Crop, Skew, Rotate - Anything that alters the dimensions of the image.
  - Non-transform methods like Gaussian Blur, Pixelate, Edge Detection - Anything that maintains the original image dimensions.

### [SixLabors.Shapes](https://github.com/SixLabors/Shapes)
Net standard geometry/shape manipulation library, can be used to instantiate various shapes allowing operations like merge, split, intersections etc.
The SixLabors.Drawing library is based on Shapes.

### [SixLabors.Fonts](https://github.com/SixLabors/Fonts)
Font loading and drawing library. Text drawing in `SixLabors.ImageSharp.Drawing` is based on this library.

### SixLabors.ImageSharp.Drawing
- Brushes and various drawing algorithms, including drawing images.
- Various vector drawing methods for drawing paths, polygons etc.
- Text drawing (based on [SixLabors.Fonts](https://github.com/SixLabors/Fonts))

### [SixLabors.ImageSharp.Web](https://github.com/SixLabors/ImageSharp.Web)
ASP.NET-Core middleware for image manipulation.
