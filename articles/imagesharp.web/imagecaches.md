# Image Caches

ImageSharp.Web caches processed output so that identical requests do not repeatedly decode, process, and re-encode the source image. The cache stores both the encoded bytes and metadata about the source and response so the middleware can detect stale entries and serve correct headers.

## How the Cache Works

For each processed request, the middleware:

- builds a cache key from the request path plus the sanitized command collection;
- hashes that key into a filesystem-safe cache name;
- stores the encoded image plus metadata such as source last-write time, cache write time, content type, browser max-age, and content length;
- reuses the cached result until the source changes or the cache entry ages beyond [`ImageSharpMiddlewareOptions.CacheMaxAge`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.CacheMaxAge).

## Default Physical Cache

[`PhysicalFileSystemCache`](xref:SixLabors.ImageSharp.Web.Caching.PhysicalFileSystemCache) is the default backend registered by [`AddImageSharp()`](xref:SixLabors.ImageSharp.Web.ServiceCollectionExtensions.AddImageSharp*).

- It stores cached files under the web root by default.
- [`PhysicalFileSystemCacheOptions.CacheFolder`](xref:SixLabors.ImageSharp.Web.Caching.PhysicalFileSystemCacheOptions.CacheFolder) defaults to `is-cache`.
- [`PhysicalFileSystemCacheOptions.CacheFolderDepth`](xref:SixLabors.ImageSharp.Web.Caching.PhysicalFileSystemCacheOptions.CacheFolderDepth) defaults to `8`, which spreads cached files across nested folders.

```csharp
using SixLabors.ImageSharp.Web;
using SixLabors.ImageSharp.Web.Caching;

builder.Services.AddImageSharp()
    .Configure<PhysicalFileSystemCacheOptions>(options =>
    {
        options.CacheRootPath = "cache";
        options.CacheFolder = "imagesharp";
        options.CacheFolderDepth = 8;
    });
```

If your app does not define a web root, set [`CacheRootPath`](xref:SixLabors.ImageSharp.Web.Caching.PhysicalFileSystemCacheOptions.CacheRootPath) explicitly. Relative paths are resolved against the application content root.

## Browser Lifetime Versus Backend Lifetime

ImageSharp.Web tracks two different lifetimes:

- [`ImageSharpMiddlewareOptions.BrowserMaxAge`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.BrowserMaxAge) controls the `Cache-Control` lifetime sent to clients.
- [`ImageSharpMiddlewareOptions.CacheMaxAge`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.CacheMaxAge) controls how long the processed result stays valid in the backend cache.

If the source provider supplies a source `Cache-Control` max-age, that value overrides `BrowserMaxAge` for the response.

## Cache Keys and Hashes

By default, ImageSharp.Web uses:

- [`UriRelativeLowerInvariantCacheKey`](xref:SixLabors.ImageSharp.Web.Caching.UriRelativeLowerInvariantCacheKey) to turn the request path and command collection into a canonical cache key.
- [`SHA256CacheHash`](xref:SixLabors.ImageSharp.Web.Caching.SHA256CacheHash) to hash that key into the stored filename.
- [`ImageSharpMiddlewareOptions.CacheHashLength`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.CacheHashLength) to control how many hash characters are kept.

If you need cache entries to vary by host or some other request detail, swap the key implementation with [`SetCacheKey<T>()`](xref:SixLabors.ImageSharp.Web.ImageSharpBuilderExtensions.SetCacheKey*) or [`SetCacheHash<T>()`](xref:SixLabors.ImageSharp.Web.ImageSharpBuilderExtensions.SetCacheHash*):

```csharp
using SixLabors.ImageSharp.Web;
using SixLabors.ImageSharp.Web.Caching;

builder.Services.AddImageSharp(options =>
{
    options.CacheHashLength = 16;
})
.SetCacheKey<UriAbsoluteLowerInvariantCacheKey>()
.SetCacheHash<SHA256CacheHash>();
```

## Preserve the v1 Cache Layout

If you are migrating an older installation and want new requests to keep using the v1 cache naming layout, switch to [`LegacyV1CacheKey`](xref:SixLabors.ImageSharp.Web.Caching.LegacyV1CacheKey) and keep the folder depth aligned with the hash length:

```csharp
using SixLabors.ImageSharp.Web;
using SixLabors.ImageSharp.Web.Caching;

builder.Services.AddImageSharp(options =>
{
    options.CacheHashLength = 12;
})
.Configure<PhysicalFileSystemCacheOptions>(options =>
{
    options.CacheFolderDepth = 12;
})
.SetCacheKey<LegacyV1CacheKey>();
```

## Azure Blob Storage Cache

Install the Azure provider package:

```bash
dotnet add package SixLabors.ImageSharp.Web.Providers.Azure
```

Then replace the default cache backend with [`SetCache<T>()`](xref:SixLabors.ImageSharp.Web.ImageSharpBuilderExtensions.SetCache*):

```csharp
using Azure.Storage.Blobs.Models;
using SixLabors.ImageSharp.Web;
using SixLabors.ImageSharp.Web.Azure.Caching;

builder.Services.AddImageSharp()
    .Configure<AzureBlobStorageCacheOptions>(options =>
    {
        options.ConnectionString = builder.Configuration["Azure:ConnectionString"]!;
        options.ContainerName = "imagesharp-cache";
        options.CacheFolder = "processed";

        AzureBlobStorageCache.CreateIfNotExists(options, PublicAccessType.None);
    })
    .SetCache<AzureBlobStorageCache>();
```

Cached objects use the hashed request key as the blob name, and the cache metadata is stored in blob properties alongside the object.

## AWS S3 Cache

Install the AWS provider package:

```bash
dotnet add package SixLabors.ImageSharp.Web.Providers.AWS
```

Then replace the default cache backend with [`SetCache<T>()`](xref:SixLabors.ImageSharp.Web.ImageSharpBuilderExtensions.SetCache*):

```csharp
using Amazon.S3;
using SixLabors.ImageSharp.Web;
using SixLabors.ImageSharp.Web.AWS.Caching;

builder.Services.AddImageSharp()
    .Configure<AWSS3StorageCacheOptions>(options =>
    {
        options.BucketName = "imagesharp-cache";
        options.Region = "us-east-1";
        options.AccessKey = builder.Configuration["AWS:AccessKey"];
        options.AccessSecret = builder.Configuration["AWS:SecretKey"];
        options.CacheFolder = "processed";

        AWSS3StorageCache.CreateIfNotExists(options, S3CannedACL.Private);
    })
    .SetCache<AWSS3StorageCache>();
```

Cached objects use the hashed request key as the object key, and the response metadata needed by the middleware is stored with the object.

## Related Topics

- [Getting Started](gettingstarted.md)
- [Image Providers](imageproviders.md)
- [Securing Requests](security.md)
- [Extensibility](extensibility.md)
