# Image Providers

Image providers answer one question: where does the source image come from? Every incoming request is offered to the registered providers in order, and the first provider whose `Match` function returns `true` owns the request.

That means provider order matters. If two providers can both match the same path, put the more specific one first or narrow its `Match` predicate so the wrong provider does not claim the request.

## Default Physical Filesystem Provider

[`PhysicalFileSystemProvider`](xref:SixLabors.ImageSharp.Web.Providers.PhysicalFileSystemProvider) is the default source provider registered by `AddImageSharp()`.

- It resolves images from the web root by default.
- [`PhysicalFileSystemProviderOptions.ProviderRootPath`](xref:SixLabors.ImageSharp.Web.Providers.PhysicalFileSystemProviderOptions.ProviderRootPath) can be `null`, absolute, or relative to the application content root.
- [`PhysicalFileSystemProviderOptions.ProcessingBehavior`](xref:SixLabors.ImageSharp.Web.Providers.PhysicalFileSystemProviderOptions.ProcessingBehavior) still defaults to [`ProcessingBehavior.CommandOnly`](xref:SixLabors.ImageSharp.Web.Providers.ProcessingBehavior.CommandOnly), but the default middleware callback injects `autoorient=true` when the request does not already contain `autoorient`, so local image requests are usually processed anyway.

```csharp
using SixLabors.ImageSharp.Web;
using SixLabors.ImageSharp.Web.Providers;

builder.Services.AddImageSharp()
    .Configure<PhysicalFileSystemProviderOptions>(options =>
    {
        options.ProviderRootPath = "assets";
        options.ProcessingBehavior = ProcessingBehavior.CommandOnly;
    });
```

If you want a provider fixed to `IWebHostEnvironment.WebRootFileProvider` with no extra options, [`WebRootImageProvider`](xref:SixLabors.ImageSharp.Web.Providers.WebRootImageProvider) is also available.

If you want truly command-only processing for local files, changing `ProcessingBehavior` is no longer sufficient on its own. You must also replace or suppress the default [`OnParseCommandsAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnParseCommandsAsync) behavior that inserts `autoorient=true`.

## Provider Matching and Ordering

ImageSharp.Web stops at the first provider whose `Match` function returns `true`. It does not continue searching if that provider later decides the request is invalid, so keep these rules in mind:

- Register more specific providers before more general ones.
- Keep `Match` predicates mutually exclusive whenever possible.
- Use `InsertProvider(...)` when provider precedence matters more than registration order.

Cloud providers in particular usually want a path prefix such as a container or bucket name so they can distinguish their requests cheaply.

## Azure Blob Storage

Install the Azure provider package:

```bash
dotnet add package SixLabors.ImageSharp.Web.Providers.Azure
```

Then configure one or more containers:

```csharp
using SixLabors.ImageSharp.Web;
using SixLabors.ImageSharp.Web.Azure.Providers;

builder.Services.AddImageSharp()
    .ClearProviders()
    .Configure<AzureBlobStorageImageProviderOptions>(options =>
    {
        options.BlobContainers.Add(new AzureBlobContainerClientOptions
        {
            ConnectionString = builder.Configuration["Azure:ConnectionString"]!,
            ContainerName = "public-images"
        });
    })
    .AddProvider<AzureBlobStorageImageProvider>();
```

Requests are matched by container name at the start of the path:

```text
/public-images/avatars/jane.png?width=200
```

[`AzureBlobStorageImageProvider`](xref:SixLabors.ImageSharp.Web.Azure.Providers.AzureBlobStorageImageProvider) uses [`ProcessingBehavior.All`](xref:SixLabors.ImageSharp.Web.Providers.ProcessingBehavior.All), so it can serve both processed and commandless requests.

## AWS S3

Install the AWS provider package:

```bash
dotnet add package SixLabors.ImageSharp.Web.Providers.AWS
```

Then configure one or more buckets:

```csharp
using SixLabors.ImageSharp.Web;
using SixLabors.ImageSharp.Web.AWS.Providers;

builder.Services.AddImageSharp()
    .ClearProviders()
    .Configure<AWSS3StorageImageProviderOptions>(options =>
    {
        options.S3Buckets.Add(new AWSS3BucketClientOptions
        {
            BucketName = "public-images",
            Region = "us-east-1",
            AccessKey = builder.Configuration["AWS:AccessKey"],
            AccessSecret = builder.Configuration["AWS:SecretKey"]
        });
    })
    .AddProvider<AWSS3StorageImageProvider>();
```

Requests are matched by bucket name at the start of the path:

```text
/public-images/avatars/jane.png?width=200
```

If your public URL shape does not naturally include the bucket name, use URL rewriting before ImageSharp.Web or implement a custom provider.

## Implementing Your Own Provider

Implement [`IImageProvider`](xref:SixLabors.ImageSharp.Web.Providers.IImageProvider) when you need a new source backend. Your provider is responsible for three things:

- deciding whether it owns the request via `Match`;
- deciding whether the request is valid via `IsValidRequest(...)`;
- returning an [`IImageResolver`](xref:SixLabors.ImageSharp.Web.Resolvers.IImageResolver) that can open the source stream and report source metadata.

If your source already fits an `IFileProvider`-style model, [`FileProviderImageProvider`](xref:SixLabors.ImageSharp.Web.Providers.FileProviderImageProvider) is the easiest base class to start from.

## Related Topics

- [Getting Started](gettingstarted.md)
- [Image Caches](imagecaches.md)
- [Extensibility](extensibility.md)
- [Troubleshooting](troubleshooting.md)
