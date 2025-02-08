# 🖼️ PicVim

> ⚠️ **Note:** This project is still early in development, so it may be a bit buggy. If you find any bugs, please let me know!

---

PicVim is a Neovim plugin that allows you to view and interact with images directly in Neovim. It supports various image formats such as PNG, JPG, GIF, BMP, and more, offering basic functionality like zooming, rotating, and panning.

---

### Key Features:
- 🚀 **Quick Image Viewing:** View images directly in Neovim.
- 🔄 **Basic Image Interaction:** Zoom, rotate, and pan.
- 🌐 **Multi-format Support:** Works with PNG, JPG, GIF, BMP, and more.


## Demo


https://github.com/user-attachments/assets/b8279faa-4e91-4fda-880b-4d4d7cab117d


### ⚠️  Notes:
- 🔧 **Early Development:** This is a work in progress, so expect some bugs. Contributions are welcome!
- 🚫 **Not a replacement for `image.nvim`:** This plugin can't render images in `README.md` files.
- **Only support for kitty:** Only supports kitty graphics.


## 📖 Usage

To use PicVim, simply open an image file in Neovim and the image will be displayed in the buffer. You can interact with the image using the provided keybindings.


## ✨ Features

- View images in Neovim.
- Zoom in and out using keybindings.
- Rotate the image with configurable keybindings.
- Pan the image using arrow keys or specific keybindings.
- Automatically scale and adjust images for optimal viewing.


## ⚙️  Installation

Use your prefferred package manager to install PicVim.


### Eg. Using lazy.nvim

If you use [lazy.nvim](https://github.com/folke/lazy.nvim), you can install PicVim by adding the following to your configuration:

```lua
{
    "Toprun123/picvim",
    config = function()
        require'picvim'.setup()
    end,
},
```

## 🔧 Setup

To activate the plugin, add the following to your init.lua configuration file:

```lua
require'picvim'.setup()
```

## 🛠️ Autocommands

The plugin automatically activates for image files (.png, .jpg, .jpeg, .gif, .bmp) upon opening. It sets the buffer to a "non-file" type to display the image correctly.

## ⌨️  Keybindings

    h, Left Arrow – Pan left.
    l, Right Arrow – Pan right.
    j, Down Arrow – Pan down.
    k, Up Arrow – Pan up.
    =, + – Zoom in.
    - – Zoom out.
    t – Rotate clockwise (30 degrees).
    T – Rotate counterclockwise (30 degrees).
    o – Reset image position and rotation.
    r – Rerender the image.

## 📦 Dependencies

`ImageMagick` for image manipulation.
`Neovim` 0.5.0 or higher.
`Kitty` for displaying the image.

##  TODO:

- [x] Allow zooming image.
- [x] Allow panning across the image.
- [x] Support image rotation.
- [x] Add support for non-png raster images.
- [ ] Add support for svg files.
- [ ] Make Keybinds configurable.
- [ ] Expose functions to handle the images.

