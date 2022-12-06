# Image Providers

ImageSharp.Web determines the location of a source image to process via the registration and application of image providers. 
  
>[!NOTE]
>It is possible to configure your own image provider by implementing and registering your own version of the @"SixLabors.ImageSharp.Web.Providers.IImageProvider" interface.

The following providers are available for the middleware. Multiples providers can be registered and will be queried for a URL match in the order of registration.

### PhysicalFileSystemProvider

The @"SixLabors.ImageSharp.Web.Providers.PhysicalFileSystemProvider" will allow the processing and serving of image files from the [web root](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/?view=aspnetcore-3.1&tabs=macos#web-root) folder. This is the default provider installed when configuring the middleware.  
  
Url matching for this provider follows the same rules as conventional static files.

### AzureBlobStorageImageProvider  
  
This provider allows the processing and serving of image files from [Azure Blob Storage](https://docs.microsoft.com/en-us/azure/storage/blobs/) and is available as an external package installable via [NuGet](https://www.nuget.org/packages/SixLabors.ImageSharp.Web.Providers.Azure)

# [Package Manager](#tab/tabid-1)

```bash
PM > Install-Package SixLabors.ImageSharp.Web.Providers.Azure -Version VERSION_NUMBER
```

# [.NET CLI](#tab/tabid-2)

```bash
dotnet add package SixLabors.ImageSharp.Web.Providers.Azure --version VERSION_NUMBER
```

# [PackageReference](#tab/tabid-3)

```xml
<PackageReference Include="SixLabors.ImageSharp.Web.Providers.Azure" Version="VERSION_NUMBER" />
```

# [Paket CLI](#tab/tabid-4)

```bash
paket add SixLabors.ImageSharp.Web.Providers.Azure --version VERSION_NUMBER
```

***

Once installed the provider @"SixLabors.ImageSharp.Web.Providers.Azure.AzureBlobContainerClientOptions" can be configured as follows:


```c#  
// Configure and register the containers.  
// Alteratively use `appsettings.json` to represent the class and bind those settings.
.Configure<AzureBlobStorageImageProviderOptions>(options =>
{
    // The "BlobContainers" collection allows registration of multiple containers.
    options.BlobContainers.Add(new AzureBlobContainerClientOptions
    {
        ConnectionString = {AZURE_CONNECTION_STRING},
        ContainerName = {AZURE_CONTAINER_NAME}
    });
})
.AddProvider<AzureBlobStorageImageProvider>()
```

Url requests are matched in accordance to the following rule:  
  
```bash
/{CONTAINER_NAME}/{BLOB_FILENAME} 
```

### AWSS3StorageImageProvider  
  
This provider allows the processing and serving of image files from [Amazon Simple Storage Service (Amazon S3)](https://aws.amazon.com/s3/) and is available as an external package installable via [NuGet](https://www.nuget.org/packages/SixLabors.ImageSharp.Web.Providers.AWS)

# [Package Manager](#tab/tabid-1a)

```bash
PM > Install-Package SixLabors.ImageSharp.Web.Providers.AWS -Version VERSION_NUMBER
```

# [.NET CLI](#tab/tabid-2a)

```bash
dotnet add package SixLabors.ImageSharp.Web.Providers.AWS --version VERSION_NUMBER
```

# [PackageReference](#tab/tabid-3a)

```xml
<PackageReference Include="SixLabors.ImageSharp.Web.Providers.AWS" Version="VERSION_NUMBER" />
```

# [Paket CLI](#tab/tabid-4a)

```bash
paket add SixLabors.ImageSharp.Web.Providers.AWS --version VERSION_NUMBER
```

***

Once installed the cache @SixLabors.ImageSharp.Web.Providers.AWS.AWSS3StorageImageProviderOptions can be configured as follows:

```c#  
// Configure and register the buckets.  
// Alteratively use `appsettings.json` to represent the class and bind those settings.
.Configure<AWSS3StorageImageProviderOptions>(options =>
{
    // The "S3Buckets" collection allows registration of multiple buckets.
    options.S3Buckets.Add(new AWSS3BucketClientOptions
    {
        Endpoint = AWS_ENDPOINT,
        BucketName = AWS_BUCKET_NAME,
        AccessKey = AWS_ACCESS_KEY,
        AccessSecret = AWS_ACCESS_SECRET,
        Region = AWS_REGION
    });
})
.AddProvider<AWSS3StorageImageProvider>()
```

Url requests are matched in accordance to the following rule:  
  
```bash
/{AWS_BUCKET_NAME}/{OBJECT_FILENAME} 
```

Which is to say that the AWS S3 bucket name must appear in the Url so it can be matched with the correct S3 configuration. If you wished to override this and provide a deafult, this can be done using [URL Rewriting middleware](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/url-rewriting?view=aspnetcore-6.0).
