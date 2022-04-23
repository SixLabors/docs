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

## Securing Processing Commands

With ImageSharp.Web it is possible to configure an action to generate an HMAC by setting the @SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.HMACSecretKey property to any byte array value. This triggers checks in the middleware to look for and compare a HMAC hash of the request URL with the hash that is passed alongside the commands.

In cryptography, an HMAC (sometimes expanded as either keyed-hash message authentication code or hash-based message authentication code) is a specific type of message authentication code (MAC) involving a cryptographic hash function and a secret cryptographic key. As with any MAC, it may be used to simultaneously verify both the data integrity and authenticity of a message.

HMAC can provide authentication using a shared secret instead of using digital signatures with asymmetric cryptography. It trades off the need for a complex public key infrastructure by delegating the key exchange to the communicating parties, who are responsible for establishing and using a trusted channel to agree on the key prior to communication.

Any cryptographic hash function, such as SHA-2 or SHA-3, may be used in the calculation of an HMAC; the resulting MAC algorithm is termed HMAC-X, where X is the hash function used (e.g. HMAC-SHA256 or HMAC-SHA3-512). The cryptographic strength of the HMAC depends upon the cryptographic strength of the underlying hash function, the size of its hash output, and the size and quality of the key.

HMAC does not encrypt the message. Instead, the message (encrypted or not) must be sent alongside the HMAC hash. Parties with the secret key will hash the message again themselves, and if it is authentic, the received and computed hashes will match.

By default ImageSharp.Web will use a HMAC-SHA256 algorithm.

```c#
private Func<ImageCommandContext, byte[], Task<string>> onComputeHMACAsync = (context, secret) =>
{
    string uri = CaseHandlingUriBuilder.BuildRelative(
            CaseHandlingUriBuilder.CaseHandling.LowerInvariant,
            context.Context.Request.PathBase,
            context.Context.Request.Path,
            QueryString.Create(context.Commands));

    return Task.FromResult(HMACUtilities.ComputeHMACSHA256(uri, secret));
};
```

Users can replicate that key using the same @SixLabors.ImageSharp.Web.CaseHandlingUriBuilder and @SixLabors.ImageSharp.Web.HMACUtilities APIs to generate the HMAC hash on the client. The hash must be passed via a command using the @SixLabors.ImageSharp.Web.HMACUtilities.TokenCommand constant.

Any invalid matches are rejected at the very start of the processing pipeline with a 400 HttpResponse code.