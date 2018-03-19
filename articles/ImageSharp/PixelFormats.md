# Pixel Formats

## Why is [](xref:SixLabors.ImageSharp.Image`1?displayProperty=name) a generic class?

We are supporting multiple pixel formats just like `System.Drawing` does. However, unlike their closed [PixelFormat](https://docs.microsoft.com/en-us/dotnet/api/system.drawing.imaging.pixelformat) enumeration, our solution is extensible.
A pixel is basically a small value type object (struct), describing the color value at a given point. An image is essentially a **generic** 2D array of pixels stored in a contigous memory block.

## Ok, how do I create an image with a pixel type other, than `Rgba32`?

Have a look at the various pixel types available under [](xref:SixLabors.ImageSharp.PixelFormats#structs)! After picking the pixel type of your choice, use it as a generic argument for [](xref:SixLabors.ImageSharp.Image`1?displayProperty=name), eg. by instantiating `Image<Bgr24>`.

## Can I define my own pixel type?

Yes, you just need to define a struct implementing [](xref:SixLabors.ImageSharp.PixelFormats.IPixel`1) and use it as a generic argument for [](xref:SixLabors.ImageSharp.Image`1?displayProperty=name).

## I have a monochrome image and I want to store it in a compact way. Can I store a pixel on a single bit?

No. Our architecture does not allow sub-byte pixel types at the moment. This feature is incredibly complex to implement, and you are going to pay the price of the low memory footprint in processing speed / CPU load.

## Can I decode into formats like [CMYK](https://en.wikipedia.org/wiki/CMYK_color_model) or [CIELAB](https://en.wikipedia.org/wiki/Lab_color_space)?

Unfortunately it's not possible at the moment. **TODO:** @JimBobSquarePants can you provide a better explanation here, I forgot the proper reasoning :)