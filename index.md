# Six Labors Documentation

Six Labors builds high-performance, cross-platform graphics libraries for modern .NET applications. The libraries are designed for production workloads where image quality, throughput, memory use, correctness, and predictable deployment all matter.

The stack is intentionally layered. ImageSharp is the imaging foundation; ImageSharp.Drawing adds canvas drawing, vector geometry, image composition, text, and optional WebGPU output; ImageSharp.Web turns ImageSharp into ASP.NET Core middleware for web delivery; Fonts provides the text engine for shaping, measuring, layout, and rendering; and PolygonClipper provides robust polygon boolean operations, normalization, and stroke geometry.

Use the articles when you are learning a workflow, making architectural choices, or trying to understand how the pieces fit together. Use the API reference when you need the exact public contract for a type, method, property, option, or enum value.

### [API documentation](api/index.md)

The generated API reference covers public types and members across the Six Labors projects. It is the place to check overloads, constructors, option defaults, enum values, inherited members, extension methods, and namespace organization once you know which feature you are using.

The reference pages are generated from source-level documentation. They describe the observable public API contract; implementation details live in the source repositories and are intentionally not repeated in the reference unless they are part of the behavior developers can rely on.

### How to Use These Docs

Start with the product article that matches the problem you are solving, then move outward:

- Use ImageSharp when you need to load, identify, resize, transform, inspect, convert, encode, or work directly with pixels.
- Add ImageSharp.Drawing when generated output needs shapes, paths, brushes, pens, text, overlays, masks, layers, or GPU-backed drawing targets.
- Use ImageSharp.Web when images are requested through ASP.NET Core and should be resized, encoded, cached, signed, or served as named variants.
- Use Fonts directly when text layout is the product concern: measurement, shaping, fallback, hit testing, caret movement, selection, variable fonts, color fonts, or custom renderers.
- Use PolygonClipper when your application owns polygon data and needs boolean operations, contour cleanup, winding normalization, or generated stroke outlines.

Most real systems use more than one package. A web image pipeline might use ImageSharp.Web for public requests, ImageSharp for encoder policy, ImageSharp.Drawing for watermarks, Fonts for localized labels, and PolygonClipper for complex mask geometry. The docs are organized so those boundaries stay visible.

### Project Documentation

Each library is focused, but the projects are designed to work together as one graphics stack. Start with the product area closest to your task, then follow the linked guides into formats, resizing, drawing, text layout, middleware, or geometry as your workflow expands.

<div class="row products">
    <div class="col mb-5">
        <div class="product">
            <img src="https://raw.githubusercontent.com/SixLabors/Branding/main/icons/imagesharp/sixlabors.imagesharp.svg?sanitize=true" alt="ImageSharp Logo">
            <h5>ImageSharp</h5>
            <p>High-performance managed image processing for .NET with broad format support, color management, and pixel-level control.</p>
            <a href="articles/imagesharp/index.md" class="btn btn-primary">
                Learn More
            </a>
        </div>
    </div>
    <div class="col mb-5">
        <div class="product">
            <img src="https://raw.githubusercontent.com/SixLabors/Branding/main/icons/imagesharp.drawing/sixlabors.imagesharp.drawing.svg?sanitize=true">
            <h5>ImageSharp.Drawing</h5>
            <p>High-performance canvas drawing for ImageSharp with paths, brushes, rich text, composition, and WebGPU output.</p>
            <a href="articles/imagesharp.drawing/index.md" class="btn btn-primary">
                Learn More
            </a>
        </div>
    </div>
    <div class="col mb-5">
        <div class="product">
            <img src="https://raw.githubusercontent.com/SixLabors/Branding/main/icons/imagesharp.web/sixlabors.imagesharp.web.svg?sanitize=true">
            <h5>ImageSharp.Web</h5>
            <p>High-performance on-the-fly image processing, caching, signing, and extensible delivery for ASP.NET Core.</p>
            <a href="articles/imagesharp.web/index.md" class="btn btn-primary">
                Learn More
            </a>
        </div>
    </div>
    <div class="col mb-5">
        <div class="product">
            <img src="https://raw.githubusercontent.com/SixLabors/Branding/main/icons/fonts/sixlabors.fonts.svg?sanitize=true">
            <h5>Fonts</h5>
            <p>High-performance font loading, shaping, layout, measurement, inspection, and custom text rendering for .NET.</p>
            <a href="articles/fonts/index.md" class="btn btn-primary">
                Learn More
            </a>
        </div>
    </div>
    <div class="col mb-5">
        <div class="product">
            <img src="https://raw.githubusercontent.com/SixLabors/Branding/main/icons/polygonclipper/sixlabors.polygonclipper.svg?sanitize=true" alt="PolygonClipper Logo">
            <h5>PolygonClipper</h5>
            <p>High-performance polygon booleans, contour hierarchy, normalization, and stroke-outline geometry for .NET.</p>
            <a href="articles/polygonclipper/index.md" class="btn btn-primary">
                Learn More
            </a>
        </div>
    </div>
</div>

>[!NOTE]
>Documentation for previous releases can be found at <https://docs-v3.sixlabors.com/>.

### Common Starting Points

- New to ImageSharp: start with [ImageSharp Getting Started](articles/imagesharp/gettingstarted.md), then read [Loading, Identifying, and Saving](articles/imagesharp/loadingandsaving.md), [Resizing Images](articles/imagesharp/resize.md), and [Image Formats](articles/imagesharp/imageformats.md).
- Migrating from platform graphics APIs: start with [ImageSharp: Migrating from System.Drawing](articles/imagesharp/migratingfromsystemdrawing.md), [ImageSharp: Migrating from SkiaSharp](articles/imagesharp/migratingfromskiasharp.md), [ImageSharp.Drawing: Migrating from System.Drawing](articles/imagesharp.drawing/migratingfromsystemdrawing.md), or [ImageSharp.Drawing: Migrating from SkiaSharp](articles/imagesharp.drawing/migratingfromskiasharp.md).
- Generating graphics: start with [ImageSharp.Drawing Getting Started](articles/imagesharp.drawing/gettingstarted.md), then move through [Canvas Drawing](articles/imagesharp.drawing/canvas.md), [Paths and Shapes](articles/imagesharp.drawing/pathsandshapes.md), [Brushes and Pens](articles/imagesharp.drawing/brushesandpens.md), and [Drawing Text](articles/imagesharp.drawing/text.md).
- Serving images from ASP.NET Core: start with [ImageSharp.Web Getting Started](articles/imagesharp.web/gettingstarted.md), then read [Configuration and Pipeline](articles/imagesharp.web/configuration.md), [Processing Commands](articles/imagesharp.web/processingcommands.md), and [Securing Requests](articles/imagesharp.web/security.md).
- Working with text: start with [Fonts Loading Fonts and Collections](articles/fonts/gettingstarted.md), then read [Measuring Text](articles/fonts/measuringtext.md), [Prepared Text with TextBlock](articles/fonts/textblock.md), [Text Layout and Options](articles/fonts/textlayout.md), and [Unicode, Code Points, and Graphemes](articles/fonts/unicode.md).
- Working with geometry: start with [PolygonClipper Getting Started](articles/polygonclipper/gettingstarted.md), then read [Polygons, Contours, and Holes](articles/polygonclipper/polygonsandcontours.md), [Boolean Operations](articles/polygonclipper/booleanoperations.md), [Normalization and Winding](articles/polygonclipper/normalization.md), and [Stroking](articles/polygonclipper/stroking.md).

### What the Guides Cover

The article guides are written for implementation work, not just feature discovery. They explain the concepts behind the API, the coordinate systems and lifetime rules that matter in real applications, the defaults that are safe to rely on, and the places where you should make policy explicit.

Across the site you will find guidance for:

- choosing image formats, encoder settings, metadata policy, color-profile handling, and resize samplers;
- building safe upload and conversion pipelines for untrusted images;
- composing vector drawing, source images, text, clipping, layers, transforms, and processors in one ordered drawing pipeline;
- using WebGPU targets when output should stay on the GPU or be presented directly to a native surface;
- shaping and measuring multilingual text with fallback fonts, OpenType features, color fonts, variable fonts, and grapheme-indexed rich text runs;
- configuring web image delivery with request parsing, named presets, HMAC signing, provider selection, cache behavior, and custom processors;
- modelling polygon data, resolving intersections, choosing fill semantics, and generating stroke geometry for downstream renderers.

### [Examples Repository](https://github.com/SixLabors/Samples)

The [Six Labors Samples](https://github.com/SixLabors/Samples) repository contains small, self-contained projects that show common workflows end to end. Use it when you want runnable code beside the conceptual guides and API reference.
