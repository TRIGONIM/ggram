## How to use

### With pure lua (outside Garry's Mod)

Just create the file with your bot's code and run it with `lua file.lua`

> In pure lua realm you need to place `local ggram = require("ggram")` at the beginning of the file and `ggram.idle()` at the end of file

### In Garry's Mod

1. Take a look at the bot-launcher for Garry's Mod on [this page](/info/running_within_garrysmod.md).
2. Create the file \_init.lua at `/addons/ggram-mod/lua/ggram/bots/anyname/_init.lua` and start writing your code

> In Garry's Mod realm you don't need to place `require("ggram")` at the beginning of the file or do `ggram.idle()` at the end of file.
>
> But you can do it if you want to make the code more universal. It will not lead to errors
