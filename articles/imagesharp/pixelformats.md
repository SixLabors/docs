# Pixel Formats

### Why is @"SixLabors.ImageSharp.Image`1" a generic class?

We support multiple pixel formats just like _System.Drawing_ does. However, unlike their closed [PixelFormat](https://docs.microsoft.com/en-us/dotnet/api/system.drawing.imaging.pixelformat) enumeration, our solution is extensible.
A pixel is basically a small value object (struct), describing the color at a given point according to a pixel model we call Pixel Format. `Image<TPixel>` represents a pixel graphic bitmap stored as a **generic, contiguous memory block** of pixels, of size `image.Width * image.Height`.

In the case of multi-frame images (usually decoded from gifs) multiple bitmaps are stored in `image.Frames` as `ImageFrame<TPixel>` instances.

### Choosing Pixel Formats

Have a look at the various pixel formats available under @"SixLabors.ImageSharp.PixelFormats#structs" After picking the pixel format of your choice, use it as a generic argument for [](xref:SixLabors.ImageSharp.Image`1?displayProperty=name), eg. by instantiating `Image<Bgr24>`.

### Defining Custom Pixel Formats

Yes, you just need to define a struct implementing [](xref:SixLabors.ImageSharp.PixelFormats.IPixel`1) and use it as a generic argument for [](xref:SixLabors.ImageSharp.Image`1?displayProperty=name).
However, at the moment you won't be able to provide SIMD-optimized batched pixel-conversion primitives. We need to open up the [](xref:SixLabors.ImageSharp.PixelFormats.PixelOperations`1) API to allow that.

### I have a monochrome image and I want to store it in a compact way. Can I store a pixel on a single bit?

No. Our architecture does not allow sub-byte pixel formats at the moment. This feature is incredibly complex to implement, and you are going to pay the price of the low memory footprint in processing speed / CPU load.

### Can I decode into pixel formats like [CMYK](https://en.wikipedia.org/wiki/CMYK_color_model) or [CIELAB](https://en.wikipedia.org/wiki/Lab_color_space)?

Unfortunately it's not possible and is unlikely to be in the future. Many image processing operations expect the pixels to be laid out in-memory in RGBA format. To manipulate images in exotic colorspaces we would have to translate each pixel to-and-from the colorspace multiple times, which would result in unusable performance and a loss of color information.
