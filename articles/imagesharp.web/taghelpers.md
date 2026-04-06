# Tag Helpers

ImageSharp.Web includes Razor tag helpers so you can build image-processing URLs in strongly typed server-side markup instead of hand-concatenating query strings. The tag helpers also integrate with HMAC signing, which makes them the easiest way to generate safe image URLs in MVC and Razor Pages apps.

## Enable the Tag Helpers

Add the ImageSharp namespaces and tag helper registration to `_ViewImports.cshtml`:

```html
@using SixLabors.ImageSharp
@using SixLabors.ImageSharp.Processing
@using SixLabors.ImageSharp.Web

@addTagHelper *, SixLabors.ImageSharp.Web
```

That enables both [`ImageTagHelper`](xref:SixLabors.ImageSharp.Web.TagHelpers.ImageTagHelper) and [`HmacTokenTagHelper`](xref:SixLabors.ImageSharp.Web.TagHelpers.HmacTokenTagHelper).

## Generate Command URLs with `ImageTagHelper`

`ImageTagHelper` targets `<img>` elements and converts `imagesharp-*` attributes into the corresponding query-string commands:

```html
<img
    src="images/hero.png"
    imagesharp-width="400"
    imagesharp-height="250"
    imagesharp-rmode="ResizeMode.Crop"
    imagesharp-format="Format.WebP"
    imagesharp-quality="75"
    alt="Hero image" />
```

That renders a `src` roughly like this:

```text
images/hero.png?width=400&height=250&rmode=Crop&format=webp&quality=75
```

The built-in typed values mirror the processor APIs:

- Use [`ResizeMode`](xref:SixLabors.ImageSharp.Processing.ResizeMode) and [`AnchorPositionMode`](xref:SixLabors.ImageSharp.Processing.AnchorPositionMode) for resize modes and anchors.
- Use [`Color`](xref:SixLabors.ImageSharp.Color) for `imagesharp-rcolor` and `imagesharp-bgcolor`.
- Use [`Format`](xref:SixLabors.ImageSharp.Web.Format) for common output formats such as `Format.Jpg` and `Format.WebP`.
- Use [`Resampler`](xref:SixLabors.ImageSharp.Web.Resampler) for common resamplers such as `Resampler.Lanczos3` and `Resampler.NearestNeighbor`.

The supported built-in attributes are:

- `imagesharp-width`, `imagesharp-height`, `imagesharp-rmode`, `imagesharp-ranchor`, `imagesharp-rxy`, `imagesharp-rcolor`, `imagesharp-rsampler`, `imagesharp-compand`, and `imagesharp-orient` for resize behavior.
- `imagesharp-autoorient` for EXIF-based rotation and flipping.
- `imagesharp-format` for output format selection.
- `imagesharp-bgcolor` for flattening transparency.
- `imagesharp-quality` for JPEG and WebP quality.

If the `<img>` element does not already have literal `width` and `height` attributes, `ImageTagHelper` also writes them to the markup from the processing dimensions. That helps avoid layout shift for simple resize scenarios.

## Local URLs Versus External URLs

`ImageTagHelper` is intended for local application image URLs. It skips `http`, `ftp`, and `data` sources because ImageSharp.Web does not process those through the built-in local-path pipeline.

## Automatic HMAC Generation

[`HmacTokenTagHelper`](xref:SixLabors.ImageSharp.Web.TagHelpers.HmacTokenTagHelper) runs on `<img src="...">` and appends the `hmac` command automatically when [`ImageSharpMiddlewareOptions.HMACSecretKey`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.HMACSecretKey) is configured and the final `src` contains recognized commands.

That means both of these patterns work:

```html
<img src="images/avatar.jpg?width=128&height=128&rmode=Crop" />

<img
    src="images/avatar.jpg"
    imagesharp-width="128"
    imagesharp-height="128"
    imagesharp-rmode="ResizeMode.Crop" />
```

In the first case, `HmacTokenTagHelper` signs your handwritten command URL. In the second case, `ImageTagHelper` generates the command URL and `HmacTokenTagHelper` signs it afterward.

## Extending the Tag Helper

[`ImageTagHelper`](xref:SixLabors.ImageSharp.Web.TagHelpers.ImageTagHelper) is unsealed. If you add custom processors and want matching Razor syntax, inherit from it and override `AddProcessingCommands(...)` to append your own commands before the final `src` is emitted.

## Related Topics

- [Processing Commands](processingcommands.md)
- [Securing Requests](security.md)
- [Extensibility](extensibility.md)
