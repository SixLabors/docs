# Resizing Images

Resizing looks simple on the surface, but it is also one of the easiest places to make an image look subtly wrong. Aspect ratio, resampler choice, fit mode, alpha handling, and decode-time downscaling all influence the result, so this page walks through the common paths in the order most people need them.

The simple `Resize()` overloads are good for direct width and height changes, while [`ResizeOptions`](xref:SixLabors.ImageSharp.Processing.ResizeOptions) gives you control over fit mode, anchor position, background padding, sampler choice, alpha handling, and manual target rectangles.

Start by choosing the layout promise. If the full image must remain visible, use a fit mode such as `Max` or `Pad`. If the output box must be completely filled, use `Crop` and choose an anchor or focal point. If exact aspect ratio is not important, `Stretch` is available, but it should be a deliberate visual choice.

## Basic Resize

Use the basic overloads when you already know the destination size:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x.Resize(1200, 800));
image.Save("output.jpg");
```

ImageSharp defaults to [`KnownResamplers.Bicubic`](xref:SixLabors.ImageSharp.Processing.KnownResamplers.Bicubic), which is a solid general-purpose choice for both downscaling and upscaling.

If either `width` or `height` is `0`, ImageSharp calculates the missing dimension to preserve aspect ratio:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x.Resize(600, 0));
```

## Choose the Right Resampler

Resampling is the part of resizing that decides how source pixels contribute to destination pixels. When shrinking an image, many source pixels must be combined into fewer destination pixels. When enlarging an image, new destination pixels must be estimated from the surrounding source pixels. Different resamplers make different tradeoffs between sharpness, smoothness, ringing, aliasing, and speed.

[`Bicubic`](xref:SixLabors.ImageSharp.Processing.KnownResamplers.Bicubic) is ImageSharp's default because it is a balanced general-purpose choice. It produces smoother results than nearest-neighbor sampling and is less prone to visible ringing than more aggressive high-lobe filters. For many application thumbnails and ordinary web images, it is a good starting point.

[`Lanczos3`](xref:SixLabors.ImageSharp.Processing.KnownResamplers.Lanczos3) is often a strong choice for high-quality downscaling because it preserves detail well. That extra sharpness can also produce halos or ringing around hard contrast edges, so it should be tested on screenshots, line art, product photos, and portraits before becoming a global default. Larger Lanczos variants such as `Lanczos5` and `Lanczos8` use wider kernels and can preserve even more detail, but they cost more work and can make ringing more visible.

[`Spline`](xref:SixLabors.ImageSharp.Processing.KnownResamplers.Spline), [`CatmullRom`](xref:SixLabors.ImageSharp.Processing.KnownResamplers.CatmullRom), [`MitchellNetravali`](xref:SixLabors.ImageSharp.Processing.KnownResamplers.MitchellNetravali), [`Robidoux`](xref:SixLabors.ImageSharp.Processing.KnownResamplers.Robidoux), and [`RobidouxSharp`](xref:SixLabors.ImageSharp.Processing.KnownResamplers.RobidouxSharp) are useful when you are tuning a visual pipeline and want a different balance of softness and edge contrast. The right choice is content-dependent: UI screenshots, portraits, scanned documents, and generated artwork can prefer different filters.

[`NearestNeighbor`](xref:SixLabors.ImageSharp.Processing.KnownResamplers.NearestNeighbor) does no smoothing. It is the right choice for pixel art, masks, indexed-style data, and any workflow where hard pixel boundaries must remain hard. It is usually the wrong choice for photos because it creates blocky stair-step artifacts.

Simple filters such as [`Box`](xref:SixLabors.ImageSharp.Processing.KnownResamplers.Box), [`Triangle`](xref:SixLabors.ImageSharp.Processing.KnownResamplers.Triangle), and [`Hermite`](xref:SixLabors.ImageSharp.Processing.KnownResamplers.Hermite) can be useful when speed, softness, or predictable low-detail output matters more than maximum sharpness.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.png");

image.Mutate(x => x.Resize(320, 240, KnownResamplers.Lanczos3));
```

If you are building a reusable pipeline, choose a default sampler per content type rather than one sampler for everything. For example, product thumbnails, user avatars, pixel-art previews, and scanned documents often deserve different choices.

## Use ResizeOptions for Real-World Layout Rules

[`ResizeOptions`](xref:SixLabors.ImageSharp.Processing.ResizeOptions) is the main API for fit-and-fill workflows. When you use it, set [`Mode`](xref:SixLabors.ImageSharp.Processing.ResizeOptions.Mode) explicitly; its default is [`Crop`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Crop).

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.jpg");

image.Mutate(x => x.Resize(new ResizeOptions
{
    Size = new Size(300, 300),
    Mode = ResizeMode.Crop,
    Position = AnchorPositionMode.Center,
    Sampler = KnownResamplers.Lanczos3,
    Compand = true
}));
```

The resize modes are:

- [`Crop`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Crop): fills the target box and crops overflow.
- [`Pad`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Pad): fits within the target box and fills the remainder.
- [`BoxPad`](xref:SixLabors.ImageSharp.Processing.ResizeMode.BoxPad): pads without upscaling the original image; when downscaling it behaves like `Pad`.
- [`Max`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Max): fits within the box without cropping.
- [`Min`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Min): scales until the shortest side reaches the target, without upscaling.
- [`Stretch`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Stretch): ignores aspect ratio and forces the exact size.
- [`Manual`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Manual): uses [`TargetRectangle`](xref:SixLabors.ImageSharp.Processing.ResizeOptions.TargetRectangle) to place the resized result explicitly.

For user-visible images, `Crop`, `Pad`, and `Max` cover most layouts. `Manual` is for composition systems where you already calculated the destination rectangle. `Stretch` is mostly for data, masks, or intentionally distorted visual effects.

## Position, Padding, and Manual Placement

`ResizeOptions` also controls where the result lands inside the output canvas:

- [`Position`](xref:SixLabors.ImageSharp.Processing.ResizeOptions.Position) sets the anchor for crop and pad operations.
- [`CenterCoordinates`](xref:SixLabors.ImageSharp.Processing.ResizeOptions.CenterCoordinates) lets you bias crop focus more precisely.
- [`PadColor`](xref:SixLabors.ImageSharp.Processing.ResizeOptions.PadColor) fills the background for padded results.
- [`TargetRectangle`](xref:SixLabors.ImageSharp.Processing.ResizeOptions.TargetRectangle) is required for [`ResizeMode.Manual`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Manual).

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

using Image image = Image.Load("input.png");

image.Mutate(x => x.Resize(new ResizeOptions
{
    Size = new Size(1200, 1200),
    Mode = ResizeMode.Pad,
    Position = AnchorPositionMode.Center,
    PadColor = Color.White
}));
```

## Companding and Alpha Handling

Resizing blends neighboring pixels. If those pixel values are blended directly in a gamma-encoded space, midtones can shift in ways that are visible on gradients, shadows, and high-contrast photographic content. [`Compand`](xref:SixLabors.ImageSharp.Processing.ResizeOptions.Compand) enables gamma-aware resizing so interpolation happens in a space that is often visually more appropriate. It costs extra work, so test it against your image set instead of enabling it blindly everywhere.

Alpha needs similar care. Transparent images usually look better when color channels are interpolated in premultiplied form, because transparent edge pixels then contribute color in proportion to their coverage. [`PremultiplyAlpha`](xref:SixLabors.ImageSharp.Processing.ResizeOptions.PremultiplyAlpha) defaults to `true` and should normally stay enabled for logos, sprites, UI elements, and cutouts. Turning it off is an advanced choice for data images or pipelines that already handle alpha in a very specific way.

## Decode Smaller When That Is Enough

If you only need a bounded preview or thumbnail, consider decoding directly to a smaller size with [`DecoderOptions.TargetSize`](xref:SixLabors.ImageSharp.Formats.DecoderOptions.TargetSize) instead of fully decoding and then resizing. ImageSharp treats that target as a fit-within box equivalent to [`ResizeMode.Max`](xref:SixLabors.ImageSharp.Processing.ResizeMode.Max).

See [Loading, Identifying, and Saving](loadingandsaving.md) and [Security Considerations](security.md) for examples.

## WrapMemory Caveat

`Resize()` changes image dimensions and therefore needs a new backing buffer. Images created with `WrapMemory(...)` are best suited to fixed-size interop workflows, so resize them only after copying or cloning into a regular ImageSharp-owned image.

See [Interop and Raw Memory](interop.md) for the full wrapped-memory guidance.

## Practical Guidance

A resize should start from the product promise, not from the overload. If a user must see the whole image, choose a fit mode such as `Max` or `Pad`. If the layout must be filled edge-to-edge, choose `Crop` and decide how the crop should be anchored. If you are building a composition engine and already know the exact destination rectangle, use `Manual`. `Stretch` is available, but it should be reserved for cases where distortion is acceptable or meaningful.

For user-uploaded photos, call `AutoOrient()` before resizing unless preserving the raw encoded pixel orientation is intentional. Crop coordinates, anchors, and focal points are much easier to reason about after the pixels match the way a person sees the image. For very large inputs where only a bounded preview is needed, `DecoderOptions.TargetSize` can reduce decode cost before the resize pipeline runs.

Resampler choice should be tested against representative images. A sharper result is not always a better result: line art, screenshots, photos, and pixel art often want different tradeoffs. After resizing, save with an explicit encoder when final quality, compression, metadata, or color handling must be predictable.

## Related Topics

- [Processing Images](processing.md)
- [Crop, Pad, and Canvas](cropandcanvas.md)
- [Generate Thumbnails](thumbnails.md)
