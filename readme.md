<img align="left" width="80" src="https://i.imgur.com/AbYOj2T.png">

# ggram – Telegram Bot Framework

> 🇬🇧 🇺🇸 NEED TRANSLATORS. Please, make pull requests if you wanna help. Temporarily I recommend [deepl](https://www.deepl.com/translator) to translate [this page](https://raw.githubusercontent.com/TRIGONIM/ggram/main/readme.md)

<p align="left">
	<img src="https://img.shields.io/github/languages/code-size/TRIGONIM/ggram">
	<img src="https://img.shields.io/github/license/TRIGONIM/ggram">
</p>

Создавайте Telegram ботов любой сложности на Lua

<img align="right" width="300" src="https://user-images.githubusercontent.com/9200174/135781831-dbb545a9-b3d9-4d0a-ba58-dd42935d35f0.png">

```lua
local bot = ggram("token")

bot.enable_polling() -- enables getUpdates loop

bot.command("start", function(ctx)
	ctx.reply.text("Hello @" .. ctx.from.username)
end)
```

Дополнительные примеры можно найти в [/examples](/examples)

---

## 💡 Demo
[Здесь (клик)](https://forum.gm-donate.ru/t/idei-telegram-botov-dlya-vashego-servera/197) опубликованы ссылки на работающие боты, а также множество идей, которые можно реализовать при помощи этого фреймворка для своего Garry's Mod сервера и не только. Возможности практически безграничны.

---

## ✨ Features
- Может работать как на чистом Lua, так и на Garry's Mod сервере
- НЕ требует никаких сторонних .dll или WEB прослоек
- Очень минималистичный и легко расширяемый
- Даже в случае отставания от Telegram API легко вызывать новые методы
- [Возможность](/lua/ggram/includes/surprise) отправки анимаций, документов, изображений
- Создан с учетом многолетного опыта создания ботов
- Дружит с парадигмой функционального программирования

---

## 🏗 Installation

#### 🐧 Linux / Mac

Install luarocks (package manager like apt but for lua)

```sh
sudo apt install luarocks # linux
# or
brew install luarocks # mac
```

Install ggram

```sh
luarocks install ggram # latest release
# or
luarocks install --server=https://luarocks.org/dev ggram # just latest
```

Make and run bot:
1. Create bot.lua file. You can choose any name for the file
2. Paste the contents of [/examples/echo.lua](/examples/echo.lua) into the file
3. Run file with `lua bot.lua`

**If any error was occur, check the troubleshooting part below**


#### 🎮 Garry's Mod
1. Скачайте ggram с этого репозитория и установите в `/addons/ggram`
2. Создайте файл `/addons/ggram_bots/lua/ggram/bots/anyname/_init.lua`
3. Заполните его содержимым демонстративного бота из папки [/examples](/examples), указав токен с [@BotFather](https://t.me/BotFather)

---

## 📚 Docs
- 🤔 [Что такое и как использовать update, context, middleware, reply](/info/understanding_things.md) (основные сущности)
- 🗂 [Где создавать бота, что кидать в extensions и зачем нужна includes](/info/project_structure.md)

---

## 😮 Development tips and tricks

> Не актуально для Garry's Mod

#### launcher.lua

Если вы планируете создать несколько ботов, то вместо отдельных файлов под каждый бот можно использовать один файл, который запустит все остальные боты примерно по такой схеме:

```lua
-- Опционально, путь к папке с модулями
package.path = package.path ..
	";/path/?.lua" ..
	";/path/?/init.lua"

-- Импорт ggram
require("ggram.core")

-- Список файлов с кодом ботов
local bots = {"bot_file1", "bot_file2"}
for _,bot_name in ipairs(bots) do
	assert(pcall(require, bot_name))
	print(bot_name .. " loaded")
end

-- Запускаем шарманку
ggram.idle()
```

#### Only one polling server

> Для тех, кто хочет работать с кучей ботов без личного веб сервера

Я [сделал микросервис](https://blog.amd-nick.me/poll-gmod-app-docs/), который принимает вебхуки от разных сервисов, а сам выступает в качестве polling сервера, подобно как работает getUpdates в Telegram. Все боты отправляют ему обновления, затем я HTTP GET запросом получаю их в одном месте.

Для работы с этим сервисом я написал небольшой фреймворк и если для вас это интересно, то я могу опубликовать гайд, как его применить.

#### Debugging

VSCode имеет очень крутой встроенный дебаггер. Если установить для него [Lua Debug плагин](https://marketplace.visualstudio.com/items?itemName=actboy168.lua-debug), то с его помощью удобнее заниматься разработкой

---

## 👩‍🔧 Troubleshooting

Пропустите при использовании ggram в системе, а не в пределах Garry's Mod

#### Lua versioning problems

Если на хосте установлено несколько версий Lua, что **особенно актуально для Mac**, то есть **вероятность** проблем из-за того, что luarocks использует версию Lua не ту же, что используется в системе по умолчанию.

**ggram тестировался на lua 5.3.6 и может не работать с более свежими версиями Lua**

Поэтому в случаях проблем с версиями, достаточно выполнять все luarocks команды c параметром `--lua-dir=$(brew --prefix)/opt/lua@5.3`, например `luarocks --lua-dir=$(brew --prefix)/opt/lua@5.3 install ggram`

Пример указан для Mac, на Linux lua будет в другой папке или установленная версия luarocks может вовсе не поддерживать такой параметр (Поддержка добавлена в luarocks 3.0.1)

На одном linux хосте у меня luarocks использует lua 5.1 и необходимости в таком параметре не было


#### $ luarocks install ggram

> Error: Your user does not have write permissions in /usr/local/lib/luarocks/rocks
> you may want to run as a privileged user or use your local tree with --local.

Just add `--local` argument to the command:

`$ luarocks install --local ggram`

#### $ luarocks install luasec

> luarocks install luasec — No file openssl/ssl.h

You need to install openssl

- Ubuntu: `apt install libssl-dev`, then retry command
- Mac: `brew install openssl`, then `luarocks install luasec OPENSSL_DIR=/opt/homebrew/opt/openssl@3`

#### Problems with luasocket installation

Ran into this on Ubuntu 20.04. I did not record the error itself

```sh
luarocks install luasocket
mkdir lua-build && cd lua-build
curl -R -O http://www.lua.org/ftp/lua-5.3.6.tar.gz && tar -zxf lua-5.3.6.tar.gz && cd lua-5.3.6
make linux test # You may need to sudo apt install make
make install
```

#### $ lua bot.lua

> lua: bot.lua:5: module 'ggram.core' not found

Происходит, если `luarocks install` выполнялся с параметром `--local`. В этом случае lua скрипту нужно сообщить, где искать модули. Для этого сверху файла с ботом нужно добавить:

```lua
-- /home/ubuntu/.luarocks/share/lua/5.1
-- /\ нужно заменить на путь к папке с модулями
-- Узнать можно выполнив luarocks show ggram
package.path = package.path
	.. ";/home/ubuntu/.luarocks/share/lua/5.1/?.lua"
	.. ";/home/ubuntu/.luarocks/share/lua/5.1/?/init.lua"
```

#### Other

If any of these problems are out of date or if you encounter others, then [create an Issue](https://github.com/TRIGONIM/ggram/issues/new), in which you need to specify the system version, the version of `lua -v`, and step by step the actions you have taken


---
> _Если остались вопросы, вы можете задать их в Telegram @amd_nick или создать Issue_
