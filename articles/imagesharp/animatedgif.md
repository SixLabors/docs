# Create an animated GIF

The following example demonstrates how to create a animated gif from several single images.
The different image frames will be images with different colors.

```c#
// Image dimensions of the gif.
const int width = 100;
const int height = 100;

// Delay between frames in (1/100) of a second.
const int frameDelay = 100;

// For demonstration: use images with different colors.
Color[] colors = {
    Color.Green,
    Color.Red
};

// Create empty image.
using Image<Rgba32> gif = new(width, height, Color.Blue);

// Set animation loop repeat count to 5.
var gifMetaData = gif.Metadata.GetGifMetadata();
gifMetaData.RepeatCount = 5;
for (int i = 0; i < colors.Length; i++)
{
    // Create a color image, which will be added to the gif.
    using Image<Rgba32> image = new(width, height, colors[i]);

    // Set the duration of the frame delay.
    GifFrameMetadata metadata = image.Frames.RootFrame.Metadata.GetGifMetadata();
    metadata.FrameDelay = frameDelay;

    // Add the color image to the gif.
    gif.Frames.AddFrame(image.Frames.RootFrame);
}

// Save the final result.
gif.SaveAsGif("output.gif");
```