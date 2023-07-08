# Отправка .gif, .doc и других файлов

Для отправки файлов используется content-type `multipart/form-data`, а сами данные передаются в особом формате в теле POST запроса. В Lua и gLua нет встроенной поддержки отправки таких запросов, поэтому используется сторонняя библиотека [lua-multipart](https://github.com/Kong/lua-multipart/tree/master)

![](https://img.qweqwe.ovh/1633308905956.png)

> **Заметка для пользователей с Garry's Mod:** Гмод разрешает записывать в файловую систему (file.Write) файлы только с расширениями .txt, .dat и еще [некоторыми другими](https://wiki.facepunch.com/gmod/file.Write), но при этом мы все равно можем скачать через http.Fetch условно .gif, записать его как .txt, затем отправить этот .txt в телеграм как .gif и он успешно отобразится.

## Примеры

Для начала где угодно создайте файл `test.lua`, сверху файла вставьте заготовку:

```lua
local ggram = require("ggram")

require("ggram.extensions.multipart_methods") -- инжект multipart методов в .reply

local bot = ggram("123456789:QWERTYUIOPASDFGHJKLZXCVBNM")
local chat_id = 1234567 -- ID чата. Можно найти через t.me/jsonson_bot

-- Если у вас Garry's Mod сервер: в garrysmod/data должен быть указанный файл
-- Если у вас чистый Lua, то используйте io.open("file.gif", "rb"):read("*a")
local gif = file.Read("gif.txt", "DATA")

-- ...
```

#### Отправка файла

В примере также показано, что поддерживаются модификаторы запросов. Например, тут к анимации добавляется клавиатура

```lua
bot.reply(chat_id).inlineKeyboard({{
	{text = "Кнопка!", callback_data = "any"}
}}).documentFromFile(gif, "anim.gif")
```

#### Отправка альбома

Обратите внимание, что один файл отправляется одновременно как "видео" (видео без звука в Telegram это анимация) и как изображение. Telegram сам разберется

```lua
bot.reply(chat_id).mediaGroupFromFiles({
	{type = "photo", media = gif, caption = "Hello world"},
	{type = "video", media = gif},
})
```

#### Использование неподдерживаемого метода

В стандартном наборе добавлены только самые базовые методы в качестве примера, чтобы не перегружать кодовую базу, но вы можете использовать любой Telegram метод, требующий отправки файлов. В этом примере это `sendSticker`

```lua
local Multipart = require("multipart")

local form_data = Multipart()
form_data:set_simple("sticker", gif, "testfile.webp")
form_data:set_simple("protect_content", "true") -- дополнительные параметры тоже отправляются как form-data

bot.reply(chat_id).sendMultipart("sendSticker", form_data)
```


## Доступные методы

- `sendMultipart` - основной метод, который отправляет запрос с content-type `multipart` вместо обычного `form-urlencoded`.
- `documentFromFile` - под капотом [sendDocument](https://core.telegram.org/bots/api#senddocument)
- `photoFromFile` - [sendPhoto](https://core.telegram.org/bots/api#sendphoto)
- `mediaGroupFromFiles` - [sendMediaGroup](https://core.telegram.org/bots/api#sendmediagroup). Пример использования выше

## Добавление своих методов

ggram хранит доступные методы в таблице `ggram.methods`. Нужно просто добавить свой метод в нее по примеру из файла `multipart_methods.lua`. Например, так на примере [sendVoice](https://core.telegram.org/bots/api#sendvoice):

```lua
local Multipart = require("multipart")

function ggram.methods:sendVoiceFromFile(voice_raw_data, voice_name)
	local form_data = Multipart()
	form_data:set_simple("voice", voice_raw_data, voice_name)
	return self.sendMultipart("sendVoice", form_data)
end
```

Затем используйте этот метод, как любой другой из-под любого вашего бота
