# PicVim

PicVim is a Neovim plugin that allows you to view and interact with images directly in Neovim. It supports various image formats such as PNG, JPG, GIF, BMP, and more, offering basic functionality like zooming, rotating, and panning.

## Features

- View images in Neovim.
- Zoom in and out using keybindings.
- Rotate the image with configurable keybindings.
- Pan the image using arrow keys or specific keybindings.
- Automatically scale and adjust images for optimal viewing.

## Installation

Use your prefferred package manager to install PicVim.

### Eg. Using lazy.nvim

If you use [lazy.nvim](https://github.com/folke/lazy.nvim), you can install PicVim by adding the following to your configuration:

```lua
{
    'your-username/picvim',
}
```

## Setup

To activate the plugin, add the following to your init.lua configuration file (not needed if using lazy.nvim):

```lua
require'picvim'.setup()
```

## Auto-commands

The plugin automatically activates for image files (.png, .jpg, .jpeg, .gif, .bmp) upon opening. It sets the buffer to a "non-file" type to display the image correctly.

## Keybindings

    h, Left Arrow – Pan left.
    l, Right Arrow – Pan right.
    j, Down Arrow – Pan down.
    k, Up Arrow – Pan up.
    =, + – Zoom in.
    - – Zoom out.
    t – Rotate clockwise (30 degrees).
    T – Rotate counterclockwise (30 degrees).
    o – Reset image position and rotation.
    r – Redraw the image.

## Dependencies

`ImageMagick` for image manipulation.
`Neovim` 0.5.0 or higher.

## Troubleshooting

Ensure you have `ImageMagick` installed for image scaling and conversion functionality.
If the image fails to load, check that the file path is correct.

## License

This project is licensed under the MIT License – see the LICENSE file for details.
