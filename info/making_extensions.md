# Создание расширений

Добавление новых методов, хендлеров

## Добавление кастом хендлеров

По типу `bot.command("cmd", func)`, `bot.on_something()`

```lua
local BOT_MT = debug.getregistry().GG_BOT

function BOT_MT:regex_command(pattern, handler)
	return self.on(function(ctx)
		return ctx.command:match(pattern)
	end, handler, "regex_command_" .. pattern)
end
```

## Добавление новых методов

Если ggram пока что не поддерживает какой-то из новых API методов Telegram, его можно добавить самостоятельно

```lua
local ggram = require("ggram")

-- https://core.telegram.org/bots/api#sendsticker
function ggram.methods:sticker(sticker)
	return self.setParameter("sticker", sticker).sendGeneric("sendSticker")
	-- return self.sendGeneric("sendSticker", {sticker = sticker}) -- That's allowed, too.
end

-- Usage:
bot.reply(chat_id).sticker("https://www.gstatic.com/webp/gallery/4.sm.webp") -- sticker_url or file_id
```
