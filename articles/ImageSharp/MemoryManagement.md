#Memory Management

### ImageSharp seems to retain ~300-400 MB of managed memory even after disposing all my images. Is this a memory leak?
By default, ImageSharp uses [ArrayPool-s](http://adamsitnik.com/Array-Pool/) for performance reasons, however this behavior is fully configurable. All large buffers are managed by the [](xref:SixLabors.ImageSharp.Memory.MemoryManager?displayProperty=name) implementation associated to [](xref:SixLabors.ImageSharp.Configuration?displayProperty=name)-s [](xref:SixLabors.ImageSharp.Configuration.MemoryManager?displayProperty=name) property. We are using [](xref:SixLabors.ImageSharp.Memory.ArrayPoolMemoryManager?displayProperty=name) by default. **TODO**

### If you experience OutOfMemoryException
We designed the default [](xref:SixLabors.ImageSharp.Memory.ArrayPoolMemoryManager?displayProperty=name) configuration in a way that default pooling behaviour should not lead to `OutOfMemoryException`-s in typical use cases. **TODO**

### Working in memory constrained environments
Sometimes having ~300 MB memory footprint is not an option. **TODO**

### Releasing pools programatically 
If your application uses ImageSharp sporadically (eg. generating some images on startup, or other use cases) **TODO**

### Using multiple `MemoryManager` instances in the same process
**TODO**