--- Упрощает вызов API методов и доступ к полю message внутри update объекта.
--- Вместо `ctx.update.message.text` можно `ctx.text`.
--- Передается во все хендлеры.
-- @classmod Context

local string_Split = string.Split or require("gmod.string").Split
local util_JSONToTable = (util or require("gmod.util")).JSONToTable

local CTX = {}
CTX.__index = function(self, k)
	local upd = self.update
	return upd[k] or (upd.message and upd.message[k]) -- @todo callback_query и другие упрощать через .use
end

local function extract_args(argss)
	local tArgs = {}
	for _,arg in ipairs( string_Split(argss, " ") ) do
		if arg ~= "" then -- #todo нужно ли?
			tArgs[#tArgs + 1] = arg
		end
	end

	return tArgs
end

local function attach_command(ctx, ent)
	local msg = ctx.update.message
	local text = msg.text

	local start = ent.offset + 2
	local endd = start + ent.length - 2
	local psc = string_Split(text:sub(start, endd), "@")
	local name = psc[1]:lower() -- /CMD@botname > cmd

	local argss = text:sub(endd + 2)
	ctx.args = function() return extract_args(argss) end
	ctx.username = psc[2]
	ctx.command = name

	if ctx.username then
		ctx.mine = ctx.bot.username and ctx.bot.username:lower() == ctx.username:lower()
		ctx.exclusive = ctx.mine
	else
		ctx.mine = true
		ctx.exclusive = msg.chat.type == "private"
	end
end

--[[
	Example for /cmd@name_bot a b c

	ctx.args() > {a, b, c}
	ctx.username > name_bot
	ctx.command > cmd

	ctx.mine determines if this command exactly for this bot or either
	ctx.exclusive 100% for me or another candidates are possible?

	@todo rename to extend_command.lua. Move out ctx.reply = ctx.bot.reply(msg.chat.id)
]]
local extend_message = function(ctx)
	local msg = ctx.update.message
	for _,ent in ipairs(msg.entities or {}) do
		if ent.type == "bot_command" then
			attach_command(ctx, ent)
			break -- только первая, т.к. в аттаче присваивание сообщению команды и принадлежности
		end
	end
end

--- Adds the ctx.reply, ctx.json and ctx.answer helpers to ctx object
local extend_callback = function(ctx)
	local cbq = ctx.callback_query

	ctx.json = function()
		return util_JSONToTable(cbq.data)
	end

	ctx.answer = function(options)
		options = options or {}

		return ctx.bot.call_method("answerCallbackQuery", {
			callback_query_id = cbq.id,
			text              = options.text,
			show_alert        = options.alert,
			url               = options.url,
			cache_time        = options.cache_time,
		})
	end
end

--- Принимает update от Telegram и оборачивает его в ctx
--- @treturn .ctx Context object
function CTX:new(bot, UPD)
	local ctx = setmetatable({
		bot    = bot,
		update = UPD,
	}, CTX)

	if ctx.update.message then
		ctx.reply = ctx.bot.reply(ctx.update.message.chat.id)
		extend_message(ctx)
	elseif ctx.update.callback_query then
		local cbq = ctx.update.callback_query
		ctx.reply = cbq.message and ctx.bot.reply(cbq.message.chat.id)
		extend_callback(ctx)
	end

	return ctx
end


--- Сам ctx объект.
--- Это то, что мы видим в хендлерах, когда пишем `bot.command("cmd", function(ctx) end)` -- вот тут ctx
-- @table .ctx
-- @tfield table update Оригинальный update объект от Telegram
-- @tfield Bot bot быстрый доступ к боту по ctx.bot вместо self
-- @tfield Reply reply 🔥 быстрый API запрос (`ctx.reply.text("hello")`). Alias for ctx.bot.reply(ctx.chat.id)
-- @tfield[opt] string command Если это команда, то через ctx.command можно получить ее название. Для /TEST@botname .command будет == "test"
-- @tfield[opt] string username `/TEST@botname` > `"botname"`
-- @tfield[opt] func args `/TEST@botname a b c` > `{"a", "b", "c"}`
-- @tfield[opt] bool mine адресовалась ли команда именно этому боту. Если наш бот называется @ourbot, то для /cmd@otherbot .mine будет false. Если username не указывался, то mine будет всегда true
-- @tfield[opt] bool exclusive если команда указывалась с @botname, то .exclusive == .mine. Если без @botname, то .exclusive == true, если написано боту в ЛС
-- @tfield[opt] func json для `callback_query` кнопок это превратит json с .data в таблицу
-- @tfield[opt] func answer для `callback_query` это упрощение вызова API answerCallbackQuery. Подробнее лучше смотреть в `ggram/context.lua`

return CTX
