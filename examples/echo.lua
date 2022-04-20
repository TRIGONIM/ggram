-- #TODO write details about ctx object

local bot = ggram("123456789:QWERTYUIOPASDFGHJKLZXCVBNM") -- replace with your token (t.me/BotFather)
bot.enable_polling() -- start getUpdates loop


-- all handlers (like .text) described in default_handlers.lua
bot.text(function(ctx)
	ctx.reply.text(ctx.message.text)
end, "echo")


-- launch http requests, timers etc
bot.idle()
