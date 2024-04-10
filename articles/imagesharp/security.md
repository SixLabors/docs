# Security Considerations

Image processing is a memory-intensive application. Most image processing libraries (including ImageSharp and SkiaSharp) decode images into in-memory buffers. Any publicly facing service using such a library might be vulnerable to DoS attacks without implementing further measures.

For solutions using ImageSharp such measures can be:
- Authentication, for example by using HMAC. See [Securing Processing Commands in ImageSharp.Web](../imagesharp.web/processingcommands.md#securing-processing-commands).
- Offloading to separate services/containers.
- Placing the solution behind a reverse proxy.
- Rate Limiting.
- Imposing conservative allocation limits by configuring a custom `MemoryAllocator`:

```csharp
Configuration.Default.MemoryAllocator = MemoryAllocator.Create(new MemoryAllocatorOptions()
{
    // Note that this limits the maximum image size to 64 megapixels.
    // Any attempt to create a larger image will throw.
    AllocationLimitMegabytes = 256
});
```