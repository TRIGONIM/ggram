local BOT_MT = FindMetaTable("GG_BOT") or {}
BOT_MT.__index = function(self, sMethod)
	local fMethod = BOT_MT[sMethod]
	return fMethod and function(...) return fMethod(self, ...) end or nil
end

debug.getregistry().GG_BOT = BOT_MT



local function promisify_handler(handler)
	return function(ctx)
		local d = deferred.new()

		local result = handler(ctx, ctx.reply)
		if result == false then
			d:reject(false)
		elseif istable(result) and result.next then
			return result -- already deferred
		else -- any value
			d:resolve(result)
		end

		return d
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



local reply = include("ggram/reply.lua")
function BOT_MT:reply(chat_id)
	return reply.get_instance(self, chat_id)
end

local request = include("ggram/request.lua")
function BOT_MT:call_method(method, parameters)
	return request(self.token, method, parameters)
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
	log_fi("suitable_handlers({}/{})", #suitable_handlers, #self.handlers)

	return deferred.map(suitable_handlers, function(handler)
		log_fi("Беремся за {} хендлер", #ctx.chain + 1)
		return promisify_handler(handler)(ctx):next(function(res)
			table.insert(ctx.chain, res or "empty")
			return res
		end)
	end):next(function(res)
		log_fd("Успешно выполнили все {} хендлеров", #suitable_handlers)
		return res
	end, function(err) -- авторизация и тд.
		-- #todo error handlers. .on ctx.error
		log_fe("Один из {} хендлеров обосрался: {}", #suitable_handlers, tostring(err)) -- err mb false
		error(err)
	end)
end

function BOT_MT:init()
	return self.call_method("getMe", {}):next(function(res)
		self.id         = res.id
		self.username   = res.username
		self.first_name = res.first_name
		self.last_name  = res.last_name

		return res
	end, fp{print, "TLG getMe ERROR"})
end

return BOT_MT
