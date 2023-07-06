-- for advanced users
-- Sequential execution of ctx.reply methods without using deferred.lua.
-- look at bot.command("test_async")

local ggram = require("ggram")

local bot = ggram("123456789:QWERTYUIOPASDFGHJKLZXCVBNM")

bot.enable_polling()

bot.update(ggram.include("middlewares.co_reply"), "co_reply_middleware")

-- The requests will be executed "simultaneously".
-- The messages may arrive in an interleaved manner: 3, 1, 2, 5, 4.
bot.command("test_async", function(ctx)
	ctx.reply.text("1")
	ctx.reply.text("2")
	ctx.reply.text("3")
	ctx.reply.text("4")
	ctx.reply.text("5")
end)

-- Using deferred.lua, Telegram will send the messages sequentially: 1, 2, 3, 4, 5.
bot.command("test_deferred", function(ctx)
	ctx.reply.text("1"):next(function()
		return ctx.reply.text("2")
	end):next(function()
		return ctx.reply.text("3")
	end):next(function()
		return ctx.reply.text("4")
	end):next(function()
		return ctx.reply.text("5")
	end)
end)

-- The requests will be executed sequentially.
-- Each ctx.reply.co.text() returns 2 values: bool ok, table msg || string err.
bot.command("test_co", function(ctx)
	ctx.reply.co.text("1")
	ctx.reply.co.text("2")
	ctx.reply.co.text("3")
	ctx.reply.co.text("4")
	local ok, msg = ctx.reply.co.text("5")
	if ok then
		ctx.reply.co.text( util.TableToJSON(msg) )
	end
end)

-- It is also possible to create own functions
-- that are executed sequentially within handlers,
-- while being inherently asynchronous:

--[[
-- Suspends the execution of a coroutine (handler) for a specific period of time.
local function co_sleep(seconds)
	coroutine.yield(function(cb) timer.Simple(seconds, cb) end)
end

-- Executes HTTP requests sequentially and returns the values.
local http_Fetch = require("http_async").get
local function co_fetch(url, headers)
	return coroutine.yield(function(cb)
		http_Fetch(url, function(body, ...)
			cb(true, body, ...)
		end, function(err)
			cb(false, err)
		end, headers)
	end)
end
]]

ggram.idle()
