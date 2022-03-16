# Six Labors Documentation.

We aim to provide modern, cross-platform, incredibly powerful yet beautifully simple graphics libraries. Built against .NET Standard, our libraries can be used in device, cloud, and embedded/IoT scenarios.

You can find tutorials, examples and API details covering all Six Labors projects.

>[!NOTE]
>Documentation for previous releases can be found at https://docs-v1.sixlabors.com/.

### [API documentation](api/index.md)

Detailed documentation for the entire API available across our projects.

### [Conceptual Documentation](articles/imagesharp/index.md)

Our graphics libraries are split into different projects. They cover different concerns separately, but there is strong cohesion in order to provide the best developer experience.

You can find documentation for each project in the links below.

<div class="row products">
    <div class="col-sm-6 col-md-3">
        <div class="product">
            <img src="https://raw.githubusercontent.com/SixLabors/Branding/main/icons/imagesharp/sixlabors.imagesharp.svg?sanitize=true" alt="ImageSharp Logo">
            <h5>ImageSharp</h5>
            <p>Fully featured 2D graphics library.</p>
            <a href="articles/imagesharp/index.md" class="btn btn-primary">
                Learn More
            </a>
        </div>
    </div>
    <div class="col-sm-6 col-md-3">
        <div class="product">
            <img src="https://raw.githubusercontent.com/SixLabors/Branding/main/icons/imagesharp.drawing/sixlabors.imagesharp.drawing.svg?sanitize=true">
            <h5>ImageSharp.Drawing</h5>
            <p>2D polygon Manipulation and Drawing.</p>
            <a href="articles/imagesharp.drawing/index.md" class="btn btn-primary">
                Learn More
            </a>
        </div>
    </div>
    <div class="col-sm-6 col-md-3">
        <div class="product">
            <img src="https://raw.githubusercontent.com/SixLabors/Branding/main/icons/imagesharp.web/sixlabors.imagesharp.web.svg?sanitize=true">
            <h5>ImageSharp.Web</h5>
            <p>ASP.NET Core Image Manipulation Middleware.</p>
            <a href="articles/imagesharp.web/index.md" class="btn btn-primary">
                Learn More
            </a>
        </div>
    </div>
    <div class="col-sm-6 col-md-3">
        <div class="product">
            <img src="https://raw.githubusercontent.com/SixLabors/Branding/main/icons/fonts/sixlabors.fonts.svg?sanitize=true">
        <h5>Fonts</h5>
        <p>Font Loading and Drawing API.</p>
        <a href="articles/fonts/index.md" class="btn btn-primary">
            Learn More
        </a>
        </div>
    </div>
</div>

### [Examples Repository](https://github.com/SixLabors/Samples)

We have implemented short self-contained sample projects for a few specific use cases, including:

1. [Avatar with rounded corners](https://github.com/SixLabors/Samples/tree/main/ImageSharp/AvatarWithRoundedCorner)<br/>
   Crops rounded corners of a source image leaving a nice rounded avatar.
2. [Draw watermark on image](https://github.com/SixLabors/Samples/tree/main/ImageSharp/DrawWaterMarkOnImage)<br/>
   Draw water mark over an image automaticaly scaling the font size to fill the available space.
3. [Change default encoder options](https://github.com/SixLabors/Samples/tree/main/ImageSharp/ChangeDefaultEncoderOptions)<br/>
   Provides an example on how you go about switching out the registered encoder for a file format and changing its default options in the process.
4. [Draw text along a path](https://github.com/SixLabors/Samples/tree/main/ImageSharp/DrawingTextAlongAPath)<br/>
   Draw some text following the contours of a path.
