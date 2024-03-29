-- middleware that adds the co field to ctx.reply object which is a proxy for the main methods
-- Turns various ctx.reply.text into coroutine functions, for example ctx.reply.co.text
-- usage: bot.update(require("ggram.middlewares.co_reply"), "co_reply_middleware")
-- in handler: local ok, res_or_rrr = ctx.reply.co.text("hello")

local def_to_yield = require("ggram.helpers.coro").deferred_to_yield

return function(ctx)
	local real_reply = ctx.reply

	ctx.reply.co = setmetatable({}, {
		__index = function(_, real_method_name)
			local method_func = real_reply[real_method_name]
			return def_to_yield(method_func)
		end
	})
end
