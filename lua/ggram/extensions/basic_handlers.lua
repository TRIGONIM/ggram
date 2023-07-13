--- @submodule Bot

local BOT_MT = require("ggram.bot")

--- Перехватывает все апдейты. Хорошее место, чтобы добавлять общие middlewares
-- @function update
-- @tparam func handler колбек функция, которая выполнится при получении нового update от telegram
-- @tparam string uid уникальный идентификатор хендлера
-- @treturn Bot self
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
