#Image Formats

### How do I save an image in it's original format after performing an operation?
@"SixLabors.ImageSharp.Image`1?displayProperty=name" (and [](xref:SixLabors.ImageSharp.ImageFrame`1?displayProperty=name)) represents raw bitmap data, stored in a contiguous memory block. It does not "remember" the original image format.
ImageSharp identifies image formats (Jpeg, Png, Gif etc.) by [](xref:SixLabors.ImageSharp.Formats.IImageFormat?displayProperty=name) instances. There are several overloads of [Image.Load](xref:SixLabors.ImageSharp.Image) capable of returning the format as an `out` parameter. It's possible to pass it to `image.Save` after performing the operation:

```C#
IImageFormat format;

using (var image = Image.Load(inputStream, out format))
{
	image.Mutate(c => c.Resize(30, 30));
	image.Save(outputStream, format);
}
```

### Common extension methods to save an image into a stream using a specific format
- `image.SaveAsJpeg()` (shortcut for `image.Save(new JpegEncoder())`)
- `image.SaveAsPng()` (shortcut for `image.Save(new PngEncoder())`)
- `image.SaveAsGif()` (shortcut for `image.Save(new GifEncoder())`)
- `image.SaveAsBmp()` (shortcut for `image.Save(new BmpEncoder())`)

### A deeper overview of ImageSharp format management
Real life image streams are usually stored / transferred in standardized formats like Jpeg, Png, Bmp, Gif etc. An image format is represented by an @"SixLabors.ImageSharp.Formats.IImageFormat?displayProperty=name" implementation. 
  - @"SixLabors.ImageSharp.Formats.IImageDecoder?displayProperty=name" is responsible for decoding streams (and files) in into @"SixLabors.ImageSharp.Image`1?displayProperty=name" instances. ImageSharp can **auto-detect** the image formats of streams/files based on their headers, selecting the correct @"SixLabors.ImageSharp.Formats.IImageFormat?displayProperty=name" (and thus @"SixLabors.ImageSharp.Formats.IImageDecoder?displayProperty=name"). This logic is implemented by @"SixLabors.ImageSharp.Formats.IImageFormatDetector?displayProperty=name"-s.
  - @"SixLabors.ImageSharp.Formats.IImageEncoder?displayProperty=name" is responsible for writing @"SixLabors.ImageSharp.Image`1?displayProperty=name" into a stream using a given format.
  - Decoders/encoders and @"SixLabors.ImageSharp.Formats.IImageFormatDetector?displayProperty=name"-s are mapped to image formats in  @"SixLabors.ImageSharp.Configuration.ImageFormatsManager?displayProperty=name". It's possible to register new formats, or drop existing ones. See [Configuration](Configuration.md) for more details.

### Metadata-only decoding
Sometimes it's worth to efficiently decode image metadata ignoring the memory and CPU heavy pixel information inside the stream. ImageSharp allows this by using one of the several [Image.Identify](xref:SixLabors.ImageSharp.Image) overloads:
```C#
using (IImageInfo imageInfo = Image.Identify(inputStream))
{
	Console.WriteLine($"{imageInfo.Width}x{imageInfo.Height} | BPP: {imageInfo.PixelType.BitsPerPixel}");
}
```

See @"SixLabors.ImageSharp.IImageInfo?displayProperty=name" for more details about the identification result. Notice that @"SixLabors.ImageSharp.Image`1?displayProperty=name" also implements `IImageInfo`!

### Working with encoders
Image formats are usually defined by complex standards allowing multiple representations for the same image. ImageSharp allows parameterizing the encoding process:
[](xref:SixLabors.ImageSharp.Formats.IImageEncoder?displayProperty=name) implementations are stateless, lightweigh **parametric** objects. This means that if you want to encode a Png in a specific way (eg. changing the compression level), you need to new-up a custom @"SixLabors.ImageSharp.Formats.Png.PngEncoder?displayProperty=name" instance.

Choosing the right encoder parameters allows to balance between conflicting tradeoffs:
- Image file size
- Encoder speed
- Image quality

#### Encoding Jpeg-s
Properties on @"SixLabors.ImageSharp.Formats.Jpeg.JpegEncoder?displayProperty=name":
- @"SixLabors.ImageSharp.Formats.Jpeg.JpegEncoder.Quality?text=Quality": quality value between 0 and 100 as defined in the standard. The default value is `75`. By reducing `Quality` you loose information resulting in a smaller file size.
- @"SixLabors.ImageSharp.Formats.Jpeg.JpegEncoder.Subsample?text=Subsample": [Chroma subsampling](https://en.wikipedia.org/wiki/Chroma_subsampling) - Affects output image quality. The default value is `null` (undefined), which means that it's automatically chosen based on `Quality`: `Ratio444` for `Quality >= 91`, `Ratio420` otherwise.
- `IgnoreMetadata`: do not write information stored in [image.MetaData](xref:SixLabors.ImageSharp.Image`1.MetaData) (like Exif/ICC profile) to the output stream. Can lead to smaller output.

Sample code for producing smaller, low quality Jpegs:
```C#
var encoder = new JpegEncoder()
{
	Quality = 40,
	IgnoreMetadata = true
};
image.Save(encoder);
```

Best quality Jpeg / largest filesize:
```C#
image.Save(new JpegEncoder()
{
	Quality = 100
});
```

### Encoding Png-s
TODO: @JimBobSquarePants ?
