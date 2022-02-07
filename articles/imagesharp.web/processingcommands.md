# Processing Commands

The ImageSharp.Web processing API is imperative. This means that the order in which you supply the individual processing operations is the order in which they are compiled and applied. This allows the API to be very flexible, allowing you to combine processes in any order.  
  
>[!NOTE]
>It is possible to configure your own processing command pipeline by implementing and registering your own version of the @"SixLabors.ImageSharp.Web.Commands.IRequestParser" interface.

The following processors are built into the middleware. In addition extension points are available to register your own command processors.

#### Resize

Allows the resizing of images.

>[!NOTE]
>In V2 this processor will automatically correct the order of dimensional commands based on the presence of EXIF metadata indicating rotated (not flipped) images.
>This behavior can be turned off per request.

``` bash
{PATH_TO_YOUR_IMAGE}?width=300
{PATH_TO_YOUR_IMAGE}?width=300&height=120&rxy=0.37,0.78
{PATH_TO_YOUR_IMAGE}?width=50&height=50&rsampler=nearest&rmode=stretch
{PATH_TO_YOUR_IMAGE}?width=300&compand=true&orient=false
```
Resize commands represent the @"SixLabors.ImageSharp.Processing.ResizeOptions" class.

- `width` The width of the image in px. Use only one dimension to preseve the aspect ratio.
- `height` The height of the image in px. Use only one dimension to preseve the aspect ratio.
- `rmode` The @"SixLabors.ImageSharp.Processing.ResizeMode" to use.
- `rsampler` The @"SixLabors.ImageSharp.Processing.Processors.Transforms.IResampler"
sampler to use.
  - `bicubic` @"SixLabors.ImageSharp.Processing.KnownResamplers.Bicubic"
  - `nearest` @"SixLabors.ImageSharp.Processing.KnownResamplers.NearestNeighbor"
  - `box` @"SixLabors.ImageSharp.Processing.KnownResamplers.Box"
  - `mitchell` @"SixLabors.ImageSharp.Processing.KnownResamplers.MitchellNetravali"
  - `catmull` @"SixLabors.ImageSharp.Processing.KnownResamplers.CatmullRom"  
  - `lanczos2` @"SixLabors.ImageSharp.Processing.KnownResamplers.Lanczos2"  
  - `lanczos3` @"SixLabors.ImageSharp.Processing.KnownResamplers.Lanczos3"
  - `lanczos5` @"SixLabors.ImageSharp.Processing.KnownResamplers.Lanczos5"
  - `lanczos8` @"SixLabors.ImageSharp.Processing.KnownResamplers.Lanczos8"
  - `welch` @"SixLabors.ImageSharp.Processing.KnownResamplers.Welch"  
  - `robidoux` @"SixLabors.ImageSharp.Processing.KnownResamplers.Robidoux"  
  - `robidouxsharp` @"SixLabors.ImageSharp.Processing.KnownResamplers.RobidouxSharp"
  - `spline` @"SixLabors.ImageSharp.Processing.KnownResamplers.Spline"  
  - `triangle` @"SixLabors.ImageSharp.Processing.KnownResamplers.Triangle"  
  - `hermite` @"SixLabors.ImageSharp.Processing.KnownResamplers.Hermite"  
- `ranchor`The @"SixLabors.ImageSharp.Processing.AnchorPositionMode" to use.
- `rxy` Use an exact anchor position point. The comma-separated x and y values range from 0-1.
- `orient` Whether to swap command dimensions based on the presence of EXIF metadata indicating rotated (not flipped) images. Defaults to `true`
- `compand` Whether to compress and expand individual pixel colors values to/from a linear color space when processing. Defaults to `false`


#### Format

Allows the encoding of the output image to a new image format. The available formats depend on your configuration settings.

```
{PATH_TO_YOUR_IMAGE}?format=bmp
{PATH_TO_YOUR_IMAGE}?format=gif
{PATH_TO_YOUR_IMAGE}?format=jpg
{PATH_TO_YOUR_IMAGE}?format=pbm
{PATH_TO_YOUR_IMAGE}?format=png
{PATH_TO_YOUR_IMAGE}?format=tga
{PATH_TO_YOUR_IMAGE}?format=tiff
{PATH_TO_YOUR_IMAGE}?format=webp
```

#### Quality

Allows the encoding of the output image at the given quality.

- For Jpeg this ranges from 1—100.
- For WebP this ranges from 1—100.

```
{PATH_TO_YOUR_IMAGE}?quality=90
{PATH_TO_YOUR_IMAGE}?format=jpg&quality=42
```

>[!NOTE]
>Only certain formats support adjustable quality. This is a constraint of individual image standards not the API.

#### Background Color

Allows the changing of the background color of transparent images.

```
{PATH_TO_YOUR_IMAGE}?bgcolor=FFFF00
{PATH_TO_YOUR_IMAGE}?bgcolor=C1FF0080
{PATH_TO_YOUR_IMAGE}?bgcolor=red
{PATH_TO_YOUR_IMAGE}?bgcolor=128,64,32
{PATH_TO_YOUR_IMAGE}?bgcolor=128,64,32,16
```
