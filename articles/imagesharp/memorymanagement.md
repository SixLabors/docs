# Memory Management

Starting with ImageSharp 2.0, the library uses large (~4MB) discontigous chunks of unmanaged memory to represent multi-megapixel images. Internally, these buffers are heavily pooled to reduce OS allocation overhead. Unlike in ImageSharp 1.0, the pools are automatically trimmed after a certain amount of allocation inactivity, releasing the buffers to the OS, making the library more suitable for applications that do imaging operations in a periodic manner.

The buffer allocation and pooling behavior is implemented by @"SixLabors.ImageSharp.Memory.MemoryAllocator" which is being used through @"SixLabors.ImageSharp.Configuration"'s @"SixLabors.ImageSharp.Configuration.MemoryAllocator" property within the library, therefore it's configurable and replaceable by the user.

### Configuring the pool size

By default, the maximum pool size is platform-specific, defaulting to a portion of the available physical memory on 64 bit coreclr, and to a 128MB constant size on other platforms / runtimes.

We highly recommend to go with these defaults, however in certain cases it might be desirable to override the pool limit. In such cases the most straightforward solution is to replace the memory allocator globally:

```C#
Configuration.Default.MemoryAllocator = MemoryAllocator.Create(new MemoryAllocatorOptions()
{
    MaximumPoolSizeMegabytes = 64
});
```

### Enforcing contiguous buffers

Certain interop use cases may require multi-megapixel images to be layed out contiguously in memory so a single buffer pointer can be passed to native API-s. This can be enforced by setting @"SixLabors.ImageSharp.Configuration"'s @"SixLabors.ImageSharp.Configuration.PreferContiguousImageBuffers" to `true`. Note that this will lead to significantly reduced pooling that may hurt overall processing throughput. We don't recommend to flip this option globally. Instead, you can enable it locally for the image instances that are expected to be contiguous:

```C#
Configuration customConfig = Configuration.Default.Clone();
customConfig.PreferContiguousImageBuffers = true;

using (Image<Rgba32> image = new(customConfig, 4096, 4096))
{
    if (!image.DangerousTryGetSinglePixelMemory(out Memory<Rgba32> memory))
    {
        throw new Exception(
            "This can only happen with multi-GB images or when PreferContiguousImageBuffers is not set to true.");
    }

    using (MemoryHandle pinHandle = memory.Pin())
    {
        void* ptr = pinHandle.Pointer;

        // You can now pass 'ptr' to native API-s.
        // Make sure to keep 'pinHandle', and 'image' alive while native resource work with the pointer.
        // Make sure to Dispose() them afterwards.
    }
}
```

### Wrapping existing buffers as `Image<TPixel>`

It's also possible to do the other way around, and wrap an existing native buffer to process it as an `Image<TPixel>`. You can use one of the @"SixLabors.ImageSharp.Image.WrapMemory*" overloads for this. Note that the resulting image is not suitable for operations that would change the dimensions of the image, such an attempt will lead to an @"SixLabors.ImageSharp.Memory.InvalidMemoryOperationException".

### Troubleshooting memory leaks

Strictly speaking, ImageSharp is safe against memory leaks, because finalizers will take care of the native memory resources leaked by omitting `Dispose()` or `using` blocks. However, letting the memory leak to finalizers may lead to performance issues and if GC execution can't keep up with the leaks, to `OutOfMemoryException`. Application code should take care of disposing any @`SixLabors.ImageSharp.Image` allocated.

In complex and large apps, this might be hard to verify. ImageSharp 2.0+ exposes some code-first diagnostic API-s that may help detecting leaks.

Query and log @"SixLabors.ImageSharp.Diagnostics.MemoryDiagnostics.TotalUndisposedAllocationCount" to track if the number of undisposed allocations is increasing during your application's lifetime:

```C#
myLogger.Log(@"Number of undisposed ImageSharp buffers: {MemoryDiagnostics.TotalUndisposedAllocationCount}");
```

For troubleshooting you can also subscribe to the event @"SixLabors.ImageSharp.Diagnostics.MemoryDiagnostics.UndisposedAllocation". When the event fires, it will report the stack trace of leaking allocations, which may help tracking down bugs. Subscribing to this event has *significant* performance overhead, so avoid it in the final production deployment of your app.

```C#
#if TROUBLESHOOTING_TESTING_NOT_PRODUCTION
MemoryDiagnostics.UndisposedAllocation += allocationStackTrace =>
{
    Console.WriteLine($@"Undisposed allocation detected at:{Environment.NewLine}{allocationStackTrace}");
    Environment.Exit(1);
};
#endif
```