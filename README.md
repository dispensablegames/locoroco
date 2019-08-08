# Locoroco

The world's favourite blob game written in Lua with LOVE.

## Instructions for playing while in development (Linux-Only)

First acquire [LOVE](https://love2d.org/), the game engine used to write this game. Ideally, download from your repository's package manager, not from the website, e.g., if you use Ubuntu, install `love` using `apt`. 

Then install `luarocks`, the package manager for the Lua language. Again, download from your repository's package manager.

Then use `luarocks` to install `xml2lua`, the library used to parse XML files used in this project:

```
luarocks install xml2lua --local
```

Finally, acquire the game files.

```
git clone https://github.com/dispensablegames/locoroco.git
```

This will create a new folder named `locoroco` inside the current folder with all the source code.

Now you are ready to run the game. 

First run this line to add the package `xml2lua` to your PATH.

```
eval $(luarocks path --bin)
```

The navigate to the `locoroco` folder created in the previous step. Then run

`love src`

And enjoy!
