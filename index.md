# Welcome to Six Labors Documentation.

We aim to provide modern, cross-platform, incredibly powerful yet beautifully simple graphics libraries. Built against .NET Standard, our libraries can be used in device, cloud, and embedded/IoT scenarios.

You can find tutorials, examples and API details covering all Six Labors projects.

### [API documentation](api/index.md)

Detailed documentation for the entire API available across our projects.

### Articles and Supplementary Documentation 

Our graphics libraries are split into different projects. They cover different concerns separately, but there is strong cohesion in order to provide the best developer experience.

You can find documentation for each project in the links below.

<div class="row projects">
    <div class="col-sm-6 col-md-3">
        <a href="articles/imagesharp" class="project">
            <div class="text-center">
                <img src="https://raw.githubusercontent.com/SixLabors/Branding/master/icons/imagesharp/sixlabors.imagesharp.svg?sanitize=true" alt="ImageSharp Logo">
            </div>
            <h3>ImageSharp</h3>
            <p>Fully featured 2D graphics API</p>
            <span class="a">Learn More &gt;</span>
        </a>
    </div>
    <div class="col-sm-6 col-md-3">
        <a href="articles/imagesharp.drawing" class="project">
            <div class="text-center">
                <img src="https://raw.githubusercontent.com/SixLabors/Branding/master/icons/imagesharp.drawing/sixlabors.imagesharp.drawing.svg?sanitize=true">
            </div>
            <h3>ImageSharp.Drawing</h3>
            <p>2D polygon Manipulation and Drawing.</p>
            <span class="a">Learn More &gt;</span>
        </a>
    </div>
    <div class="col-sm-6 col-md-3">
        <a href="articles/imagesharp.web" class="project">
            <div class="text-center">
                <img src="https://raw.githubusercontent.com/SixLabors/Branding/master/icons/imagesharp.web/sixlabors.imagesharp.web.svg?sanitize=true">
            </div>
            <h3>ImageSharp.Web</h3>
            <p>ASP.NET Core Image Manipulation Middleware.</p>
            <span class="a">Learn More &gt;</span>
        </a>
    </div>
    <div class="col-sm-6 col-md-3">
        <a href="articles/fonts" class="project">
            <div class="text-center">
                <img src="https://raw.githubusercontent.com/SixLabors/Branding/master/icons/fonts/sixlabors.fonts.svg?sanitize=true">
            </div>
            <h3>Fonts</h3>
            <p>Font Loading and Drawing API.</p>
            <span class="a">Learn More &gt;</span>
        </a>
    </div>
</div>

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

### [SixLabors.ImageSharp](https://github.com/SixLabors/ImageSharp)

- Contains the generic @"SixLabors.ImageSharp.Image`1?displayProperty=name" class, PixelFormats, Configuration, and other core functionality.
- The [](xref:SixLabors.ImageSharp.Formats.IImageFormat?displayProperty=name) interface, Jpeg, Png, Bmp, and Gif formats.
- The image processor infrastructure, `.Mutate()` and `.Clone()`
  - Transform methods like Resize, Crop, Skew, Rotate - Anything that alters the dimensions of the image.
  - Non-transform methods like Gaussian Blur, Pixelate, Edge Detection - Anything that maintains the original image dimensions.

### [SixLabors.Fonts](https://github.com/SixLabors/Fonts)

Font loading and drawing library. Text drawing in `SixLabors.ImageSharp.Drawing` is based on this library.

### SixLabors.ImageSharp.Drawing

- Shape primitives and geometry API.
- Brushes and various drawing algorithms, including drawing images.
- Various vector drawing methods for drawing paths, polygons etc.
- Text drawing (based on [SixLabors.Fonts](https://github.com/SixLabors/Fonts))

### [SixLabors.ImageSharp.Web](https://github.com/SixLabors/ImageSharp.Web)
ASP.NET-Core middleware for image manipulation.
