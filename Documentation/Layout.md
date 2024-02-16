# Layout

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="_images/StreamDeckLayout.dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="_images/StreamDeckLayout.light.svg">
  <img alt="An illustration of how layers are arranged in StreamDeckLayout" src="_images/StreamDeckLayout.light.svg">
</picture>

[...] Values will differ, depending on which view is the next parent in hierarchy. So in a `keyAreaView` of `StreamDeckLayout`, the `size` will reflect the size of the whole area. While in the `keyView` of a `StreamDeckKeypadLayout`, the `size` will reflect the size of the key canvas.