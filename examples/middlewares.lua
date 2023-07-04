-- for advanced users
-- understanding middlewares

require("ggram.core")

local bot = ggram("123456789:QWERTYUIOPASDFGHJKLZXCVBNM")

bot.enable_polling()

bot.update(ggram.include("session"), "session_middleware") -- extends ctx object with .sesion property

-- Executes before any other handlers that are added after this one.
-- so even the /test command will be processed with a delay.
bot.update(function(ctx)
	ctx.reply.markdown("Sleeping *4 seconds*")
	ctx.reply.action("typing")

	coroutine.yield(function(cb) (timer or require("gmod.timer")).Simple(4, cb) end)
end, "sleep")

-- The command /test will be processed in 4 seconds (if it was entered).
bot.command("test", function(ctx)
	local ses = ctx.session
	ses.presses = (ses.presses or 0) + 1

	ctx.reply.text(ctx.text .. " pressed " .. ses.presses .. " times")
end)

local http_Fetch = require("http_async").get
local function co_fetch(url)
	return coroutine.yield(function(cb)
		http_Fetch(url,
			function(body, ...) cb(true, body, ...) end,
			function(err) cb(false, err) end
		)
	end)
end

bot.command("delayed_handler", function(ctx)
	ctx.reply.text("fetching urls")
	local _, res1 = co_fetch("https://httpbin.org/delay/1")
	local _, res2 = co_fetch("https://httpbin.org/get")
	ctx.reply.text("fetching completed")

	ctx.session.http_results = {res1, res2}
end)

-- This handler will be executed simultaneously with the /test command.
bot.update(function(ctx)
	ctx.reply.markdown("Stopped. The 'done' text will send only if /delayed_handler called")
	return ctx.session.http_results ~= nil
end, "stop_middl")

bot.update(function(ctx)
	ctx.reply.text("Done. It's the last middleware. You see this because the /delayed_handler command was executed")
	assert(ctx.session.http_results ~= nil)
end, "done")

ggram.idle()
