-- Adds the ctx.reply, ctx.json and ctx.answer helpers to ctx object

local util_JSONToTable = (util or require("gmod.util")).JSONToTable

return function(ctx)
	if not ctx.update.callback_query then return end

	local cbq = ctx.callback_query
	ctx.reply = cbq.message and ctx.bot.reply(cbq.message.chat.id)

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
