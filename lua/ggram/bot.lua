---@diagnostic disable: param-type-mismatch
--- Объект бота, создается через ggram()
---
--- ⚠️ Все методы здесь определяются через bot:method, но для вызова нужно использовать bot.method
-- @classmod Bot

local BOT_MT = {}
BOT_MT.__index = function(self, sMethod)
	local fMethod = BOT_MT[sMethod]
	return fMethod and function(...) return fMethod(self, ...) end or nil
end

--- Возвращает объект-конструктор запроса к Telegram API.
--- Прикрепляется к каждому ctx объекту.
-- @function reply
-- @tparam int chat_id ID пользователя, чата, канала, для которого будет выполняться API запрос
-- @treturn Reply Перейдите по ссылке, чтобы посмотреть примеры использования
-- @usage bot.reply(123456).text("Hello")
function BOT_MT:reply(chat_id)
	if not chat_id then
		local inf, path = debug.getinfo(2, "lS"), "unknown place"
		if inf.what ~= "C" then
			path = inf.short_src .. ":" .. inf.currentline
		end

		error("no chat_id provided to .reply method in " .. path)
	end

	return setmetatable({
		bot = self,
		id  = chat_id,
		parameters = {},
		files = {}, -- for multipart content
	}, require("ggram.reply"))
end

--- Выполняет http запрос к Telegram API
-- @function call_method
-- @tparam string method название API метода. Например, sendMessage
-- @tparam table parameters ключ-значение таблица с параметрами запроса. Например, {chat_id = 12345, text = "Hello"}
-- @tparam[opt] table http_struct_overrides ggram использует функцию HTTP. Вы можете перезаписать любой параметр, который перечислен тут: https://wiki.facepunch.com/gmod/Structures/HTTPRequest
-- @treturn Promise deferred object
-- @usage bot.call_method("setWebhook", {url = "https://example.com"})
local request = require("ggram.request").request
function BOT_MT:call_method(method, parameters_, http_struct_overrides_, try_)
	try_ = try_ or 1

	--- Таблица, которая передается в `bot.handle_error(err_ctx)`.
	-- @table .ErrCtx
	-- @tfield func retry, при вызове которой запрос повторится с теми же параметрами (полезно при retry-after ошибках)
	-- @tfield string method API метод, который бот пытался выполнить при запросе
	-- @tfield table parameters таблица параметров
	-- @tfield int try номер попытки выполнения запроса
	-- @tfield table error ошибка в чистом виде, которая получена от Telegram после выполнения запроса
	local err_ctx = {
		retry = function()
			return self.call_method(method, parameters_, http_struct_overrides_, try_ + 1)
		end,
		method = method,
		parameters = parameters_,
		try = try_,
	}

	return request(self.token, method, parameters_, http_struct_overrides_, self.options.base_url)
		:next(nil, function(err)
			err_ctx.error = err -- array, look at rejections in ggram/request.lua
			return self.handle_error(err_ctx)
		end)
end

--- Обработка ошибки запроса к Telegram API.
--- Функция для оверрайда. Вызывается, когда Telegram вернул ошибку после запроса.
--- По умолчанию принтит все данные об ошибке в консоль
-- @function handle_error
-- @tparam .ErrCtx err_ctx параметр отличается от обычного ctx
-- @usage
-- local defer = require("deferred")
-- function bot.handle_error(ctx)
-- 	local err = ctx.error
-- 	if err.extra and err.extra.http_error then
-- 		return defer.sleep(5):next(ctx.retry)
-- 	elseif err.error_code == 429 then
-- 		return defer.sleep(err.parameters.retry_after):next(ctx.retry)
-- 	end
-- 	error(err)
-- end
function BOT_MT:handle_error(err_ctx)
	local print_table = PrintTable or require("gmod.globals").PrintTable
	print(os.date("%Y-%m-%d %H:%M:%S") .. " [ggram] Error during request \\/")

	local full_info = {
		bot_name = self.username,
		bot_id = self.id,
		api_method = err_ctx.method,
		request_params = err_ctx.parameters,
		bot_options = err_ctx.options,
		error = err_ctx.error,
	}

	print_table(full_info)
	error(err_ctx.error) -- pass error to other :next(nil, cb) handlers
end

--- Обработка Lua ошибок внутри хендлеров.
--- Функция для оверрайда. Вызывается, когда pcall(handler) получил ошибку.
--- Ошибка в обработке команды/callback_query и тд.
-- @function handle_middleware_error
-- @tparam any err Результат неудачного выполнения pcall на хендлере
-- @usage
-- -- Отправка данных об ошибке в Telegram через отдельный бот
-- local report_bot = require("ggram")("1234:token")
-- local BOT_MT = require("ggram.bot")
-- function BOT_MT:handle_middleware_error(err)
-- 	local errtrace = "@" .. self.username .. " error: " .. debug.traceback(err)
-- 	report_bot.reply(123456).text(errtrace) -- chat_id
-- 	print("[ggram] " .. errtrace)
-- end
function BOT_MT:handle_middleware_error(err)
	print("[ggram] middleware error: " .. debug.traceback(err))
end

--- Выполняется, когда бот получает update.
--- Можно вызывать самостоятельно, чтобы организовать вебхуки или свою реализацию поллинга.
--- Внутри получает подходящие под update хендлеры и передает им update объект, обернутый в @{Context} (ctx).
-- @function handle_update
-- @tparam table UPD update объект от Telegram
local coroutinize = require("ggram.helpers.coro").coroutinize
function BOT_MT:handle_update(UPD)
	local ctx = require("ggram.context"):new(self, UPD)

	local suitable_handlers = {}
	for _,filter_handler in pairs(self.handlers) do
		if filter_handler[1](ctx) then -- подходит под контекст
			suitable_handlers[#suitable_handlers + 1] = filter_handler[2]
		end
	end

	coroutinize(function()
		for _, handler in ipairs(suitable_handlers) do
			local ok, res = pcall(handler, ctx)
			if not ok then self.handle_middleware_error(res) end
			if res == false then break end -- остальные хендлеры не обрабатываем
		end
	end)
end

--- Добавляет в бот хендлер на указанных условиях.
--- На основе этой функции созданы все хендлеры: bot.command, bot.callback, bot.update и т.д.
-- @function on
-- @tparam func fFilter сюда передается @{Context} (ctx). Если вернуть true, то выполнится handler(ctx)
-- @tparam func handler выполнятся, если fFilter вернул true
-- @tparam string uid уникальный идентификатор хендлера. Не должен повторяться для одного бота
-- @treturn Bot self
-- @usage
-- -- Вот так реализован bot.command хендлер:
-- local BOT_MT = require("ggram.bot")
-- function BOT_MT:command(name, handler)
-- 	return self.on(function(ctx)
-- 		return ctx.command == name
-- 	end, handler, "command_" .. name)
-- end
function BOT_MT:on(fFilter, handler, uid)
	local priority = self.handler_index[uid]
	priority = priority or (#self.handlers + 1)
	self.handler_index[uid] = priority

	self.handlers[priority] = {fFilter, handler} -- + uid? Для поиска uid по ид
	return self
end


---------------------------------------------------------
-- Basic Handlers
--
-- Основные хендлеры, созданы через @{bot:on}
--
-- @section BasicHandlers
---------------------------------------------------------

--- Перехватывает все апдейты. Хорошее место, чтобы добавлять общие middlewares
-- @function update
-- @tparam func handler колбек функция, которая выполнится при получении нового update от telegram
-- @tparam string uid уникальный идентификатор хендлера
-- @treturn Bot self
-- @see bot:on
function BOT_MT:update(handler, uid)
	return self.on(function()
		return true
	end, handler, "update_" .. uid)
end

--- Перехватывает команды бота
-- @function command
-- @tparam string name команда, при получении которой выполнять handler
-- @tparam func handler колбек функция, которая выполнится при получении указанной команды
-- @treturn Bot self
-- @usage bot.command("test", function(ctx) ctx.reply.text("Hello") end)
function BOT_MT:command(name, handler)
	return self.on(function(ctx)
		return ctx.command == name
	end, handler, "command_" .. name)
end

--- Нажата inline кнопка
-- @function callback
-- @tparam func handler функция, которая выполнится при нажатии inline кнопок
-- @tparam string uid уникальный идентификатор хендлера
-- @treturn Bot self
-- @usage
-- bot.command("test", function(ctx)
-- 	ctx.reply.inlineKeyboard({ {
-- 		{text = "Line 1, row 1", callback_data = "any"},
-- 	} }).text("Hello world!")
-- end)
-- bot.callback(function(ctx)
-- 	local query = ctx.callback_query
-- 	if query.data == "any" then
-- 		ctx.answer({text = "It's inline answer"})
-- 	end
-- end, "callback_example")
function BOT_MT:callback(handler, uid)
	return self.on(function(ctx)
		return ctx.callback_query ~= nil
	end, handler, "callback_" .. uid)
end

--- Пришло текстовое сообщение. Может также содержать команду.
--- Не gif, не callback_query и т.д.
-- @function text
-- @tparam func handler функция, которая выполнится при получении текстового сообщения
-- @tparam string uid уникальный идентификатор хендлера
-- @treturn Bot self
function BOT_MT:text(handler, uid)
	return self.on(function(ctx)
		return ctx.text ~= nil
	end, handler, "text_" .. uid)
end

--- Команды, гифки... Все, что имеет поле .message
-- @function message
-- @tparam func handler функция, которая выполнится при получении update с полем .message
-- @tparam string uid уникальный идентификатор хендлера
-- @treturn Bot self
function BOT_MT:message(handler, uid)
	return self.on(function(ctx)
		return ctx.message ~= nil
	end, handler, "message_" .. uid)
end


return BOT_MT
