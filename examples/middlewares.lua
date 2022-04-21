-- for advanced users
-- understanding middlewares

require("ggram.core")

local bot = ggram("123456789:QWERTYUIOPASDFGHJKLZXCVBNM")

bot.enable_polling()

bot.update(ggram.include("session"), "session_middleware") -- extends ctx object with .sesion property

local function deferred_sleep(time)
	local d = deferred.new() -- https://github.com/zserge/lua-promises/blob/master/deferred.lua
	timer.Simple(time, function() d:resolve() end)
	return d
end

bot.update(function(ctx)
	ctx.reply.markdown("Sleeping *4 seconds*")
	ctx.reply.action("typing")
	return deferred_sleep(4)
end, "sleep")

bot.command("test", function(ctx)
	local ses = ctx.session
	ses.presses = (ses.presses or 0) + 1

	return ctx.reply.text(ctx.text .. " pressed " .. ses.presses .. " times")
end)

bot.update(function(ctx)
	ctx.reply.text("Stopped. The 'done' text will not send. " ..
		"Just comment the return string or whole block to pass to the next function")

	return false
end, "stop_middl")

bot.update(function(ctx)
	ctx.reply.text("Done. It's the last middleware")
end, "done")

bot.idle()
