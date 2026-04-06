# Securing Requests

Once you let clients describe image transformations in the URL, you usually want some control over who can generate those URLs and which command shapes are allowed. ImageSharp.Web gives you two main tools for that: HMAC signing for request authorization and preset-only parsing for fixed command sets.

## Require HMAC Tokens for Command Requests

Set [`ImageSharpMiddlewareOptions.HMACSecretKey`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.HMACSecretKey) to enable request signing:

```csharp
using SixLabors.ImageSharp.Web;

builder.Services.AddImageSharp(options =>
{
    options.HMACSecretKey = Convert.FromBase64String(
        builder.Configuration["ImageSharp:HmacKey"]!);
});
```

Once a non-empty secret key is configured, any request that still contains recognized commands after sanitization must also include a matching `hmac` query parameter. If the token is missing or invalid, the middleware returns HTTP 400.

Use one stable secret across all app instances that must validate the same URLs. Rotating the secret invalidates previously generated signed URLs.

## How the Default Token Is Computed

By default, ImageSharp.Web computes HMAC-SHA256 over a lower-invariant relative URL built from:

- the request path base;
- the request path;
- the sanitized command collection.

That behavior is important because the middleware strips unknown commands before validation. The easiest way to stay in sync with the server is to let ImageSharp.Web compute the token for you instead of re-implementing the canonicalization rules yourself.

>[!NOTE]
>`OnParseCommandsAsync` runs after the middleware computes the HMAC candidate value. If you mutate commands there, treat that callback as trusted server-side logic rather than part of the client-signable contract.

## Generate Signed URLs on the Server

[`RequestAuthorizationUtilities`](xref:SixLabors.ImageSharp.Web.RequestAuthorizationUtilities) is the simplest server-side API for generating a valid token:

```csharp
using SixLabors.ImageSharp.Web;

RequestAuthorizationUtilities auth =
    app.Services.GetRequiredService<RequestAuthorizationUtilities>();

string path = "/images/hero.jpg?width=400&format=webp";
string token = auth.ComputeHMAC(path, CommandHandling.Sanitize)!;
string signedPath = $"{path}&{RequestAuthorizationUtilities.TokenCommand}={token}";
```

Use [`CommandHandling.Sanitize`](xref:SixLabors.ImageSharp.Web.CommandHandling.Sanitize) unless you have a very specific reason to hash unsanitized commands. That keeps token generation aligned with the middleware's own validation path.

## Customize the Hash Algorithm or Canonicalization

If the default HMAC-SHA256 plus lower-invariant relative URL is not the contract you want, override [`OnComputeHMAC`](xref:SixLabors.ImageSharp.Web.Middleware.ImageSharpMiddlewareOptions.OnComputeHMAC):

```csharp
using Microsoft.AspNetCore.Http;
using SixLabors.ImageSharp.Web;

builder.Services.AddImageSharp(options =>
{
    options.OnComputeHMAC = (context, secret) =>
    {
        string uri = CaseHandlingUriBuilder.BuildRelative(
            CaseHandlingUriBuilder.CaseHandling.LowerInvariant,
            context.Context.Request.PathBase,
            context.Context.Request.Path,
            QueryString.Create(context.Commands));

        return HMACUtilities.ComputeHMACSHA512(uri, secret);
    };
});
```

If you change the canonicalization rules or hash algorithm, every URL generator in your system must use the same logic.

## Let Razor Tag Helpers Add the Token

If you are rendering image URLs in Razor, the built-in tag helpers can generate the token automatically once `HMACSecretKey` is configured. See [Tag Helpers](taghelpers.md) for the Razor setup and examples.

## Use Presets to Limit the Exposed Command Surface

If you do not want clients to submit arbitrary commands at all, switch to [`PresetOnlyQueryCollectionRequestParser`](xref:SixLabors.ImageSharp.Web.Commands.PresetOnlyQueryCollectionRequestParser):

```csharp
using SixLabors.ImageSharp.Web;
using SixLabors.ImageSharp.Web.Commands;

builder.Services.AddImageSharp()
    .SetRequestParser<PresetOnlyQueryCollectionRequestParser>()
    .Configure<PresetOnlyQueryCollectionRequestParserOptions>(options =>
    {
        options.Presets["avatar"] = "width=128&height=128&rmode=crop&format=webp";
        options.Presets["card"] = "width=640&height=360&rmode=crop";
    });
```

That makes requests look like this:

```text
/images/user.jpg?preset=avatar
```

Only the named preset is expanded into commands. Other free-form query-string keys are ignored by that parser. You can combine presets with HMAC signing if you want both a small command surface and signed URLs.

## Related Topics

- [Configuration and Pipeline](configuration.md)
- [Processing Commands](processingcommands.md)
- [Tag Helpers](taghelpers.md)
- [Troubleshooting](troubleshooting.md)
