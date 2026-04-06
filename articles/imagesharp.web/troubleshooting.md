# Troubleshooting

Most ImageSharp.Web problems come down to one of five layers: middleware order, provider matching, command parsing, request signing, or cache configuration. This page groups the common failures that way so you can check the right layer first.

## Query Strings Are Ignored

If `/images/photo.jpg?width=400` behaves the same as `/images/photo.jpg`, check these first:

- `app.UseImageSharp()` must run before `app.UseStaticFiles()`.
- If you replaced [`OnParseCommandsAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnParseCommandsAsync), make sure you did not accidentally remove the default `autoorient=true` insertion or other command mutations you rely on.
- A provider may be matching the request before the provider you expected. Provider order matters.

## I Get HTTP 400 After Enabling HMAC

Once [`ImageSharpMiddlewareOptions.HMACSecretKey`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.HMACSecretKey) is configured, requests that include ImageSharp commands must include a valid `hmac` token.

Useful checks:

- Generate the token with [`RequestAuthorizationUtilities`](xref:SixLabors.ImageSharp.Web.RequestAuthorizationUtilities) instead of recreating the canonicalization logic by hand.
- Use [`CommandHandling.Sanitize`](xref:SixLabors.ImageSharp.Web.CommandHandling.Sanitize) when generating the token unless you intentionally need unsanitized commands.
- Make sure all app instances share the same secret key.
- Remember that unknown commands are stripped before validation, so signing a URL with extra application-specific keys will not match unless you remove them first or translate them in a custom request parser.

## I Get a 404 or the Original Image Instead of a Processed One

That usually means the source image was never resolved by the expected provider.

Check these cases:

- The file is outside the configured `ProviderRootPath`.
- The request path does not include the expected bucket or container prefix for the AWS or Azure providers.
- The source file extension is not recognized by the active ImageSharp format configuration.
- You switched to [`PresetOnlyQueryCollectionRequestParser`](xref:SixLabors.ImageSharp.Web.Commands.PresetOnlyQueryCollectionRequestParser) and the request uses a missing or misspelled `preset` value.

## Physical Cache or Provider Root Path Cannot Be Determined

The physical provider and physical cache default to the web root when their root paths are `null`. If your app does not define a web root, configure both explicitly:

- [`PhysicalFileSystemProviderOptions.ProviderRootPath`](xref:SixLabors.ImageSharp.Web.Providers.PhysicalFileSystemProviderOptions.ProviderRootPath)
- [`PhysicalFileSystemCacheOptions.CacheRootPath`](xref:SixLabors.ImageSharp.Web.Caching.PhysicalFileSystemCacheOptions.CacheRootPath)

Relative paths are resolved against the application content root.

## Tag Helpers Do Nothing

If `imagesharp-*` attributes are not changing the rendered `src`, check these first:

- `_ViewImports.cshtml` must contain `@addTagHelper *, SixLabors.ImageSharp.Web`.
- `ImageTagHelper` is for local application URLs and skips `http`, `ftp`, and `data` sources.
- Automatic HMAC generation only happens when `HMACSecretKey` is configured and the final URL contains recognized commands.

## Parsed Values Differ Between Machines

By default, ImageSharp.Web parses commands with invariant culture. If you set [`UseInvariantParsingCulture`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.UseInvariantParsingCulture) to `false`, separators and decimal parsing follow `CultureInfo.CurrentCulture`.

That is useful for specialized local workflows, but it also means a value like `0.5` versus `0,5` can behave differently across environments.

## Images Stopped Auto-Rotating After I Customized `OnParseCommandsAsync`

The default [`OnParseCommandsAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnParseCommandsAsync) callback inserts `autoorient=true` when the request does not already contain `autoorient`.

If you assign your own callback without chaining the previous delegate, you remove that default behavior. Preserve the existing callback first unless you intentionally want to opt out:

```csharp
using SixLabors.ImageSharp.Web.Middleware;

Func<ImageCommandContext, Task> defaultParse = options.OnParseCommandsAsync;

options.OnParseCommandsAsync = async context =>
{
    await defaultParse(context);

    // Your additional command mutations here.
};
```

## Colors or Compression Changed After I Replaced `options.Configuration`

Check whether you replaced [`ImageSharpMiddlewareOptions.Configuration`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.Configuration) with `Configuration.Default.Clone()` or another custom configuration.

That changes two things at once:

- You replace the middleware's built-in JPEG, PNG, and WebP encoder registrations.
- If [`OnBeforeLoadAsync`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnBeforeLoadAsync) still returns `null`, decode falls back to [`ColorProfileHandling.Compact`](xref:SixLabors.ImageSharp.Formats.ColorProfileHandling.Compact) instead of [`ColorProfileHandling.Convert`](xref:SixLabors.ImageSharp.Formats.ColorProfileHandling.Convert).

If you want custom encoders and the original ICC-conversion behavior, clone the current middleware configuration, assign it back, and return explicit [`DecoderOptions`](xref:SixLabors.ImageSharp.Formats.DecoderOptions) from `OnBeforeLoadAsync`.

## Cached Output Does Not Refresh

ImageSharp.Web keeps using a cached result until one of these changes:

- the source last-write time changes;
- the cache entry ages beyond [`CacheMaxAge`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.CacheMaxAge);
- the cached entry disappears and the middleware has to regenerate it.

If you are replacing source files in place, make sure the backing store actually updates the source last-write metadata the provider sees.

## A Good Debugging Order

When an ImageSharp.Web request misbehaves, this order is usually productive:

1. Check middleware order.
2. Confirm which provider should own the request.
3. Confirm the parsed command set or preset name.
4. Check HMAC generation if signing is enabled.
5. Check cache roots, cache lifetime, and source last-write metadata.

## Related Topics

- [Getting Started](gettingstarted.md)
- [Configuration and Pipeline](configuration.md)
- [Securing Requests](security.md)
- [Extensibility](extensibility.md)
