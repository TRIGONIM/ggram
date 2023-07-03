-- middleware that adds the co field to ctx.reply object which is a proxy for the main methods
-- Turns various ctx.reply.text into coroutine functions, for example ctx.reply.co.text
-- usage: bot.update(ggram.include("co_reply").middleware, "co_reply_middleware")

local deferred_to_yield = function(deferred_func)
	-- оверрайдим функцию метода, вызывая оригинальный, но превращая в корутину
	return function(...)
		local args = {...}
		return coroutine.yield(function(cb)
			deferred_func( unpack(args) ):next(function(res)
				cb(true, res)
			end, function(err)
				cb(false, err)
			end)
		end)
	end
end

local exports = {}

exports.middleware = function(ctx)
	local real_reply = ctx.reply

	ctx.reply.co = setmetatable({}, {
		__index = function(_, real_method_name)
			local method_func = real_reply[real_method_name]
			return deferred_to_yield(method_func)
		end
	})
end

exports.deferred_to_yield = deferred_to_yield

return exports
