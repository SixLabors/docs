# Processing Commands

ImageSharp.Web ships with a small set of built-in processors that cover the most common web-image tasks: resize, EXIF-aware orientation, format conversion, quality control, and alpha flattening. By default those commands come from the query string, but the same processors also work with custom request parsers or Razor tag helpers.

## How Command Execution Works

The default [`QueryCollectionRequestParser`](xref:SixLabors.ImageSharp.Web.Commands.QueryCollectionRequestParser) reads query-string pairs into an ordered [`CommandCollection`](xref:SixLabors.ImageSharp.Web.Commands.CommandCollection). A few details are worth knowing:

- If the same command key appears more than once, the last value wins.
- Unknown commands are stripped before HMAC validation and before the processor pipeline runs.
- Processors run in the order their first recognized command appears in the request, not in a hard-coded global order.
- Values are parsed with invariant culture by default. If you turn that off, parsing follows `CultureInfo.CurrentCulture`.

## Resize

Resize commands are handled by [`ResizeWebProcessor`](xref:SixLabors.ImageSharp.Web.Processors.ResizeWebProcessor) and map to [`ResizeOptions`](xref:SixLabors.ImageSharp.Processing.ResizeOptions).

```text
/images/photo.jpg?width=300
/images/photo.jpg?width=300&height=200&rmode=crop
/images/photo.jpg?width=300&height=200&rmode=pad&rcolor=limegreen
/images/photo.jpg?width=300&height=200&rxy=0.37,0.78
/images/photo.jpg?width=300&rsampler=lanczos3&compand=true
```

- `width` and `height` set the target dimensions in pixels. If you provide only one dimension, the original aspect ratio is preserved.
- `rmode` selects the [`ResizeMode`](xref:SixLabors.ImageSharp.Processing.ResizeMode). Common values are `crop`, `pad`, `boxpad`, `max`, `min`, `stretch`, and `manual`.
- `ranchor` selects the [`AnchorPositionMode`](xref:SixLabors.ImageSharp.Processing.AnchorPositionMode). Valid values are `center`, `top`, `bottom`, `left`, `right`, `topleft`, `topright`, `bottomright`, and `bottomleft`.
- `rxy` supplies an exact focal point as `x,y`, where both values are between `0` and `1`.
- `rcolor` sets the pad color for resize modes that add canvas area.
- `rsampler` selects the resampler. Built-in keywords are `bicubic`, `nearest`, `box`, `mitchell`, `catmull`, `lanczos2`, `lanczos3`, `lanczos5`, `lanczos8`, `welch`, `robidoux`, `robidouxsharp`, `spline`, `triangle`, and `hermite`.
- `orient` defaults to `true` and changes how resize interprets EXIF rotation when mapping dimensions, anchors, and focal points. It does not physically rotate the pixels.
- `compand` toggles linear-light companding during the resize.

`orient` is easy to confuse with `autoorient`. The short version is that `orient` only changes resize math, while `autoorient` actually rotates or flips the decoded image.

## Auto-Orient

[`AutoOrientWebProcessor`](xref:SixLabors.ImageSharp.Web.Processors.AutoOrientWebProcessor) applies EXIF orientation to the decoded image before later processors run.

```text
/images/photo.jpg?autoorient=true
/images/photo.jpg?autoorient=true&width=300&height=200&rmode=crop
```

Use `autoorient=true` when you want the output pixels themselves to be normalized to the display orientation.

## Format

[`FormatWebProcessor`](xref:SixLabors.ImageSharp.Web.Processors.FormatWebProcessor) switches the encoder used for the response and cached output.

```text
/images/logo.png?format=jpg
/images/logo.png?format=webp
/images/logo.png?width=300&format=gif
```

Any file extension registered with the active [`ImageFormatsManager`](xref:SixLabors.ImageSharp.Configuration.ImageFormatsManager) can be used here. The exact set therefore depends on the underlying ImageSharp configuration.

The selected format uses the encoder currently registered in [`ImageSharpMiddlewareOptions.Configuration`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.Configuration). With the default middleware configuration, that means `format=jpg`, `format=png`, and `format=webp` all use web-oriented encoder settings rather than the raw ImageSharp library defaults.

## Quality

[`QualityWebProcessor`](xref:SixLabors.ImageSharp.Web.Processors.QualityWebProcessor) controls encoder quality for JPEG and WebP output.

```text
/images/photo.jpg?quality=90
/images/photo.jpg?format=jpg&quality=42
/images/photo.jpg?format=webp&quality=75
```

Quality values are clamped by the target encoder. For WebP, values below `100` switch the encoder to lossy mode.

When no `quality` command is supplied, the default middleware configuration still encodes JPEG and WebP at quality `75`. If you replace [`ImageSharpMiddlewareOptions.Configuration`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.Configuration), you also change those no-query defaults.

## Background Color

[`BackgroundColorWebProcessor`](xref:SixLabors.ImageSharp.Web.Processors.BackgroundColorWebProcessor) fills transparent areas with a color.

```text
/images/logo.png?bgcolor=FFFF00
/images/logo.png?bgcolor=C1FF0080
/images/logo.png?bgcolor=red
/images/logo.png?bgcolor=128,64,32
/images/logo.png?bgcolor=128,64,32,16
```

This is most useful when flattening transparent images before converting them to opaque formats such as JPEG:

```text
/images/logo.png?bgcolor=white&format=jpg&quality=85
```

## Related Topics

- [Configuration and Pipeline](configuration.md)
- [Securing Requests](security.md)
- [Tag Helpers](taghelpers.md)
- [Extensibility](extensibility.md)
