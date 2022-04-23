-- #TODO write details about ctx object

-- Run this file with
-- lua echo.lua tmp
-- where tmp is a directory to store temporary files like polling offset

require("ggram.core")


local bot = ggram("123456789:QWERTYUIOPASDFGHJKLZXCVBNM") -- replace with your token (t.me/BotFather)
bot.enable_polling() -- start getUpdates loop


-- all handlers (like .text) described in default_handlers.lua
bot.text(function(ctx)
	ctx.reply.text(ctx.message.text)
end, "echo")


-- launch http requests, timers etc
ggram.idle()
