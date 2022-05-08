local bot = BOT_OBJECT -- для крупных ботов рекомендую создавать глобальные бот-объекты: BOT_VAR = ggram("token")
local chat_id = 123456 -- узнать можно через @jsonson_bot

-- Отправка сообщения от бота вне контекста
do
	-- P.S. Это аналогичные записи
	-- .html является алиасом для .text("txt", "html")
	bot.reply(chat_id).text("<b>Жирный текст</b>, отправленный не из контекста", "html")
	bot.reply(chat_id).html("<b>Жирный текст</b>, отправленный не из контекста")

	bot.reply(chat_id)
		.keyboard({{"Text Button 1", "Button 2"}}) -- кнопки https://core.telegram.org/bots#keyboards
		.selective()
		.markdown("*Жирный* текст, с которым снизу чата появилсь кнопки")
end

-- Добавление несуществующего метода
do
	-- https://core.telegram.org/bots/api#sendsticker
	function ggram.methods:sticker(sticker)
		return self.setParameter("sticker", sticker).sendGeneric("sendSticker")
		-- return self.sendGeneric("sendSticker", {sticker = sticker}) -- так тоже можно
	end

	-- Вызов метода идет не через :, а через .:
	bot.reply(chat_id).sticker("sticker_url or file_id") -- example: https://www.gstatic.com/webp/gallery/4.sm.webp
end

-- Указание неподдерживаемого параметра в reply
do
	bot.reply(chat_id).setParameter("protect_content", true).text("Сообщение, которое нельзя переслать")
end
