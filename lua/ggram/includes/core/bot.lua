local BOT_MT = debug.getregistry().GG_BOT or {}
BOT_MT.__index = function(self, sMethod)
	local fMethod = BOT_MT[sMethod]
	return fMethod and function(...) return fMethod(self, ...) end or nil
end

debug.getregistry().GG_BOT = BOT_MT

local function promisify_handler(handler)
	return function(ctx)
		return deferred.new(function(d)
			local result = handler(ctx, ctx.reply)
			if result == false then
				d:reject(false)
			elseif istable(result) and result.next then
				return result -- already deferred
			else -- any value
				d:resolve(result)
			end
		end)
	end
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



local reply = ggram.include("core/reply")
function BOT_MT:reply(chat_id)
	return reply.get_instance(self, chat_id)
end

local request = ggram.include("core/request").request
function BOT_MT:call_method(method, parameters, options_)
	local doRequest = function()
		return request(self.token, method, parameters, options_, self.options.base_url)
	end

	return doRequest():next(nil, function(err)
		return self.handle_error(err, {
			retry = doRequest,
			method = method,
			parameters = parameters,
			options = options_,
		})
	end)
end

-- override me. p.s. ctx is not the same as in middlewares. Look inside bot:call_method
local log_error = ggram.include("core/log_error")
function BOT_MT:handle_error(err, ctx)
	log_error(self.token, ctx.method, ctx.parameters, err)
	error(err)
end


function BOT_MT:on(fFilter, handler, uid)
	local priority = self.handler_index[uid]
	priority = priority or (#self.handlers + 1)
	self.handler_index[uid] = priority

	self.handlers[priority] = {fFilter, handler} -- + uid? Для поиска uid по ид
	return self
end


local extend_callback = ggram.include("extend_callback")
local extend_message  = ggram.include("extend_message")
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

	return deferred.map(suitable_handlers, function(handler)
		return promisify_handler(handler)(ctx):next(function(res)
			table.insert(ctx.chain, res or "empty")
			return res
		end)
	end):next(function(res)
		return res
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
