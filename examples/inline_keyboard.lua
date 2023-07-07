local ggram = require("ggram")

local bot = ggram("123456789:QWERTYUIOPASDFGHJKLZXCVBNM")
ggram.include("polling").start(bot)

bot.command("start", function(ctx)
	ctx.reply.inlineKeyboard({
		{
			{text = "Line 1, row 1", callback_data = "any"},
			{text = "Line 1, row 2", url = "https://example.com"}
		},
		{
			{text = "Line 2, row 1", callback_data = "any2"}
		}
	}).text("Hello world!")
end)


bot.callback(function(ctx)
	local query = ctx.callback_query
	if query.data == "any" then
		ctx.answer({text = "It's inline answer"})

	else
		ctx.reply.text("You just pressed button in second row. ctx.update:"):next(function()
			return ctx.reply.markdown("```\n" .. util.TableToJSON(ctx.update, true) .. "\n```")
		end):next(function()
			return ctx.reply.text("Json payload above 👆")
		end):next(function()
			return ctx.reply.text("The third message")
		end)
	end
end, "callback_example")

ggram.idle()
