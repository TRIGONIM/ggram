## How to use

### With pure lua (outside Garry's Mod)

Just create the file with your bot's code and run it with `lua file.lua tmp`, where tmp is the name of temporary folder in which will be stored some necessary files (polling offsets, session middleware's data etc.)

> In pure lua realm you should `require("ggram.core")` at the beginning of the file and `ggram.idle()` at the end of file

### In Garry's Mod

Create the file \_init.lua at `/addons/ggram_bots/lua/ggram/bots/anyname/_init.lua` and start writing your code

> In Garry's Mod realm you don't need to place `require("ggram.core")` at the beginning of the file or do `ggram.idle()` at the end of file
