# LocoRoco

The world's favourite blob game written in Lua with LOVE. 

## Current Progress

Take a look at these gifs of the game in action:

![Video of Gameplay](https://raw.githubusercontent.com/dispensablegames/locoroco/master/previewfiles/v1.gif)

![Video of Gameplay](https://raw.githubusercontent.com/dispensablegames/locoroco/master/previewfiles/v2.gif)

## Levels

You can design your own LocoRoco levels in any vector graphics editor with XML support (e.g. Inkscape).

### Quickstart

A LocoRoco level file is an `.svg` with additional restrictions:
- A layer with `id:meta` for placing meta objects
- A path with `spawn:true` in the meta layer; this dictates where the blobs spawn when the level is loaded

After ensuring you have these requirements, just draw your level!

A level file must also be accompanied with an assets file which is also an `.svg`, has the same name as the level file, and can be empty. Place the level file in the `levels` directory and the assets file in the `assets` directory.

### Details

By default, paths drawn in the level file become regular static hardbodies, like walls and platforms. 

Any path drawn in a layer (including sublayers) with `id:background` becomes part of the background.

Any path drawn in a layer with `id:objects` is not rendered on the screen (this is useful for putting your paths that are used for `use`s only).

Any `use` is part of the background. 

For performance, use `use` for repeated background objects (bushes, grass, etc.) rather than many copies of `paths`. This is because any `use` of the same path does not need to be rendered after the parent path is rendered, but every `path` must be rendered individually.

Any paths in the assets file become floating background objects (recommended for: flowers, leaves, etc.). 
