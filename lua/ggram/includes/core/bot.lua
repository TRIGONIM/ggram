local BOT_MT = debug.getregistry().GG_BOT or {}
BOT_MT.__index = function(self, sMethod)
	local fMethod = BOT_MT[sMethod]
	return fMethod and function(...) return fMethod(self, ...) end or nil
end

debug.getregistry().GG_BOT = BOT_MT


local function wrapUpdate(upd) -- > ctx
	local wrapped_t = {update = upd}
	local wrapped_m = setmetatable(wrapped_t, {
		__index = function(self, k)
			return upd[k] or (upd.message and upd.message[k]) -- callback_query и другие упрощать через .use (#todo)
		end
	})

	return wrapped_m
end



local reply = ggram.include("core/reply")
function BOT_MT:reply(chat_id)
	return reply.get_instance(self, chat_id)
end

local request = ggram.include("core/request").request
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
local log_error = ggram.include("core/log_error")
function BOT_MT:handle_error(ctx)
	log_error(self.token, ctx.method, ctx.parameters, ctx.error)
	error(ctx.error)
end


function BOT_MT:on(fFilter, handler, uid)
	local priority = self.handler_index[uid]
	priority = priority or (#self.handlers + 1)
	self.handler_index[uid] = priority

	self.handlers[priority] = {fFilter, handler} -- + uid? Для поиска uid по ид
	return self
end

-- Yield с функцией "продолжить" внутри f:
-- coroutine.yield(function(cont) some_async(function(res) cont(res) end) end)
local coroutinize = function(f, ...)
	local co = coroutine.create(f)
	local function exec(...)
		local ok, data = coroutine.resume(co, ...)
		if not ok then
			error( debug.traceback(co, data) )
		end
		if coroutine.status(co) ~= "dead" then
			data(exec)
		end
	end
	exec(...)
end


local extend_callback = ggram.include("extend_callback")
local extend_message  = ggram.include("extend_message")
local coroutinize     = ggram.include("utils.coro").coroutinize
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
			local res = handler(ctx)
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
