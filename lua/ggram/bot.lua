local ggram = require("ggram")

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



local reply = ggram.include("reply")
function BOT_MT:reply(chat_id)
	return reply.get_instance(self, chat_id)
end

local request = ggram.include("request").request
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
			ctx.error = err
			return self.handle_error(ctx)
		end)
end

-- override me. p.s. ctx is not the same as in middlewares. Look inside bot:call_method
local log_error = ggram.include("helpers.log_error") -- #todo встроить сюда в код. Отдельный файл удалить
function BOT_MT:handle_error(ctx)
	log_error(self.token, ctx.method, ctx.parameters, ctx.error)
	error(ctx.error)
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

local extend_callback = ggram.include("middlewares.extend_callback")
local extend_message  = ggram.include("middlewares.extend_message")
local coroutinize     = ggram.include("helpers.coro").coroutinize
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
