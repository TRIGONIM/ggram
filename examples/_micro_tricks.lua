local ggram = require("ggram")

GLOBAL_BOT = ggram("123456789:QWERTYUIOPASDFGHJKLZXCVBNM")

local bot = GLOBAL_BOT -- I recommend creating global bot objects for large bots: BOT_VAR = ggram("token")
local chat_id = 123456 -- you can find this via @jsonson_bot

-- Sending a message from a bot out of context
do
	-- P.S. These are similar entries
	-- .html is an alias for .text("txt", "html")
	bot.reply(chat_id).text("<b>Bold text</b> sent out of context", "html")
	bot.reply(chat_id).html("<b>Bold text</b> sent out of context")

	bot.reply(chat_id)
		.keyboard({{"Text Button 1", "Button 2"}}) -- buttons https://core.telegram.org/bots#keyboards
		.selective()
		.markdown("*Bold* text with which buttons appear at the bottom of the chat")
end

-- Adding a non-existent method
do
	-- moved to info file:
	-- /info/making_extensions.md
end

-- Specifying an unsupported parameter in reply
do
	bot.reply(chat_id).setParameter("protect_content", true).text("Message that cannot be forwarded")
end

ggram.idle()
