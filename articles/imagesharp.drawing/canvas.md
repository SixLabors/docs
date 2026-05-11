# Canvas Drawing

[`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas) is the central drawing surface in ImageSharp.Drawing. You normally use it through [`Paint(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.PaintExtensions) inside an ImageSharp processing pipeline:

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(400, 240, Color.White.ToPixel<Rgba32>());

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Clear(Brushes.Solid(Color.White));
    Rectangle panel = new(24, 24, 160, 96);
    canvas.Fill(Brushes.Solid(Color.CornflowerBlue), panel);
    canvas.Draw(Pens.Solid(Color.Black, 3), panel);
}));
```

The callback receives a canvas for the current frame. Use the canvas for all drawing work that should happen together.

## Deferred Drawing and Replay

[`DrawingCanvas`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas) looks immediate, but most drawing commands are recorded first and replayed later. Calls such as [`Fill(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Fill*), [`Draw(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Draw*), [`DrawText(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.DrawText*), and [`SaveLayer(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.SaveLayer*) append drawing intent to a command buffer. Calls that must happen at a specific point, such as [`Apply(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Apply*) and [`RenderScene(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.RenderScene*) are stored as entries in the canvas replay timeline.

The root canvas replays the timeline when it is disposed. During replay, command ranges are prepared into backend command batches, and the backend creates and renders scenes for those ranges. This is why a manually-created canvas must be disposed: disposal is the point where recorded work is actually rendered into the target.

The replay timeline can contain three kinds of entry:

- command ranges for normal drawing commands
- apply barriers for `Apply(...)` operations
- retained scene references inserted by `RenderScene(...)`

This deferred model lets ImageSharp.Drawing use one public canvas API for CPU images, WebGPU surfaces, and retained backend scenes. The canvas records drawing intent once, performs shared preparation once, and then hands a stable command batch to the active backend.

[`Flush()`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Flush) seals the commands recorded so far into a command-range timeline entry. It does not render immediately by itself. Most code does not need it; replay barriers such as [`Apply(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Apply*) already seal earlier commands before they run.

```csharp
image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.LightGray));

    // Apply is a replay barrier, so the blur sees the earlier fill.
    canvas.Apply(new Rectangle(40, 40, 180, 120), region => region.GaussianBlur(6));

    canvas.Draw(Pens.Solid(Color.Black, 3), new Rectangle(40, 40, 180, 120));
}));
```

Inside [`Paint(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.PaintExtensions), ImageSharp.Drawing owns the canvas lifetime. When you call [`CreateCanvas(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvasFactoryExtensions.CreateCanvas*) yourself, your `using` statement is what triggers replay.

## Paint Versus CreateCanvas

Use [`Paint(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.PaintExtensions) for normal `Mutate(...)` and `Clone(...)` pipelines. It follows ImageSharp's processor model and handles each frame for you.

Use [`CreateCanvas(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvasFactoryExtensions.CreateCanvas*) when you already have an image frame and want to manage the canvas lifetime yourself. Disposing the canvas replays the recorded work into the target frame.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;

using Image<Rgba32> image = new(320, 180, Color.White.ToPixel<Rgba32>());
using DrawingCanvas canvas = image.Frames.RootFrame.CreateCanvas(image.Configuration, new());

canvas.Fill(Brushes.Solid(Color.LightSteelBlue));
canvas.Draw(Pens.Dash(Color.Navy, 3), new Rectangle(18, 18, 284, 144));
```

## Clear and Fill

Use [`Fill(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Fill*) when you want normal brush compositing. Use [`Clear(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Clear*) when you want to replace pixels in the covered area, including replacing them with transparent pixels.

[`Clear(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Clear*) can target the full canvas, a rectangle, or any [`IPath`](xref:SixLabors.ImageSharp.Drawing.IPath). It also honors the active clip state created by [`Save(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Save*), so clears can be scoped by both the supplied clear shape and the current canvas state.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(320, 200, Color.Transparent.ToPixel<Rgba32>());
DrawingOptions clipToEllipse = new()
{
    ShapeOptions = new()
    {
        BooleanOperation = BooleanOperation.Intersection
    }
};

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.MidnightBlue.WithAlpha(0.95F)));
    canvas.Fill(Brushes.Solid(Color.Crimson.WithAlpha(0.8F)), new Rectangle(26, 18, 268, 164));

    EllipsePolygon clip = new(new PointF(160, 100), new SizeF(214, 126));
    _ = canvas.Save(clipToEllipse, clip);

    canvas.Clear(Brushes.Solid(Color.LightYellow.WithAlpha(0.85F)));

    // Transparent clear removes content inside the supplied path and active clip.
    EllipsePolygon cutout = new(new PointF(164, 98), new SizeF(74, 48));
    canvas.Clear(Brushes.Solid(Color.Transparent), cutout);
    canvas.Restore();

    canvas.Draw(Pens.DashDot(Color.Black, 3), clip);
}));
```

## State and Storage

[`Save()`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Save) stores the current drawing state on a stack and [`Restore()`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Restore) returns to the previous state. The state includes drawing options, clip paths, target bounds, and layer information for later commands.

The overload [`Save(DrawingOptions, params IPath[])`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Save*) stores the supplied [`DrawingOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingOptions) instance by reference. Treat options passed to [`Save(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Save*) as owned by the active canvas state until that state has been restored.

The active state reference is captured when each command is recorded. Later [`Save(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Save*) or [`Restore()`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Restore) calls do not replace the state for commands already in the command buffer, but mutating a referenced [`DrawingOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingOptions) instance can still affect commands that captured that same instance.

The state captured for drawing includes:

- [`DrawingOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingOptions), including graphics options, shape options, and transform
- clip paths supplied to [`Save(DrawingOptions, params IPath[])`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Save*)
- target bounds for the active canvas or region
- destination offset for region canvases
- whether the command is being recorded inside a layer

[`Save()`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Save) pushes a normal state frame. [`SaveLayer(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.SaveLayer*) pushes a layer state frame. Only layer state frames create layer boundary commands when restored.

## Save and Restore State

[`Save(...)`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Save*) pushes the current drawing state. The overload that accepts [`DrawingOptions`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingOptions) and clip paths replaces the active state until you call [`Restore()`](xref:SixLabors.ImageSharp.Drawing.Processing.DrawingCanvas.Restore).

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(360, 220, Color.White.ToPixel<Rgba32>());
DrawingOptions clipInside = new()
{
    ShapeOptions = new()
    {
        BooleanOperation = BooleanOperation.Intersection
    }
};

image.Mutate(ctx => ctx.Paint(canvas =>
{
    EllipsePolygon clipPath = new(new PointF(180, 110), new SizeF(260, 140));

    _ = canvas.Save(clipInside, clipPath);
    canvas.Fill(Brushes.Solid(Color.MidnightBlue), new Rectangle(0, 0, 360, 220));
    canvas.Fill(Brushes.Solid(Color.Gold.WithAlpha(0.72F)), new Rectangle(56, 38, 248, 144));
    canvas.Restore();

    canvas.Draw(Pens.Solid(Color.Black, 3), clipPath);
}));
```

Use `SaveLayer(...)` when you need an isolated compositing layer that is later blended back onto the parent canvas.

## Region Canvases

`CreateRegion(...)` creates a child canvas over a clipped subregion of the parent target. The child canvas has a local origin at `(0, 0)` for drawing commands, but it shares the parent replay timeline. The root canvas still owns final replay.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(360, 220, Color.White.ToPixel<Rgba32>());

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.LightGray));

    using DrawingCanvas region = canvas.CreateRegion(new Rectangle(80, 48, 180, 112));
    region.Fill(Brushes.Solid(Color.CornflowerBlue));

    // Region-local coordinates start at the region origin.
    region.Draw(Pens.Solid(Color.White, 5), new Rectangle(12, 12, 156, 88));

    canvas.Draw(Pens.Solid(Color.Black, 2), new Rectangle(80, 48, 180, 112));
}));
```

Use a region when you want a smaller local coordinate system. Use `Save(...)` with clip paths when you want to keep the parent coordinate system but clip later commands.

## Layers

`SaveLayer(...)` starts an isolated composition scope. Commands drawn inside the layer are recorded into that scope, and `Restore()` closes the layer. The closed layer is composited back into the parent using the `GraphicsOptions` supplied to `SaveLayer(...)`.

Layer bounds limit the isolated target and final composition area. They do not move the canvas origin, so commands inside a bounded layer still use the same local coordinates as the parent canvas.

A layer is useful when a group of commands must be blended as one result. Without a layer, each command is blended into the parent independently. With a layer, commands first render into an isolated target, then that whole target is composited back once.

The layer lifecycle is:

1. `SaveLayer(...)` records a begin-layer command and pushes a layer state.
2. Drawing commands inside the layer are recorded with the layer state.
3. `Restore()` or `RestoreTo(...)` records an end-layer command.
4. Disposal replay asks the backend to lower that layer scope for the target.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(360, 220, Color.White.ToPixel<Rgba32>());

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.SteelBlue), new Rectangle(24, 24, 312, 172));

    GraphicsOptions layerOptions = new()
    {
        BlendPercentage = 0.5F
    };

    _ = canvas.SaveLayer(layerOptions, new Rectangle(70, 46, 220, 128));

    // The layer bounds isolate composition; these coordinates are still parent-canvas coordinates.
    canvas.Fill(Brushes.Solid(Color.OrangeRed), new EllipsePolygon(new PointF(180, 110), new SizeF(170, 96)));
    canvas.Draw(Pens.Solid(Color.White, 8), new Rectangle(96, 74, 168, 72));
    canvas.Restore();

    canvas.Draw(Pens.Solid(Color.Black, 2), new Rectangle(70, 46, 220, 128));
}));
```

If a canvas is disposed while a layer is still active, disposal unwinds the layer using the same path as `Restore()`.

Use bounded layers deliberately. A smaller layer bounds can reduce the isolated composition area, but anything outside those bounds is not part of that layer's final composition.

## Draw Images

`DrawImage(...)` records image drawing through the same canvas timeline as shape and text commands. Pass the source image, a source rectangle, a destination rectangle, and an optional resampler.

The source rectangle is sampled from the source image and scaled into the destination rectangle. The current transform and clip state apply to the destination drawing. Source rectangles that extend outside the source image are clipped to the available pixels.

Because canvas drawing is deferred, the source image must remain alive until the canvas has replayed the command. With `Paint(...)`, that means keeping the source image alive for the duration of the `Mutate(...)` call. With a manually-created canvas, keep it alive until the canvas is disposed.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> source = Image.Load<Rgba32>("photo.jpg");
using Image<Rgba32> image = new(420, 260, Color.White.ToPixel<Rgba32>());
DrawingOptions clipInside = new()
{
    ShapeOptions = new()
    {
        BooleanOperation = BooleanOperation.Intersection
    }
};

EllipsePolygon clip = new(new PointF(210, 130), new SizeF(300, 170));
Rectangle sourceRect = new(20, 12, 240, 180);
RectangleF destination = new(60, 45, 300, 170);

image.Mutate(ctx => ctx.Paint(canvas =>
{
    _ = canvas.Save(clipInside, clip);

    // Bicubic resampling is a good default for scaled photographic content.
    canvas.DrawImage(source, sourceRect, destination, KnownResamplers.Bicubic);
    canvas.Restore();

    canvas.Draw(Pens.Solid(Color.Black, 3), clip);
}));
```

## Strokes and Command Preparation

Stroke drawing is prepared during replay. A `Draw(...)` command records the original path, pen, stroke width, dash pattern, caps, joins, and active state. When the canvas prepares the command batch, it normalizes strokes for backend execution.

Simple solid line segments can stay as line commands. Dashed strokes, paths, joins, caps, and other complex strokes are prepared as stroke path commands or expanded into fillable geometry before backend handoff. Clip paths are applied during preparation so backends receive commands with consistent clipping semantics.

That means `Draw(...)` and `Fill(...)` share the same backend handoff model even though the public calls describe different drawing intent. Backends receive prepared commands and can focus on rendering them for their target.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(420, 220, Color.White.ToPixel<Rgba32>());

PathBuilder builder = new();
builder.AddCubicBezier(new(36, 150), new(116, 32), new(292, 44), new(384, 158));

IPath path = builder.Build();
Pen pen = Pens.DashDot(Color.DarkSlateBlue, 10);
pen.StrokeOptions.LineCap = LineCap.Round;
pen.StrokeOptions.LineJoin = LineJoin.Round;

image.Mutate(ctx => ctx.Paint(canvas =>
{

    // Dash, cap, and join settings are part of the recorded stroke intent.
    canvas.Draw(pen, path);
}));
```

Use the pen's `StrokeOptions` for stroke shape:

- `LineCap` controls open path ends.
- `LineJoin` controls corners.
- `MiterLimit` controls how far miter joins can extend.
- dash pens such as `Pens.Dash(...)` and `Pens.DashDot(...)` record a stroke pattern.

## Retained Scene Replay

Use `CreateScene()` when the same recorded drawing should be replayed into more than one canvas target. It seals and prepares the recorded drawing commands into a retained backend scene. `RenderScene(...)` inserts that retained scene into the receiving canvas timeline at the point where it is called.

The scene is backend-owned state, so keep it alive until every canvas that records it has been disposed. A canvas that receives `RenderScene(...)` still replays on disposal like any other canvas.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.Drawing.Processing.Backends;
using SixLabors.ImageSharp.PixelFormats;

using Image<Rgba32> source = new(160, 120, Color.Transparent.ToPixel<Rgba32>());
using DrawingCanvas sourceCanvas = source.Frames.RootFrame.CreateCanvas(source.Configuration, new());

sourceCanvas.Fill(Brushes.Solid(Color.Gold), new EllipsePolygon(new PointF(80, 60), new SizeF(116, 72)));
sourceCanvas.Draw(Pens.Solid(Color.Black, 3), new Rectangle(12, 12, 136, 96));

using DrawingBackendScene scene = sourceCanvas.CreateScene();

using Image<Rgba32> first = new(160, 120, Color.White.ToPixel<Rgba32>());
using DrawingCanvas firstCanvas = first.Frames.RootFrame.CreateCanvas(first.Configuration, new());
firstCanvas.RenderScene(scene);
firstCanvas.Dispose();

using Image<Rgba32> second = new(160, 120, Color.LightGray.ToPixel<Rgba32>());
using DrawingCanvas secondCanvas = second.Frames.RootFrame.CreateCanvas(second.Configuration, new());
secondCanvas.RenderScene(scene);
secondCanvas.Dispose();
```

`RenderScene(...)` preserves timeline order. Commands recorded before it replay before the retained scene; commands recorded after it replay after the retained scene.

## Apply Image Processing to a Region

`Apply(...)` runs ImageSharp processors inside a rectangle, path, or path builder region. It is a replay barrier because the processor needs real pixels, not just recorded drawing commands.

During replay, ImageSharp.Drawing reads the covered target pixels into a temporary image, runs the processor operation on that temporary image, then writes the processed result back through the canvas pipeline using the recorded path and state.

```csharp
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Drawing;
using SixLabors.ImageSharp.Drawing.Processing;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

using Image<Rgba32> image = new(360, 220, Color.White.ToPixel<Rgba32>());

image.Mutate(ctx => ctx.Paint(canvas =>
{
    canvas.Fill(Brushes.Solid(Color.LightGray));
    canvas.Draw(Pens.Solid(Color.Black, 4), new Rectangle(24, 24, 312, 172));

    EllipsePolygon blurPath = new(new PointF(180, 110), new SizeF(220, 120));

    // The blur is clipped to the supplied path region.
    canvas.Apply(blurPath, region => region.GaussianBlur(8));
}));
```

Because `Apply(...)` reads pixels at its replay point, commands before the barrier affect the processed image, and commands after the barrier do not.
