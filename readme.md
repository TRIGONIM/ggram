<img align="left" width="80" src="https://i.imgur.com/AbYOj2T.png">

# ggram – Lua Telegram Bot Framework

<p align="left">
	<img src="https://img.shields.io/github/languages/code-size/TRIGONIM/ggram">
	<img src="https://img.shields.io/github/license/TRIGONIM/ggram">
</p>

Create Telegram bots of any complexity in Lua

<img align="right" width="300" src="https://user-images.githubusercontent.com/9200174/135781831-dbb545a9-b3d9-4d0a-ba58-dd42935d35f0.png">

```lua
local ggram = require("ggram")
local bot = ggram("token")

require("ggram.polling").start(bot) -- enables getUpdates loop

bot.command("start", function(ctx)
	ctx.reply.text("Hello @" .. ctx.from.username)
end)
```

Additional examples can be found in [/examples](/examples)

---

## ✨ Features

- Can work both on pure Lua, and [on the Garry's Mod server](/info/running_within_garrysmod.md)
- Does NOT require any third-party .dll or WEB scripts
- Very minimalistic and easily expandable
- If Telegram adds methods that are not already in the bot, they are very easy to add with a 3-line [module](/info/making_extensions.md)
- [Possibility](/examples/send_multipart.lua) for sending animations, documents, images

## 🛠️ Installation

### Docker

Download this repository and go to the downloaded folder. You can take a look at the contents of the [Dockerfile](/Dockerfile). It does not contain ggram itself. It installs the dependencies to make it work.

```bash
# create image. You can choose any Dockerfile from this repo
docker build -t ggramenv:latest -f Dockerfile_tarantool .

# run example bot (echo.lua)
# dont forget to change bot token in the file
docker run -it \
	-e "LUA_PATH=/app/lua/?.lua;/app/lua/?/init.lua;;" \
	-v $PWD:/app ggramenv \
	lua app/examples/echo.lua

# 🎉
```

### Linux / Mac

Install luarocks (package manager like apt but for lua)

```bash
sudo apt install luarocks # linux
# or
brew install luarocks # mac
```

Install ggram

```bash
luarocks install ggram
```

## 🚀 Creating and launching a bot

1. Create bot.lua file. You can choose any name for the file.
2. Paste the contents of [/examples/echo.lua](/examples/echo.lua) into the file.
3. Run file with `lua bot.lua`. _If you want to run a bot on a **Garry's Mod** server, then [read this](/info/running_within_garrysmod.md)_.
4. Check out other examples in the [/examples](/examples) folder.

**If any error was occur, check the [troubleshooting](/info/troubleshooting.md) guide**

## 📚 Docs

All the docs are collected here: [click](/info)
