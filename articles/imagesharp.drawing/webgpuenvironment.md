# WebGPU Environment and Support

[`WebGPUEnvironment`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUEnvironment) configures and probes the library-managed WebGPU environment. Use it before constructing windows, external surfaces, or render targets when startup must be predictable.

The environment represents the process-level WebGPU runtime used by the public target types. It is responsible for acquiring the adapter, device, and queue used by ImageSharp.Drawing.WebGPU. Because the environment initializes on first use, set options and error callbacks before creating any WebGPU object.

## Configure Before First Use

[`WebGPUEnvironment.Options`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUEnvironment.Options) is read during first initialization. Changing it later does not reconfigure an existing device.

```csharp
using SixLabors.ImageSharp.Drawing.Processing.Backends;

WebGPUEnvironment.Options = new()
{
    PowerPreference = WebGPUPowerPreference.HighPerformance
};
```

`HighPerformance` is the usual choice for drawing workloads. If an application should prefer a lower-power adapter, configure that once during startup before probing or creating targets.

## Probe Availability

Call [`ProbeAvailability()`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUEnvironment.ProbeAvailability) to check whether the library can initialize the WebGPU API, create an instance, acquire an adapter, acquire a device, and get the default queue.

Call [`ProbeComputePipelineSupport()`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUEnvironment.ProbeComputePipelineSupport) when the drawing backend must prove it can create compute pipelines. This is a stronger check than basic device acquisition.

```csharp
using SixLabors.ImageSharp.Drawing.Processing.Backends;

static bool TryUseWebGPU()
{
    WebGPUEnvironmentError availability = WebGPUEnvironment.ProbeAvailability();
    if (availability != WebGPUEnvironmentError.Success)
    {
        Console.WriteLine($"WebGPU unavailable: {availability}");
        return false;
    }

    WebGPUEnvironmentError compute = WebGPUEnvironment.ProbeComputePipelineSupport();
    if (compute != WebGPUEnvironmentError.Success)
    {
        Console.WriteLine($"WebGPU compute unavailable: {compute}");
        return false;
    }

    return true;
}
```

`Success` is the only successful result. Other values are stable failure categories such as API initialization failure, adapter timeout, device request failure, queue acquisition failure, or compute-pipeline probe failure. Branch on the enum value rather than parsing diagnostic strings.

## Log Native WebGPU Errors

Configure [`UncapturedError`](xref:SixLabors.ImageSharp.Drawing.Processing.Backends.WebGPUEnvironment.UncapturedError) to receive native WebGPU validation, device, or internal errors reported outside a specific managed call.

```csharp
using SixLabors.ImageSharp.Drawing.Processing.Backends;

WebGPUEnvironment.UncapturedError = (errorType, message) =>
{
    Console.Error.WriteLine($"{errorType}: {message}");
};
```

The callback can be raised from a native WebGPU callback thread. Keep handlers short and non-blocking. Use it for logging, not for complex UI updates or recovery work.

## Fallback Strategy

Applications that can render on either CPU or GPU should decide early:

```csharp
bool useGpu = TryUseWebGPU();

if (useGpu)
{
    // Construct WebGPUWindow, WebGPUExternalSurface, or WebGPURenderTarget.
}
else
{
    // Fall back to Image<TPixel> and the normal ImageSharp.Drawing path.
}
```

Do not create a WebGPU target first and then probe after failure. Probing first gives better diagnostics and avoids partially initialized rendering paths.

## Related Topics

- [WebGPU](webgpu.md)
- [WebGPU Window Rendering](webgpuwindow.md)
- [WebGPU External Surfaces](webgpuexternalsurface.md)
- [WebGPU Offscreen Render Targets](webgpurendertarget.md)

## Practical Guidance

Configure `WebGPUEnvironment.Options` and `UncapturedError` during application startup. Use `ProbeAvailability()` for basic device readiness and `ProbeComputePipelineSupport()` when WebGPU drawing is required. Treat a non-success result as a normal deployment condition and provide a CPU fallback when the application can still produce useful output.
