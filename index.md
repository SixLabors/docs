# Welcome to Six Labors documentation!

You can find tutorials, examples and API details covering all Six Labors projects.

### [Articles](articles/intro.md)
Examples and explanatory documentation about our API.

### [API documentation](api/index.md)
Detailed documentation for the entire API available across our projects.

### [Examples repository](https://github.com/SixLabors/Samples)
We have implemented short self-contained sample projects for a few specific use cases, including:
- [Avatar with rounded corners](https://github.com/SixLabors/Samples/tree/master/ImageSharp/AvatarWithRoundedCorner)
- [Draw watermark on image](https://github.com/SixLabors/Samples/tree/master/ImageSharp/DrawWaterMarkOnImage)
- [Change default encoder options](https://github.com/SixLabors/Samples/tree/master/ImageSharp/ChangeDefaultEncoderOptions)
- [Draw text along a path](https://github.com/SixLabors/Samples/tree/master/ImageSharp/DrawingTextAlongAPath)

# SixLabors Projects
Our graphics libraries are split into different projects. They cover different concerns separately, but there is strong cohesion.

### [SixLabors.Core](https://github.com/SixLabors/Core)
Common classes and structs used aross our projects including [](xref:SixLabors.Primitives)

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
