<img align="left" width="80" src="https://i.imgur.com/AbYOj2T.png">

# ggram – Telegram Bot Framework

> 🇬🇧 🇺🇸 NEED TRANSLATORS. Please, make pull requests if you wanna help. Temporarily I recommend [deepl](https://www.deepl.com/translator) or ChatGPT to translate [this page](https://raw.githubusercontent.com/TRIGONIM/ggram/main/readme.md)

<p align="left">
	<img src="https://img.shields.io/github/languages/code-size/TRIGONIM/ggram">
	<img src="https://img.shields.io/github/license/TRIGONIM/ggram">
</p>

Create Telegram bots of any complexity in Lua

<img align="right" width="300" src="https://user-images.githubusercontent.com/9200174/135781831-dbb545a9-b3d9-4d0a-ba58-dd42935d35f0.png">

```lua
local bot = ggram("token")

bot.enable_polling() -- enables getUpdates loop

bot.command("start", function(ctx)
	ctx.reply.text("Hello @" .. ctx.from.username)
end)
```

Additional examples can be found in [/examples](/examples)

---

## 💡 Demo
[Here (click)](https://forum.gm-donate.net/t/idei-telegram-botov-dlya-vashego-servera/197) you can find links to running bots, as well as many ideas that can be implemented with this framework for your Garry's Mod server and much more. The possibilities are almost endless.

## ✨ Features
- Can work both on pure Lua, and on the Garry's Mod server
- Does NOT require any third-party .dll or WEB scripts
- Very minimalistic and easily expandable
- If Telegram adds methods that are not already in the bot, they are very easy to add with a 3-line [module](/info/making_extensions.md)
- [Possibility](/lua/ggram/includes/surprise) sending animations, documents, images

## 🚀 Installation

### 🏗 Docker

Download this repository and go to the downloaded folder. You can take a look at the contents of the [Dockerfile](/Dockerfile). It does not contain ggram itself. It installs the dependencies to make it work.

```bash
# create image
docker build -t ggramenv:latest .

# run example bot (echo.lua)
# dont forget to change bot token in the file
docker run -it \
	-e "LUA_PATH=/app/lua/?.lua;/app/lua/?/init.lua;;" \
	-v $PWD:/app ggramenv \
	lua app/examples/echo.lua

# 🎉
```

### 🐧 Linux / Mac

Install luarocks (package manager like apt but for lua)

```bash
sudo apt install luarocks # linux
# or
brew install luarocks # mac
```

Install ggram

```bash
luarocks install ggram # latest release
# or
luarocks install --server=https://luarocks.org/dev ggram # just latest
```

Make and run bot:
1. Create bot.lua file. You can choose any name for the file
2. Paste the contents of [/examples/echo.lua](/examples/echo.lua) into the file
3. Run file with `lua bot.lua`

**If any error was occur, check the troubleshooting part below**


### 🎮 Garry's Mod
1. Скачайте ggram с этого репозитория и установите в `/addons/ggram`
2. Создайте файл `/addons/ggram_bots/lua/ggram/bots/anyname/_init.lua`
3. Заполните его содержимым демонстративного бота из папки [/examples](/examples), указав токен с [@BotFather](https://t.me/BotFather)

## 📚 Docs
- 🤔 [Objects description](/info/understanding_things.md) - What is and how to use update, context, middleware and reply objects
- 🗂 [Folders structure](/info/project_structure.md) - Only for garrysmod users
- 🆙 [Creating extensions/modules](/info/making_extensions.md) - Adding new methods, handlers, utils

## 😮 Development tips and tricks

> Не актуально для Garry's Mod

### launcher.lua

If you plan to create several bots, then instead of using separate files for each bot, you can use one file, which will run all the other bots about this scheme:

```lua
-- Optionally, the path to the folder with the modules
package.path = string.format("%s;%s;%s",
	"./path/?.lua",
	"./path/?/init.lua",
package.path)

-- Inluding ggram
local ggram = require("ggram")

-- List of bot code files
local bots = {"bot_file1", "bot_file2"}
for _,bot_name in ipairs(bots) do
	assert(pcall(require, bot_name))
	print(bot_name .. " loaded")
end

ggram.idle()
```

### Only one polling server

> Для тех, кто хочет работать с кучей ботов без личного веб сервера

Я [сделал микросервис](https://blog.amd-nick.me/poll-gmod-app-docs/), который принимает вебхуки от разных сервисов, а сам выступает в качестве polling сервера, подобно как работает getUpdates в Telegram. Все боты отправляют ему обновления, затем я HTTP GET запросом получаю их в одном месте.

Для работы с этим сервисом я написал небольшой фреймворк и если для вас это интересно, то я могу опубликовать гайд, как его применить.

## 👩‍🔧 Troubleshooting

[Take a look here](/info/troubleshooting.md)

If you still have problems, you can ask me in Telegram @amd_nick or [create an Issue](https://github.com/TRIGONIM/ggram/issues/new), in which you need to specify the system version, the version of `lua -v`, and step by step the actions you have taken to reproduce

## ☑︎ TODO

- Попробовать отвязать глупую затею с `ctx.reply.text`, `bot.handle_error` (доступ к методу по точке) и т.д. и сделать нормальные `ctx.reply:text()`. Обратную совместимость докрутить модулем. Не забыть поправить доки и примеры
