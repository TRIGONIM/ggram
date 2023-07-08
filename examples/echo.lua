-- Run this file with lua echo.lua

local ggram = require("ggram")


local bot = ggram("123456789:QWERTYUIOPASDFGHJKLZXCVBNM") -- replace with your token (t.me/BotFather)
require("ggram.polling").start(bot) -- start getUpdates loop


-- all handlers (like .text) described in basic_handlers.lua
-- more info about ctx: /info/
bot.text(function(ctx)
	ctx.reply.text(ctx.message.text)
end, "echo")


-- launch http requests, timers etc
ggram.idle()
