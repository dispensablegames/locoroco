# LocoRoco

The world's favourite blob game written in Lua with LOVE. Heavily based off of Sony's *LocoRoco* in terms of visuals and mechanics. 

## Controls

Use the left and right arrow keys to tilt the world. Hold down both directions for a second, then let go, to jump. Tap up to split into smaller locos, and hold down to merge them back together. 

## Current Progress

Take a look at these gifs of the game in action:

![Video of Gameplay](https://raw.githubusercontent.com/dispensablegames/locoroco/master/previewfiles/v1.gif)

![Video of Gameplay](https://raw.githubusercontent.com/dispensablegames/locoroco/master/previewfiles/v2.gif)

## Levels

You can design your own LocoRoco levels in any vector graphics editor with XML support (e.g. Inkscape).

### Quickstart

A LocoRoco level file is an `.svg` with additional restrictions:
- A layer with `id:meta` for placing meta objects
- A `path` with `spawn:true` in the meta layer; this dictates where the blob spawns when the level is loaded

After ensuring you have these requirements, just draw your level! Colours are conserved, but not the alpha channel.

A level file must also be accompanied with an assets file which is also an `.svg`, has the same name as the level file, and can be empty. Place the level file in the `levels` directory and the assets file in the `assets` directory.

### Details

By default, `path`s drawn in the level file become regular static hardbodies, like walls and platforms. 

Any `path` drawn in a layer (including sublayers) with `id:background` becomes part of the background.

Any `path` drawn in a layer with `id:objects` is not rendered on the screen (this is useful for putting your `path`s that are used for `use`s only).

Any `use` is part of the background. For performance, use `use` for repeated background objects (bushes, grass, etc.) rather than many copies of `paths`. This is because any `use` of the same `path` does not need to be rendered after the parent path is rendered, but every `path` must be rendered individually.

Any `path`s in the assets file become floating background objects (recommended for: flowers, leaves, etc.). 
