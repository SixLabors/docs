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
- Qoi

ImageSharp's API however, is designed to support extension by the registration of additional [`IImageFormat`](xref:SixLabors.ImageSharp.Formats.IImageFormat) implementations.

### Loading and Saving Specific Image Formats

[`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1) represents raw pixel data, stored in a contiguous memory block. It does not "remember" the original image format.

ImageSharp identifies image formats (Jpeg, Png, Gif etc.) by [`IImageFormat`](xref:SixLabors.ImageSharp.Formats.IImageFormat) instances. Decoded images store the format in the [DecodedImageFormat](xref:SixLabors.ImageSharp.Metadata.ImageMetadata.DecodedImageFormat) within the image metadata. It is possible to pass that value to `image.Save` after performing the operation:

```C#
using (var image = Image.Load(inputStream))
{
    image.Mutate(c => c.Resize(30, 30));
    image.Save(outputStream, image.Metadata.DecodedImageFormat);
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
- `image.SaveAsQoi()` (shortcut for `image.Save(new QoiEncoder())`)

### A Deeper Overview of ImageSharp Format Management

Real life image streams are usually stored / transferred in standardized formats like Jpeg, Png, Bmp, Gif etc. An image format is represented by an [`IImageFormat`](xref:SixLabors.ImageSharp.Formats.IImageFormat) implementation.

- [`ImageDecoder`](xref:SixLabors.ImageSharp.Formats.ImageDecoder) is responsible for decoding streams (and files) in into [`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1). ImageSharp can **auto-detect** the image formats of streams/files based on their headers, selecting the correct [`IImageFormat`](xref:SixLabors.ImageSharp.Formats.IImageFormat) (and thus [`ImageDecoder`](xref:SixLabors.ImageSharp.Formats.ImageDecoder)). This logic is implemented by [`IImageFormatDetector`](xref:SixLabors.ImageSharp.Formats.IImageFormatDetector)'s.
- [`ImageEncoder`](xref:SixLabors.ImageSharp.Formats.ImageEncoder) is responsible for writing [`Image<TPixel>`](xref:SixLabors.ImageSharp.Image`1) into a stream using a given format.
- Decoders/encoders and [`IImageFormatDetector`](xref:SixLabors.ImageSharp.Formats.IImageFormatDetector)'s are mapped to image formats in [`ImageFormatsManager`](xref:SixLabors.ImageSharp.Configuration.ImageFormatsManager). It's possible to register new formats, or drop existing ones. See [Configuration](configuration.md) for more details.

### Working with Decoders

The behavior of the various decoders during the decoding process can be controlled by passing [`DecoderOptions`](xref:SixLabors.ImageSharp.Formats.DecoderOptions) instances to our general `Load` APIs. These options contain means to control metadata handling, the decoded frame count, and properties to allow directly decoding the encoded image to a given target size.

### Specialized Decoding

In addition to the general decoding API we offer additional specialized decoding options [`ISpecializedDecoderOptions`](xref:SixLabors.ImageSharp.Formats.ISpecializedDecoderOptions) that can be accessed directly against [`ISpecializedDecoder<T>`](xref:SixLabors.ImageSharp.Formats.ISpecializedImageDecoder`1) instances which provide further options for decoding.

### Metadata-only Decoding

Sometimes it's worth to efficiently decode image metadata ignoring the memory and CPU heavy pixel information inside the stream. ImageSharp allows this by using one of the several [Image.Identify](xref:SixLabors.ImageSharp.Image) overloads:

```C#
ImageInfo imageInfo = Image.Identify(inputStream);
Console.WriteLine($"{imageInfo.Width}x{imageInfo.Height} | BPP: {imageInfo.PixelType.BitsPerPixel}");
```

See [`ImageInfo`](xref:SixLabors.ImageSharp.ImageInfo) for more details about the identification result.

### Working with Encoders

Image formats are usually defined by complex standards allowing multiple representations for the same image. ImageSharp allows parameterizing the encoding process:
[`ImageEncoder`](xref:SixLabors.ImageSharp.Formats.ImageEncoder) implementations are stateless, lightweight **parametric** objects. This means that if you want to encode a Png in a specific way (eg. changing the compression level), you need to new-up a custom [`PngEncoder`](xref:SixLabors.ImageSharp.Formats.Png.PngEncoder) instance.

Choosing the right encoder parameters allows to balance between conflicting tradeoffs:

- Image file size
- Encoder speed
- Image quality
  
Each encoder offers options specific to the image format it represents.
