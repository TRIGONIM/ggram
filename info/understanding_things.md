
# Описание сущностей

> Блок для продвинутых пользователей для улучшенного понимания, как тут все устроено


## context (ctx)
<img align="left" width="450" src="https://img.qweqwe.ovh/1631826032690.jpg">

Любое сообщение, которое получит ваш бот называется [update](https://core.telegram.org/bots/api#update). Оно оборачивается в обертку, называемой context. context это по сути и есть update объект с некоторыми дополнительными полями для упрощения взаимодействия с ботом (быстрые ответы и тд)

context объект передается всем хендлерам первым аргументом, например в bot.command(), bot.update(), bot.message() и т.д.

# handlers (Обработчики событий)
<img align="left" width="450" src="https://img.qweqwe.ovh/1631829101051.jpg">

По своей сути эти фильтры апдейтов. Когда вы пишете `bot.command("start", function(ctx) end)`, то добавляете фильтр к вашему боту, который выполнится только если в update найдена команда _/start_. `bot.update(callback, uid)` это тоже фильтр, но который выпоняется всегда.

Доступные фильтры можно посмотреть в `extensions/default_handlers.lua`, а также написать свои (например, для перехвата гифок или упоминаний и тд)

## middlewares
<img align="left" width="450" src="https://img.qweqwe.ovh/1631829516145.jpg">

Middlewares это когда обработчик событий не просто присылает вам в ответ "Привет", а еще может вмешаться в обработку апдейта, добавив новые данные в context, остановить обработку следующих обработчиков, банально залогировать запрос, ничего не меняя и тд. Все Middlewares это и есть **те самые обработчики** событий, просто иногда воспринимаются как модули.

> Все middlewares выполняются в том порядке, в котором вы их добавили и могут влиять на выполнение последующих

Пример:

```lua
	-- Перехватывает все запросы к боту и добавляет к контексту ctx.key
	bot.update(function(ctx) ctx.key = "value" end, "foo")

	-- Выполнится, если вы напишете боту /example
	-- И споскольку предыдущий middleware добавил поле key к ctx, то print(ctx.key) выведет "value"
	-- Обратите внимание на return false
	bot.command("example", function(ctx) print(ctx.key) return false end)

	-- Еще один обработчик событий, который не выполнится, если выполнится предыдущий, так как в нем мы сделали return false
	bot.update(function(ctx) print("Вы видите этот текст только, если не написали /example") end, "bar")
```

Middlewares позволяют управлять потоком запросов, модифицируя их на лету. К примеру, можно сделать middleware авторизации, rate-limit запросов, дополнительные методы для context и тд

```lua
local function attach_player(ctx)
	if ctx.message and ctx.message.from then
		ctx.steamid = sql.QueryValue("SELECT steamid FROM users WHERE telegram_id = " .. ctx.message.from.id) -- таблица выдумана
		ctx.player  = player.GetBySteamID(ctx.steamid) -- Если игрок не на сервере, то тут будет false
	end
end

local function restrict_access_for_non_admins(ctx)
	if not (ctx.player and ctx.player:IsSuperAdmin()) then
		ctx.reply.text("Бот только для администраторов")
		return false
	end
end

bot.update(attach_player, "attach_player")
bot.update(restrict_access_for_non_admins, "check_access")

bot.command("ban", function(ctx)
	ctx.reply.text("Вы админ, если смогли выполнить эту команду")
end)
```

Примеры некоторых подключаемых middlewares можно найти в папке `includes`.

## reply
<img align="left" width="450" src="https://img.qweqwe.ovh/1631829390410.jpg">

Этот объект упрощает [отправку запросов](https://core.telegram.org/bots/api#available-methods) к серверам Telegram. Отправка текста, изображений, стикеров, **удаление сообщений** и тд происходит через reply.

.reply присваивается большинству [updates](https://core.telegram.org/bots/api#update) и получить к нему доступ можно через ctx.reply

> Если нужно выполнить запрос, например отправить сообщение не из контекста, используйте `bot.reply(chat_id).text("Hello")`

Доступные методы можно увидеть в файле reply.lua.


---
> _Если остались вопросы, вы можете задать их в Telegram @amd_nick или создать Issue_
