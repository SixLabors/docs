# Configuration

ImageSharp contains a @"SixLabors.ImageSharp.Configuration" class designed to allow the configuration of application wide settings.
This class provides a range of configuration opportunities that cover format support, memory and parallelization settings and more.

@"SixLabors.ImageSharp.Configuration.Default" is a shared singleton that is used to configure the default behavior of the ImageSharp library but it is possible to provide your own instances depended upon your required setup. 

### Injection Points. 

The @"SixLabors.ImageSharp.Configuration" class can be injected in several places within the API to allow overriding global values. This provides you with the means to apply fine grain control over your processing activity to cater for your environment.

- The @"SixLabors.ImageSharp.Image" and @"SixLabors.ImageSharp.Image`1" constructors.
- The @"SixLabors.ImageSharp.Image.Load*" methods and variants.
- The @"SixLabors.ImageSharp.Processing.ProcessingExtensions.Mutate*" and @"SixLabors.ImageSharp.Processing.ProcessingExtensions.Clone*" methods.

### Configuring ImageFormats

As mentioned in [Image Formats](imageformats.md) it is possible to configure your own format collection for the API to consume.
For example, if you wanted to restrict the library to support a specific collection of formats you would configure the library as follows:

```c#
var configuration = new Configuration(
    new PngConfigurationModule(),
    new JpegConfigurationModule(),
    new GifConfigurationModule(),
    new BmpConfigurationModule(),
    new TgaConfigurationModule()
    new CustomFormatConfigurationModule());

```
