local BOT_MT = {}
BOT_MT.__index = function(self, sMethod)
	local fMethod = BOT_MT[sMethod]
	return fMethod and function(...) return fMethod(self, ...) end or nil
end

local function wrapUpdate(upd) -- > ctx
	local wrapped_t = {update = upd}
	local wrapped_m = setmetatable(wrapped_t, {
		__index = function(self, k)
			return upd[k] or (upd.message and upd.message[k]) -- callback_query и другие упрощать через .use (#todo)
		end
	})

	return wrapped_m
end

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
		parameters = {}
	}, require("ggram.reply"))
end

local request = require("ggram.request").request
function BOT_MT:call_method(method, parameters_, http_struct_overrides_, try_)
	try_ = try_ or 1

	local ctx = {
		retry = function()
			return self.call_method(method, parameters_, http_struct_overrides_, try_ + 1)
		end,
		method = method,
		parameters = parameters_,
		options = options_,
		try = try_,
	}

	return request(self.token, method, parameters_, http_struct_overrides_, self.options.base_url)
		:next(nil, function(err)
			ctx.error = err -- array, look at rejections in ggram/request.lua
			return self.handle_error(ctx)
		end)
end

-- override me. p.s. ctx is not the same as in middlewares. Look inside BOT_MT:call_method
function BOT_MT:handle_error(ctx)
	local print_table = PrintTable or require("gmod.globals").PrintTable
	print(os.date("%Y-%m-%d %H:%M:%S") .. " [ggram] Error during request \\/")

	local full_info = {
		bot_name = self.username,
		bot_id = self.id,
		api_method = ctx.method,
		request_params = ctx.parameters,
		bot_options = ctx.options,
		error = ctx.error,
	}

	print_table(full_info)
	error(ctx.error) -- pass error to other :next(nil, cb) handlers
end

-- Ошибка в обработке команды/callback_query и тд.
function BOT_MT:handle_middleware_error(err)
	print("[ggram] middleware error: " .. debug.traceback(err))
end

function BOT_MT:on(fFilter, handler, uid)
	local priority = self.handler_index[uid]
	priority = priority or (#self.handlers + 1)
	self.handler_index[uid] = priority

	self.handlers[priority] = {fFilter, handler} -- + uid? Для поиска uid по ид
	return self
end

local extend_callback = require("ggram.middlewares.extend_callback")
local extend_message  = require("ggram.middlewares.extend_message")
local coroutinize     = require("ggram.helpers.coro").coroutinize
function BOT_MT:handle_update(UPD)
	local ctx = wrapUpdate(UPD)
	ctx.bot = self

	-- Своеобразные встроенные мидлверы
	extend_message(ctx)
	extend_callback(ctx)

	local suitable_handlers = {}
	for _,filter_handler in pairs(self.handlers) do
		if filter_handler[1](ctx) then -- подходит под контекст
			suitable_handlers[#suitable_handlers + 1] = filter_handler[2]
		end
	end

	ctx.chain = {} -- промежуточные результаты выполнений

	coroutinize(function()
		for _, handler in ipairs(suitable_handlers) do
			local ok, res = pcall(handler, ctx)
			if not ok then self.handle_middleware_error(res) end
			table.insert(ctx.chain, res or "empty")
			if res == false then break end -- остальные хендлеры не обрабатываем
		end
	end)
end

function BOT_MT:init()
	return self.call_method("getMe", {}):next(function(res)
		self.id         = res.id
		self.username   = res.username
		self.first_name = res.first_name
		self.last_name  = res.last_name

		return res
	end)
end

return BOT_MT
