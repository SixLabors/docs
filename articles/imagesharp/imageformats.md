# Image Formats

Out of the box ImageSharp supports the following image formats:

- Bmp
- Gif
- Jpeg
- Pbm
- Png
- Tiff
- Tga
- WebP

ImageSharp's API however, is designed to support extension by the registration of additional [`IImageFormat`](xref:SixLabors.ImageSharp.Formats.IImageFormat) implementations.

### Loading and Saving Specific Image Formats

[`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1) represents raw pixel data, stored in a contiguous memory block. It does not "remember" the original image format.

ImageSharp identifies image formats (Jpeg, Png, Gif etc.) by [`IImageFormat`](xref:SixLabors.ImageSharp.Formats.IImageFormat) instances. There are several overloads of [`Image.Load`](xref:SixLabors.ImageSharp.Image) capable of returning the format as an `out` parameter. It's possible to pass that value to `image.Save` after performing the operation:

```C#
IImageFormat format;

using (var image = Image.Load(inputStream, out format))
{
    image.Mutate(c => c.Resize(30, 30));
    image.Save(outputStream, format);
}
```

> [!NOTE]
> ImageSharp provides common extension methods to save an image into a stream using a specific format.

- `image.SaveAsBmp()` (shortcut for `image.Save(new BmpEncoder())`)
- `image.SaveAsGif()` (shortcut for `image.Save(new GifEncoder())`)
- `image.SaveAsJpeg()` (shortcut for `image.Save(new JpegEncoder())`)
- `image.SaveAsPbm()` (shortcut for `image.Save(new PbmEncoder())`)
- `image.SaveAsPng()` (shortcut for `image.Save(new PngEncoder())`)
- `image.SaveAsTga()` (shortcut for `image.Save(new TgaEncoder())`)
- `image.SaveAsTiff()` (shortcut for `image.Save(new TiffEncoder())`)
- `image.SaveAsWebp()` (shortcut for `image.Save(new WebpEncoder())`)

### A Deeper Overview of ImageSharp Format Management

Real life image streams are usually stored / transferred in standardized formats like Jpeg, Png, Bmp, Gif etc. An image format is represented by an [`IImageFormat`](xref:SixLabors.ImageSharp.Formats.IImageFormat) implementation.

- [`IImageDecoder`](xref:SixLabors.ImageSharp.Formats.IImageDecoder) is responsible for decoding streams (and files) in into [`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1). ImageSharp can **auto-detect** the image formats of streams/files based on their headers, selecting the correct [`IImageFormat`](xref:SixLabors.ImageSharp.Formats.IImageFormat) (and thus [`IImageDecoder`](xref:SixLabors.ImageSharp.Formats.IImageDecoder)). This logic is implemented by [`IImageFormatDetector`](xref:SixLabors.ImageSharp.Formats.IImageFormatDetector)'s.
- [`IImageEncoder`](xref:SixLabors.ImageSharp.Formats.IImageEncoder) is responsible for writing [`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1) into a stream using a given format.
- Decoders/encoders and [`IImageFormatDetector`](xref:SixLabors.ImageSharp.Formats.IImageFormatDetector)'s are mapped to image formats in [`ImageFormatsManager`](xref:SixLabors.ImageSharp.Configuration.ImageFormatsManager). It's possible to register new formats, or drop existing ones. See [Configuration](configuration.md) for more details.

### Metadata-only Decoding

Sometimes it's worth to efficiently decode image metadata ignoring the memory and CPU heavy pixel information inside the stream. ImageSharp allows this by using one of the several [Image.Identify](xref:SixLabors.ImageSharp.Image) overloads:

```C#
IImageInfo imageInfo = Image.Identify(inputStream);
Console.WriteLine($"{imageInfo.Width}x{imageInfo.Height} | BPP: {imageInfo.PixelType.BitsPerPixel}");
```

See [`IImageInfo`](xref:SixLabors.ImageSharp.IImageInfo) for more details about the identification result. Note that [`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1) also implements `IImageInfo`.

### Working with Encoders

Image formats are usually defined by complex standards allowing multiple representations for the same image. ImageSharp allows parameterizing the encoding process:
[`IImageEncoder`](xref:SixLabors.ImageSharp.Formats.IImageEncoder) implementations are stateless, lightweight **parametric** objects. This means that if you want to encode a Png in a specific way (eg. changing the compression level), you need to new-up a custom [`PngEncoder`](xref:SixLabors.ImageSharp.Formats.Png.PngEncoder) instance.

Choosing the right encoder parameters allows to balance between conflicting tradeoffs:

- Image file size
- Encoder speed
- Image quality
  
Each encoder offers options specific to the image format it represents.
