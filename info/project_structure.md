# Файловая структура

### Порядок загрузки файлов после запуска сервера
1. /addons/ggram/lua/ggram`/core.lua`
2. /addons/ggram/lua/ggram`/extensions/*.lua`
3. /addons/ggram/lua/ggram`/bots/*/_init.lua`

---

<img align="left" width="450" src="https://img.qweqwe.ovh/1631811124184.jpg">

## [/extensions](/lua/ggram/extensions)
Директория, хранящая в себе файлы, которые должны расширить самый базовый функционал всех ботов. Это могут быть модификаторы метатаблиц ботов, какие-то ENUM константы, функции-утилиты, например `escapeMarkdown(text)` и т.д. Эти файлы грузятся до загрузки самих ботов

## [/bots](/lua/ggram/bots)
Директория, в которой вы должны хранить код ботов. Для каждого отдельного бота нужно создать свою поддиректорию. В `/bots/{anyname}` обязательно должен быть файл \_init.lua — этот файл будет загружен при include вашего бота. Вы можете создавать дополнительные файлы в `/bots/{botname}` и инклюдить их самостоятельно из-под \_init.lua. `/bots` загружаются после `core.lua` и `/extensions`

## [/includes](/lua/ggram/includes)
Файлы с загрузкой по востребованности. Функция `ggram.include(filename)` делает инклюд указанного файла в тот момент, когда вам это нужно. Например, вы создали `/includes/test_middleware.lua` с содержимым `return function(ctx) print("It works!") end`. Чтобы подключить такой мидлвер к боту, используйте в боте `bot.update(ggram.include("test_middleware"), "test")`. В `ggram.include` не нужно писать .lua в конце или абсолютный путь в начале. Папка может использоваться не только для хранения middlewares, но и любого другого контента

---
> _Если остались вопросы, вы можете задать их в Telegram @amd_nick или создать Issue_
> 