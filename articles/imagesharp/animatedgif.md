# Create an animated GIF

The following example demonstrates how to create a animated gif from serveral single images.
The different image frames will be images with differnt colors.

```c#
// Image dimensions of the gif.
int width = 100;
int height = 100;

// Delay between frames in (1/100) of a second.
int frameDelay = 100;

// For demonstration: use images with different colors.
List<Color> colors = new List<Color>()
{
    Color.Blue,
    Color.Green,
    Color.Red
};

// Create empty image.
using (var gif = new Image<Rgba32>(width, height))
{
    for (int i = 0; i < colors.Count; i++)
    {
        // Create a color image, which will be inserted in the gif at position i.
        using var image = new Image<Rgba32>(width, height);
        image.Mutate(img => img.BackgroundColor(colors[i]));

        // Set the duration of the image.
        GifFrameMetadata gifMetadata =
            image.Frames.RootFrame.Metadata.GetFormatMetadata(GifFormat.Instance);
        gifMetadata.FrameDelay = frameDelay;

        // Add the color image to the gif.
        gif.Frames.InsertFrame(i, image.Frames.RootFrame);
    }

    // Save the final result.
    gif.SaveAsGif("output.gif");
}
```